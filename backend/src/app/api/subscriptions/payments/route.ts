import { NextRequest } from "next/server";
import { db } from "@/db";
import { subscriptionPayments } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

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
    const conditions = subscriptionId ? [eq(subscriptionPayments.subscriptionId, subscriptionId)] : [];
    const rows = await db.select().from(subscriptionPayments).where(conditions.length > 0 ? conditions[0] : undefined).orderBy(desc(subscriptionPayments.paymentDate));
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
    } catch (e) { return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 }); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = paymentSchema.parse(body);
        const [updated] = await db.update(subscriptionPayments).set({ subscriptionId: data.subscriptionId, amount: data.amount.toString(), paymentDate: data.paymentDate, notes: data.notes }).where(eq(subscriptionPayments.id, id)).returning();
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
        await db.delete(subscriptionPayments).where(eq(subscriptionPayments.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
