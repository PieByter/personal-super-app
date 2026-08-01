import { NextRequest } from "next/server";
import { db } from "@/db";
import { journalEntries, journalTags, journalEntryTags } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { journalEntrySchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(journalEntries)
        .where(eq(journalEntries.userId, user.userId))
        .orderBy(desc(journalEntries.createdAt));

    return Response.json(entries);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = journalEntrySchema.parse(body);

        const [entry] = await db
            .insert(journalEntries)
            .values({
                userId: user.userId,
                title: data.title,
                problem: data.problem,
                rootCause: data.rootCause,
                solution: data.solution,
                conceptLearned: data.conceptLearned,
                codeSnippet: data.codeSnippet,
                language: data.language,
                projectName: data.projectName,
            })
            .returning();

        if (data.tagIds && data.tagIds.length > 0) {
            await db.insert(journalEntryTags).values(
                data.tagIds.map((tagId) => ({ journalId: entry.id, tagId }))
            );
        }

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
        const data = journalEntrySchema.parse(body);

        const [updated] = await db
            .update(journalEntries)
            .set({
                title: data.title,
                problem: data.problem,
                rootCause: data.rootCause,
                solution: data.solution,
                conceptLearned: data.conceptLearned,
                codeSnippet: data.codeSnippet,
                language: data.language,
                projectName: data.projectName,
                updatedAt: new Date(),
            })
            .where(eq(journalEntries.id, id))
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

        await db.delete(journalEntryTags).where(eq(journalEntryTags.journalId, id));
        await db.delete(journalEntries).where(eq(journalEntries.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
