import { NextRequest } from "next/server";
import { db } from "@/db";
import { subscriptionPayments, subscriptions } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, desc, inArray, getTableColumns } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const paymentSchema = z.object({
    subscriptionId: z.string().uuid(),
    amount: z.string().or(z.number()),
    paymentDate: z.string(),
    notes: z.string().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const subscriptionId = searchParams.get("subscriptionId");
    const conditions = [eq(subscriptions.userId, user.userId)];
    if (subscriptionId) conditions.push(eq(subscriptionPayments.subscriptionId, subscriptionId));
    const rows = await db
        .select({ ...getTableColumns(subscriptionPayments) })
        .from(subscriptionPayments)
        .innerJoin(subscriptions, eq(subscriptionPayments.subscriptionId, subscriptions.id))
        .where(and(...conditions))
        .orderBy(desc(subscriptionPayments.paymentDate));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = paymentSchema.parse(body);
        const [row] = await db.insert(subscriptionPayments).values({ subscriptionId: data.subscriptionId, amount: data.amount.toString(), paymentDate: data.paymentDate, notes: data.notes }).returning();
        return Response.json(row, { status: 201 });
    } catch (e) { return apiError(e); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = paymentSchema.parse(body);
        const [updated] = await db.update(subscriptionPayments).set({ subscriptionId: data.subscriptionId, amount: data.amount.toString(), paymentDate: data.paymentDate, notes: data.notes }).from(subscriptions).where(and(eq(subscriptionPayments.id, id), eq(subscriptionPayments.subscriptionId, subscriptions.id), eq(subscriptions.userId, user.userId))).returning();
        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) { return apiError(e); }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        await db.delete(subscriptionPayments).where(and(
            eq(subscriptionPayments.id, id),
            inArray(subscriptionPayments.subscriptionId, db.select({ id: subscriptions.id }).from(subscriptions).where(eq(subscriptions.userId, user.userId)))
        ));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
