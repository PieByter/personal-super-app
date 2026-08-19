import { NextRequest } from "next/server";
import { db } from "@/db";
import { users, passwordResets, refreshTokens } from "@/db/schema";
import { hashPassword } from "@/lib/auth";
import { rateLimit, rateLimitResponse } from "@/lib/rate-limit";
import { eq, and, isNull, gt } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const resetSchema = z.object({
    token: z.string().min(1),
    newPassword: z.string().min(8).max(128),
});

export async function POST(req: NextRequest) {
    const limit = rateLimit(req, { windowMs: 60_000, max: 5 });
    if (!limit.success) {
        return rateLimitResponse(limit.retryAfterSeconds ?? 60);
    }

    try {
        const body = await req.json();
        const data = resetSchema.parse(body);

        const [reset] = await db
            .select()
            .from(passwordResets)
            .where(
                and(
                    eq(passwordResets.token, data.token),
                    isNull(passwordResets.usedAt),
                    gt(passwordResets.expiresAt, new Date())
                )
            )
            .limit(1);

        if (!reset) {
            return Response.json({ error: "Invalid or expired reset token" }, { status: 400 });
        }

        const passwordHash = await hashPassword(data.newPassword);

        // Update the password and mark the token as used.
        await db
            .update(users)
            .set({ passwordHash, updatedAt: new Date() })
            .where(eq(users.id, reset.userId));
        await db
            .update(passwordResets)
            .set({ usedAt: new Date() })
            .where(eq(passwordResets.id, reset.id));

        // Revoke all refresh tokens for this user (force re-login everywhere).
        await db
            .update(refreshTokens)
            .set({ revokedAt: new Date() })
            .where(and(eq(refreshTokens.userId, reset.userId), isNull(refreshTokens.revokedAt)));

        return Response.json({ success: true });
    } catch (error) {
        return apiError(error);
    }
}
