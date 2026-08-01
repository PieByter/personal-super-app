import { NextRequest } from "next/server";
import { db } from "@/db";
import { habitLogs } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { habitLogSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const habitId = searchParams.get("habitId");
    const conditions = habitId ? [eq(habitLogs.habitId, habitId)] : [];
    const rows = await db.select().from(habitLogs).where(conditions.length > 0 ? conditions[0] : undefined).orderBy(desc(habitLogs.logDate));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = habitLogSchema.parse(body);
        const [row] = await db.insert(habitLogs).values({ habitId: data.habitId, logDate: data.logDate, value: data.value?.toString(), notes: data.notes, mood: data.mood }).returning();
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
        const data = habitLogSchema.parse(body);
        const [updated] = await db.update(habitLogs).set({ logDate: data.logDate, value: data.value?.toString(), notes: data.notes, mood: data.mood }).where(eq(habitLogs.id, id)).returning();
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
        await db.delete(habitLogs).where(eq(habitLogs.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
