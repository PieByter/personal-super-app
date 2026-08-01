import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeBudgets } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const budgetSchema = z.object({
    categoryId: z.string().uuid().optional(),
    amount: z.string().or(z.number()),
    period: z.enum(["weekly", "monthly", "yearly"]),
    startDate: z.string(),
    endDate: z.string().optional(),
    alertThreshold: z.string().or(z.number()).optional(),
    isActive: z.boolean().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const rows = await db.select().from(financeBudgets).where(eq(financeBudgets.userId, user.userId)).orderBy(desc(financeBudgets.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = budgetSchema.parse(body);
        const [row] = await db.insert(financeBudgets).values({ userId: user.userId, categoryId: data.categoryId, amount: data.amount.toString(), period: data.period, startDate: data.startDate, endDate: data.endDate, alertThreshold: data.alertThreshold?.toString(), isActive: data.isActive }).returning();
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
        const data = budgetSchema.parse(body);
        const [updated] = await db.update(financeBudgets).set({ categoryId: data.categoryId, amount: data.amount.toString(), period: data.period, startDate: data.startDate, endDate: data.endDate, alertThreshold: data.alertThreshold?.toString(), isActive: data.isActive }).where(eq(financeBudgets.id, id)).returning();
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
        await db.delete(financeBudgets).where(eq(financeBudgets.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
