import { NextRequest } from "next/server";
import { db } from "@/db";
import { dailyMetrics } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { dailyMetricSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const rows = await db.select().from(dailyMetrics).where(eq(dailyMetrics.userId, user.userId)).orderBy(desc(dailyMetrics.metricDate));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = dailyMetricSchema.parse(body);
        const [row] = await db.insert(dailyMetrics).values({
            userId: user.userId,
            metricDate: data.metricDate,
            sleepHours: data.sleepHours?.toString(),
            studyHours: data.studyHours?.toString(),
            codingHours: data.codingHours?.toString(),
            exerciseMinutes: data.exerciseMinutes,
            readingMinutes: data.readingMinutes,
            screenTimeMinutes: data.screenTimeMinutes,
            deepWorkHours: data.deepWorkHours?.toString(),
            mood: data.mood,
            energyLevel: data.energyLevel,
            notes: data.notes,
        }).returning();
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
        const data = dailyMetricSchema.parse(body);
        const [updated] = await db.update(dailyMetrics).set({
            metricDate: data.metricDate,
            sleepHours: data.sleepHours?.toString(),
            studyHours: data.studyHours?.toString(),
            codingHours: data.codingHours?.toString(),
            exerciseMinutes: data.exerciseMinutes,
            readingMinutes: data.readingMinutes,
            screenTimeMinutes: data.screenTimeMinutes,
            deepWorkHours: data.deepWorkHours?.toString(),
            mood: data.mood,
            energyLevel: data.energyLevel,
            notes: data.notes,
            updatedAt: new Date(),
        }).where(eq(dailyMetrics.id, id)).returning();
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
        await db.delete(dailyMetrics).where(eq(dailyMetrics.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
