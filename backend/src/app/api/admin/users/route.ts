import { NextRequest } from "next/server";
import { db } from "@/db";
import { users } from "@/db/schema";
import { getAuthUser, requireAdmin } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const updateUserSchema = z.object({
    fullName: z.string().optional(),
    role: z.enum(["user", "admin"]).optional(),
    timezone: z.string().optional(),
    currency: z.string().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    const adminCheck = requireAdmin(user);
    if (adminCheck) return adminCheck;

    const rows = await db.select({
        id: users.id,
        email: users.email,
        fullName: users.fullName,
        avatarUrl: users.avatarUrl,
        timezone: users.timezone,
        currency: users.currency,
        role: users.role,
        createdAt: users.createdAt,
    }).from(users).orderBy(desc(users.createdAt));

    return Response.json(rows);
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    const adminCheck = requireAdmin(user);
    if (adminCheck) return adminCheck;

    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        const body = await req.json();
        const data = updateUserSchema.parse(body);

        const [updated] = await db.update(users).set({
            fullName: data.fullName,
            role: data.role,
            timezone: data.timezone,
            currency: data.currency,
            updatedAt: new Date(),
        }).where(eq(users.id, id)).returning();

        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) {
        return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 });
    }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    const adminCheck = requireAdmin(user);
    if (adminCheck) return adminCheck;

    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        await db.delete(users).where(eq(users.id, id));
        return Response.json({ success: true });
    } catch (e) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
