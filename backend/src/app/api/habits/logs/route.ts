import { NextRequest } from "next/server";
import { db } from "@/db";
import { habitLogs, habits } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { habitLogSchema } from "@/lib/validation";
import { eq, and, desc, inArray, getTableColumns } from "drizzle-orm";
import { apiError } from "@/lib/api-error";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const habitId = searchParams.get("habitId");
    const conditions = [eq(habits.userId, user.userId)];
    if (habitId) conditions.push(eq(habitLogs.habitId, habitId));
    const rows = await db
        .select({ ...getTableColumns(habitLogs) })
        .from(habitLogs)
        .innerJoin(habits, eq(habitLogs.habitId, habits.id))
        .where(and(...conditions))
        .orderBy(desc(habitLogs.logDate));
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
    } catch (e) { return apiError(e); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = habitLogSchema.parse(body);
        const [updated] = await db.update(habitLogs).set({ logDate: data.logDate, value: data.value?.toString(), notes: data.notes, mood: data.mood }).from(habits).where(and(eq(habitLogs.id, id), eq(habitLogs.habitId, habits.id), eq(habits.userId, user.userId))).returning();
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
        await db.delete(habitLogs).where(and(
            eq(habitLogs.id, id),
            inArray(habitLogs.habitId, db.select({ id: habits.id }).from(habits).where(eq(habits.userId, user.userId)))
        ));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
