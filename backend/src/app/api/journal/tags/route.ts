import { NextRequest } from "next/server";
import { db } from "@/db";
import { journalTags } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

const tagSchema = z.object({
    name: z.string().min(1),
    color: z.string().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const rows = await db.select().from(journalTags).where(eq(journalTags.userId, user.userId)).orderBy(desc(journalTags.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = tagSchema.parse(body);
        const [row] = await db.insert(journalTags).values({ userId: user.userId, name: data.name, color: data.color }).returning();
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
        const data = tagSchema.parse(body);
        const [updated] = await db.update(journalTags).set({ name: data.name, color: data.color }).where(eq(journalTags.id, id)).returning();
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
        await db.delete(journalTags).where(eq(journalTags.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
