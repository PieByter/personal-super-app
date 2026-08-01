import { NextRequest } from "next/server";
import { db } from "@/db";
import { projects } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { projectSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(projects)
        .where(eq(projects.userId, user.userId))
        .orderBy(desc(projects.createdAt));

    return Response.json(entries);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = projectSchema.parse(body);

        const [entry] = await db
            .insert(projects)
            .values({
                userId: user.userId,
                name: data.name,
                description: data.description,
                goal: data.goal,
                priority: data.priority,
                startDate: data.startDate,
                targetDate: data.targetDate,
                techStack: data.techStack,
                gitRepository: data.gitRepository,
                color: data.color,
            })
            .returning();

        return Response.json(entry, { status: 201 });
    } catch (error) {
        if (error instanceof Error) {
            return Response.json({ error: error.message }, { status: 400 });
        }
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const { searchParams } = new URL(req.url);
        const id = searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        const body = await req.json();
        const data = projectSchema.parse(body);

        const [updated] = await db
            .update(projects)
            .set({
                name: data.name,
                description: data.description,
                goal: data.goal,
                priority: data.priority,
                startDate: data.startDate,
                targetDate: data.targetDate,
                techStack: data.techStack,
                gitRepository: data.gitRepository,
                color: data.color,
                updatedAt: new Date(),
            })
            .where(eq(projects.id, id))
            .returning();

        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });

        return Response.json(updated);
    } catch (error) {
        if (error instanceof Error) {
            return Response.json({ error: error.message }, { status: 400 });
        }
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const { searchParams } = new URL(req.url);
        const id = searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        await db.delete(projects).where(eq(projects.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
