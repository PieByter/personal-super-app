import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeSavingGoals } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const goalSchema = z.object({
    name: z.string().min(1),
    targetAmount: z.string().or(z.number()),
    currentAmount: z.string().or(z.number()).optional(),
    deadline: z.string().optional(),
    color: z.string().optional(),
    icon: z.string().optional(),
    isActive: z.boolean().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const rows = await db.select().from(financeSavingGoals).where(eq(financeSavingGoals.userId, user.userId)).orderBy(desc(financeSavingGoals.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = goalSchema.parse(body);
        const [row] = await db.insert(financeSavingGoals).values({ userId: user.userId, name: data.name, targetAmount: data.targetAmount.toString(), currentAmount: data.currentAmount?.toString(), deadline: data.deadline, color: data.color, icon: data.icon, isActive: data.isActive }).returning();
        return Response.json(row, { status: 201 });
    } catch (e) { return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 }); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = goalSchema.parse(body);
        const [updated] = await db.update(financeSavingGoals).set({ name: data.name, targetAmount: data.targetAmount.toString(), currentAmount: data.currentAmount?.toString(), deadline: data.deadline, color: data.color, icon: data.icon, isActive: data.isActive, updatedAt: new Date() }).where(eq(financeSavingGoals.id, id)).returning();
        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) { return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 }); }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        await db.delete(financeSavingGoals).where(eq(financeSavingGoals.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
