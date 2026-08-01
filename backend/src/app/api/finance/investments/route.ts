import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeInvestments } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const investmentSchema = z.object({
    name: z.string().min(1),
    type: z.string().min(1),
    symbol: z.string().optional(),
    quantity: z.string().or(z.number()),
    purchasePrice: z.string().or(z.number()),
    currentPrice: z.string().or(z.number()).optional(),
    purchaseDate: z.string(),
    broker: z.string().optional(),
    notes: z.string().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const rows = await db.select().from(financeInvestments).where(eq(financeInvestments.userId, user.userId)).orderBy(desc(financeInvestments.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = investmentSchema.parse(body);
        const [row] = await db.insert(financeInvestments).values({ userId: user.userId, name: data.name, type: data.type, symbol: data.symbol, quantity: data.quantity.toString(), purchasePrice: data.purchasePrice.toString(), currentPrice: data.currentPrice?.toString(), purchaseDate: data.purchaseDate, broker: data.broker, notes: data.notes }).returning();
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
        const data = investmentSchema.parse(body);
        const [updated] = await db.update(financeInvestments).set({ name: data.name, type: data.type, symbol: data.symbol, quantity: data.quantity.toString(), purchasePrice: data.purchasePrice.toString(), currentPrice: data.currentPrice?.toString(), purchaseDate: data.purchaseDate, broker: data.broker, notes: data.notes, updatedAt: new Date() }).where(eq(financeInvestments.id, id)).returning();
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
        await db.delete(financeInvestments).where(eq(financeInvestments.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
