import { NextRequest } from "next/server";
import { db } from "@/db";
import { refreshTokens } from "@/db/schema";
import { eq, and, isNull } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const logoutSchema = z.object({
    refreshToken: z.string().min(1),
});

export async function POST(req: NextRequest) {
    try {
        const body = await req.json();
        const data = logoutSchema.parse(body);

        // Revoke the refresh token so it can no longer be used.
        await db
            .update(refreshTokens)
            .set({ revokedAt: new Date() })
            .where(and(eq(refreshTokens.token, data.refreshToken), isNull(refreshTokens.revokedAt)));

        return Response.json({ success: true });
    } catch (error) {
        return apiError(error);
    }
}
