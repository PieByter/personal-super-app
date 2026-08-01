import { NextRequest } from "next/server";
import { db } from "@/db";
import { projectTasks } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { projectTaskSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const projectId = searchParams.get("projectId");
    const conditions = projectId ? [eq(projectTasks.projectId, projectId)] : [];
    const rows = await db.select().from(projectTasks).where(conditions.length > 0 ? conditions[0] : undefined).orderBy(desc(projectTasks.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = projectTaskSchema.parse(body);
        const [row] = await db.insert(projectTasks).values({ projectId: data.projectId, milestoneId: data.milestoneId, title: data.title, description: data.description, status: data.status, priority: data.priority, dueDate: data.dueDate, tags: data.tags }).returning();
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
        const data = projectTaskSchema.parse(body);
        const [updated] = await db.update(projectTasks).set({ milestoneId: data.milestoneId, title: data.title, description: data.description, status: data.status, priority: data.priority, dueDate: data.dueDate, tags: data.tags, updatedAt: new Date() }).where(eq(projectTasks.id, id)).returning();
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
        await db.delete(projectTasks).where(eq(projectTasks.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
