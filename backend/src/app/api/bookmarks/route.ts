import { NextRequest } from "next/server";
import { db } from "@/db";
import { bookmarks } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { bookmarkSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(bookmarks)
        .where(eq(bookmarks.userId, user.userId))
        .orderBy(desc(bookmarks.createdAt));

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
            .where(eq(bookmarks.id, id))
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

        await db.delete(bookmarks).where(eq(bookmarks.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
