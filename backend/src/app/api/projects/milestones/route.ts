import { NextRequest } from "next/server";
import { db } from "@/db";
import { projectMilestones } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const milestoneSchema = z.object({
    projectId: z.string().uuid(),
    title: z.string().min(1),
    description: z.string().optional(),
    dueDate: z.string().optional(),
    isCompleted: z.boolean().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const projectId = searchParams.get("projectId");
    const conditions = projectId ? [eq(projectMilestones.projectId, projectId)] : [];
    const rows = await db.select().from(projectMilestones).where(conditions.length > 0 ? conditions[0] : undefined).orderBy(desc(projectMilestones.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = milestoneSchema.parse(body);
        const [row] = await db.insert(projectMilestones).values({ projectId: data.projectId, title: data.title, description: data.description, dueDate: data.dueDate, isCompleted: data.isCompleted }).returning();
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
        const data = milestoneSchema.parse(body);
        const [updated] = await db.update(projectMilestones).set({ title: data.title, description: data.description, dueDate: data.dueDate, isCompleted: data.isCompleted, completedAt: data.isCompleted ? new Date() : null }).where(eq(projectMilestones.id, id)).returning();
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
        await db.delete(projectMilestones).where(eq(projectMilestones.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
