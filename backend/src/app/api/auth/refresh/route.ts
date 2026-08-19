import { NextRequest } from "next/server";
import { db } from "@/db";
import { refreshTokens, users } from "@/db/schema";
import { generateAccessToken, generateRefreshToken } from "@/lib/auth";
import { rateLimit, rateLimitResponse } from "@/lib/rate-limit";
import { eq, and, isNull, gt } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const refreshSchema = z.object({
    refreshToken: z.string().min(1),
});

const REFRESH_TOKEN_DAYS = 30;

export async function POST(req: NextRequest) {
    const limit = rateLimit(req, { windowMs: 60_000, max: 20 });
    if (!limit.success) {
        return rateLimitResponse(limit.retryAfterSeconds ?? 60);
    }

    try {
        const body = await req.json();
        const data = refreshSchema.parse(body);

        // Find a valid, non-revoked, non-expired refresh token.
        const [stored] = await db
            .select()
            .from(refreshTokens)
            .where(
                and(
                    eq(refreshTokens.token, data.refreshToken),
                    isNull(refreshTokens.revokedAt),
                    gt(refreshTokens.expiresAt, new Date())
                )
            )
            .limit(1);

        if (!stored) {
            return Response.json({ error: "Invalid refresh token" }, { status: 401 });
        }

        const [user] = await db
            .select({ id: users.id, email: users.email, role: users.role })
            .from(users)
            .where(eq(users.id, stored.userId))
            .limit(1);

        if (!user) {
            return Response.json({ error: "User not found" }, { status: 401 });
        }

        // Revoke the old refresh token (rotation).
        await db
            .update(refreshTokens)
            .set({ revokedAt: new Date() })
            .where(eq(refreshTokens.id, stored.id));

        // Issue a new pair.
        const role = user.role || "user";
        const accessToken = generateAccessToken(user.id, user.email, role);
        const refreshToken = generateRefreshToken();
        const expiresAt = new Date(Date.now() + REFRESH_TOKEN_DAYS * 24 * 60 * 60 * 1000);
        await db.insert(refreshTokens).values({
            userId: user.id,
            token: refreshToken,
            expiresAt,
        });

        return Response.json({ accessToken, refreshToken });
    } catch (error) {
        return apiError(error);
    }
}
