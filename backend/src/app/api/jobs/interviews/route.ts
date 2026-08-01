import { NextRequest } from "next/server";
import { db } from "@/db";
import { jobInterviews } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const interviewSchema = z.object({
    jobId: z.string().uuid(),
    round: z.number().optional(),
    interviewType: z.string().min(1),
    scheduledAt: z.string().optional(),
    durationMinutes: z.number().optional(),
    location: z.string().optional(),
    meetingUrl: z.string().optional(),
    interviewerName: z.string().optional(),
    interviewerEmail: z.string().optional(),
    notes: z.string().optional(),
    status: z.string().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const jobId = searchParams.get("jobId");
    const conditions = jobId ? [eq(jobInterviews.jobId, jobId)] : [];
    const rows = await db.select().from(jobInterviews).where(conditions.length > 0 ? conditions[0] : undefined).orderBy(desc(jobInterviews.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = interviewSchema.parse(body);
        const [row] = await db.insert(jobInterviews).values({ jobId: data.jobId, round: data.round, interviewType: data.interviewType, scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : null, durationMinutes: data.durationMinutes, location: data.location, meetingUrl: data.meetingUrl, interviewerName: data.interviewerName, interviewerEmail: data.interviewerEmail, notes: data.notes, status: data.status }).returning();
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
        const data = interviewSchema.parse(body);
        const [updated] = await db.update(jobInterviews).set({ round: data.round, interviewType: data.interviewType, scheduledAt: data.scheduledAt ? new Date(data.scheduledAt) : null, durationMinutes: data.durationMinutes, location: data.location, meetingUrl: data.meetingUrl, interviewerName: data.interviewerName, interviewerEmail: data.interviewerEmail, notes: data.notes, status: data.status }).where(eq(jobInterviews.id, id)).returning();
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
        await db.delete(jobInterviews).where(eq(jobInterviews.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
