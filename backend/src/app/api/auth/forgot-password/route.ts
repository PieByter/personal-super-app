import { NextRequest } from "next/server";
import { db } from "@/db";
import { users, passwordResets } from "@/db/schema";
import { randomBytes } from "crypto";
import { rateLimit, rateLimitResponse } from "@/lib/rate-limit";
import { eq } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const forgotSchema = z.object({
    email: z.string().email(),
});

const RESET_TOKEN_TTL_MINUTES = 15;

export async function POST(req: NextRequest) {
    const limit = rateLimit(req, { windowMs: 60_000, max: 5 });
    if (!limit.success) {
        return rateLimitResponse(limit.retryAfterSeconds ?? 60);
    }

    try {
        const body = await req.json();
        const data = forgotSchema.parse(body);

        const [user] = await db
            .select({ id: users.id })
            .from(users)
            .where(eq(users.email, data.email))
            .limit(1);

        // Always return the same message to avoid user enumeration.
        if (!user) {
            return Response.json({
                message: "If that email is registered, a reset token has been sent.",
            });
        }

        const token = randomBytes(32).toString("hex");
        const expiresAt = new Date(Date.now() + RESET_TOKEN_TTL_MINUTES * 60 * 1000);

        await db.insert(passwordResets).values({
            userId: user.id,
            token,
            expiresAt,
        });

        // NOTE: This is a personal app without an email service, so the token
        // is returned directly. In production, send it via email instead and
        // do NOT include it in the response.
        return Response.json({
            message: "If that email is registered, a reset token has been sent.",
            resetToken: token,
            expiresInMinutes: RESET_TOKEN_TTL_MINUTES,
        });
    } catch (error) {
        return apiError(error);
    }
}
