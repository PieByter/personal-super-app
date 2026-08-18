import { NextRequest } from "next/server";
import { db } from "@/db";
import { users } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq } from "drizzle-orm";
import { z } from "zod";

const updateProfileSchema = z.object({
    fullName: z.string().min(1).max(255).optional(),
    avatarUrl: z.string().url().optional().nullable(),
    timezone: z.string().max(50).optional(),
    currency: z.string().max(10).optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const [row] = await db
        .select({
            id: users.id,
            email: users.email,
            fullName: users.fullName,
            avatarUrl: users.avatarUrl,
            timezone: users.timezone,
            currency: users.currency,
            role: users.role,
            createdAt: users.createdAt,
            updatedAt: users.updatedAt,
        })
        .from(users)
        .where(eq(users.id, user.userId))
        .limit(1);

    if (!row) return Response.json({ error: "User not found" }, { status: 404 });
    return Response.json(row);
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = updateProfileSchema.parse(body);

        const [updated] = await db
            .update(users)
            .set({
                fullName: data.fullName,
                avatarUrl: data.avatarUrl,
                timezone: data.timezone,
                currency: data.currency,
                updatedAt: new Date(),
            })
            .where(eq(users.id, user.userId))
            .returning({
                id: users.id,
                email: users.email,
                fullName: users.fullName,
                avatarUrl: users.avatarUrl,
                timezone: users.timezone,
                currency: users.currency,
                role: users.role,
                updatedAt: users.updatedAt,
            });

        if (!updated) return Response.json({ error: "User not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) {
        return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 });
    }
}
