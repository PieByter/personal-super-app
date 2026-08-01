import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeCategories } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { categorySchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const rows = await db.select().from(financeCategories).where(eq(financeCategories.userId, user.userId)).orderBy(desc(financeCategories.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = categorySchema.parse(body);
        const [row] = await db.insert(financeCategories).values({ userId: user.userId, name: data.name, type: data.type, color: data.color, icon: data.icon, parentId: data.parentId }).returning();
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
        const data = categorySchema.parse(body);
        const [updated] = await db.update(financeCategories).set({ name: data.name, type: data.type, color: data.color, icon: data.icon, parentId: data.parentId }).where(eq(financeCategories.id, id)).returning();
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
        await db.delete(financeCategories).where(eq(financeCategories.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
