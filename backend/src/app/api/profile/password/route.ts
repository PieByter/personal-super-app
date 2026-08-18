import { NextRequest } from "next/server";
import { db } from "@/db";
import { users } from "@/db/schema";
import { getAuthUser, unauthorizedResponse, hashPassword, verifyPassword } from "@/lib/auth";
import { rateLimit, rateLimitResponse } from "@/lib/rate-limit";
import { eq } from "drizzle-orm";
import { z } from "zod";

const changePasswordSchema = z.object({
    currentPassword: z.string().min(1),
    newPassword: z.string().min(8).max(128),
});

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const limit = rateLimit(req, { windowMs: 60_000, max: 5 });
    if (!limit.success) {
        return rateLimitResponse(limit.retryAfterSeconds ?? 60);
    }

    try {
        const body = await req.json();
        const data = changePasswordSchema.parse(body);

        const [row] = await db
            .select({ passwordHash: users.passwordHash })
            .from(users)
            .where(eq(users.id, user.userId))
            .limit(1);

        if (!row) return Response.json({ error: "User not found" }, { status: 404 });

        const valid = await verifyPassword(data.currentPassword, row.passwordHash);
        if (!valid) {
            return Response.json({ error: "Current password is incorrect" }, { status: 400 });
        }

        const passwordHash = await hashPassword(data.newPassword);
        await db
            .update(users)
            .set({ passwordHash, updatedAt: new Date() })
            .where(eq(users.id, user.userId));

        return Response.json({ success: true });
    } catch (e) {
        return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 });
    }
}
