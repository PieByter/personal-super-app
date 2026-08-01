import { NextRequest } from "next/server";
import { db } from "@/db";
import { bugEntries } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { bugEntrySchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(bugEntries)
        .where(eq(bugEntries.userId, user.userId))
        .orderBy(desc(bugEntries.createdAt));

    return Response.json(entries);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = bugEntrySchema.parse(body);

        const [entry] = await db
            .insert(bugEntries)
            .values({
                userId: user.userId,
                title: data.title,
                projectName: data.projectName,
                technology: data.technology,
                errorMessage: data.errorMessage,
                errorType: data.errorType,
                cause: data.cause,
                solution: data.solution,
                severity: data.severity,
                tags: data.tags,
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
        const data = bugEntrySchema.parse(body);

        const [updated] = await db
            .update(bugEntries)
            .set({
                title: data.title,
                projectName: data.projectName,
                technology: data.technology,
                errorMessage: data.errorMessage,
                errorType: data.errorType,
                cause: data.cause,
                solution: data.solution,
                severity: data.severity,
                tags: data.tags,
                updatedAt: new Date(),
            })
            .where(eq(bugEntries.id, id))
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

        await db.delete(bugEntries).where(eq(bugEntries.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
