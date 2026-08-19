import { NextRequest } from "next/server";
import { db } from "@/db";
import { habits } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { habitSchema } from "@/lib/validation";
import { getPagination, paginateResponse } from "@/lib/pagination";
import { eq, and, desc, count } from "drizzle-orm";
import { apiError } from "@/lib/api-error";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const pagination = getPagination(req);
    const baseQuery = db
        .select()
        .from(habits)
        .where(eq(habits.userId, user.userId))
        .orderBy(desc(habits.createdAt));

    if (pagination.enabled) {
        const [totalRow] = await db
            .select({ value: count() })
            .from(habits)
            .where(eq(habits.userId, user.userId));
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
        const data = habitSchema.parse(body);

        const [entry] = await db
            .insert(habits)
            .values({
                userId: user.userId,
                name: data.name,
                description: data.description,
                icon: data.icon,
                color: data.color,
                targetValue: data.targetValue?.toString(),
                unit: data.unit,
                frequency: data.frequency,
                targetDays: data.targetDays,
                reminderTime: data.reminderTime,
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
        const data = habitSchema.parse(body);

        const [updated] = await db
            .update(habits)
            .set({
                name: data.name,
                description: data.description,
                icon: data.icon,
                color: data.color,
                targetValue: data.targetValue?.toString(),
                unit: data.unit,
                frequency: data.frequency,
                targetDays: data.targetDays,
                reminderTime: data.reminderTime,
                updatedAt: new Date(),
            })
            .where(and(eq(habits.id, id), eq(habits.userId, user.userId)))
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

        await db.delete(habits).where(and(eq(habits.id, id), eq(habits.userId, user.userId)));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
