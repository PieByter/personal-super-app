import { NextRequest } from "next/server";
import { db } from "@/db";
import { projectMilestones, projects } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, desc, inArray, getTableColumns } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

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
    const conditions = [eq(projects.userId, user.userId)];
    if (projectId) conditions.push(eq(projectMilestones.projectId, projectId));
    const rows = await db
        .select({ ...getTableColumns(projectMilestones) })
        .from(projectMilestones)
        .innerJoin(projects, eq(projectMilestones.projectId, projects.id))
        .where(and(...conditions))
        .orderBy(desc(projectMilestones.createdAt));
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
    } catch (e) { return apiError(e); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = milestoneSchema.parse(body);
        const [updated] = await db.update(projectMilestones).set({ title: data.title, description: data.description, dueDate: data.dueDate, isCompleted: data.isCompleted, completedAt: data.isCompleted ? new Date() : null }).from(projects).where(and(eq(projectMilestones.id, id), eq(projectMilestones.projectId, projects.id), eq(projects.userId, user.userId))).returning();
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
        await db.delete(projectMilestones).where(and(
            eq(projectMilestones.id, id),
            inArray(projectMilestones.projectId, db.select({ id: projects.id }).from(projects).where(eq(projects.userId, user.userId)))
        ));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
