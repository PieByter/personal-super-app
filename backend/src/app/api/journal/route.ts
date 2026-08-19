import { NextRequest } from "next/server";
import { db } from "@/db";
import { journalEntries, journalTags, journalEntryTags } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { journalEntrySchema } from "@/lib/validation";
import { getPagination, paginateResponse } from "@/lib/pagination";
import { eq, and, desc, count } from "drizzle-orm";
import { apiError } from "@/lib/api-error";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const pagination = getPagination(req);
    const baseQuery = db
        .select()
        .from(journalEntries)
        .where(eq(journalEntries.userId, user.userId))
        .orderBy(desc(journalEntries.createdAt));

    if (pagination.enabled) {
        const [totalRow] = await db
            .select({ value: count() })
            .from(journalEntries)
            .where(eq(journalEntries.userId, user.userId));
        const total = totalRow?.value ?? 0;
        const rows = await baseQuery.limit(pagination.pageSize).offset(pagination.offset);
        return Response.json(paginateResponse(rows, total, pagination));
    }

    const entries = await baseQuery;
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
        return apiError(error);
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
            .where(and(eq(journalEntries.id, id), eq(journalEntries.userId, user.userId)))
            .returning();

        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });

        return Response.json(updated);
    } catch (error) {
        return apiError(error);
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
        await db.delete(journalEntries).where(and(eq(journalEntries.id, id), eq(journalEntries.userId, user.userId)));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
