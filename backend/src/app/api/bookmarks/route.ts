import { NextRequest } from "next/server";
import { db } from "@/db";
import { bookmarks } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { bookmarkSchema } from "@/lib/validation";
import { getPagination, paginateResponse } from "@/lib/pagination";
import { eq, and, desc, count } from "drizzle-orm";
import { apiError } from "@/lib/api-error";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const pagination = getPagination(req);
    const baseQuery = db
        .select()
        .from(bookmarks)
        .where(eq(bookmarks.userId, user.userId))
        .orderBy(desc(bookmarks.createdAt));

    if (pagination.enabled) {
        const [totalRow] = await db
            .select({ value: count() })
            .from(bookmarks)
            .where(eq(bookmarks.userId, user.userId));
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
        const data = bookmarkSchema.parse(body);

        const [entry] = await db
            .insert(bookmarks)
            .values({
                userId: user.userId,
                collectionId: data.collectionId,
                title: data.title,
                url: data.url,
                description: data.description,
                notes: data.notes,
                status: data.status,
                rating: data.rating,
                tags: data.tags,
            })
            .returning();

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
        const data = bookmarkSchema.parse(body);

        const [updated] = await db
            .update(bookmarks)
            .set({
                collectionId: data.collectionId,
                title: data.title,
                url: data.url,
                description: data.description,
                notes: data.notes,
                status: data.status,
                rating: data.rating,
                tags: data.tags,
                updatedAt: new Date(),
            })
            .where(and(eq(bookmarks.id, id), eq(bookmarks.userId, user.userId)))
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

        await db.delete(bookmarks).where(and(eq(bookmarks.id, id), eq(bookmarks.userId, user.userId)));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
