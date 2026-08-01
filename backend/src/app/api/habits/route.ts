import { NextRequest } from "next/server";
import { db } from "@/db";
import { habits } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { habitSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(habits)
        .where(eq(habits.userId, user.userId))
        .orderBy(desc(habits.createdAt));

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
            .where(eq(habits.id, id))
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

        await db.delete(habits).where(eq(habits.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
