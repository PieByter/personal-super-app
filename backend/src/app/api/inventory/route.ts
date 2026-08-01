import { NextRequest } from "next/server";
import { db } from "@/db";
import { inventoryItems } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { inventoryItemSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(inventoryItems)
        .where(eq(inventoryItems.userId, user.userId))
        .orderBy(desc(inventoryItems.createdAt));

    return Response.json(entries);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = inventoryItemSchema.parse(body);

        const [entry] = await db
            .insert(inventoryItems)
            .values({
                userId: user.userId,
                categoryId: data.categoryId,
                name: data.name,
                description: data.description,
                brand: data.brand,
                model: data.model,
                serialNumber: data.serialNumber,
                purchaseDate: data.purchaseDate,
                purchasePrice: data.purchasePrice?.toString(),
                currentValue: data.currentValue?.toString(),
                condition: data.condition,
                location: data.location,
                warrantyExpiry: data.warrantyExpiry,
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
        const data = inventoryItemSchema.parse(body);

        const [updated] = await db
            .update(inventoryItems)
            .set({
                categoryId: data.categoryId,
                name: data.name,
                description: data.description,
                brand: data.brand,
                model: data.model,
                serialNumber: data.serialNumber,
                purchaseDate: data.purchaseDate,
                purchasePrice: data.purchasePrice?.toString(),
                currentValue: data.currentValue?.toString(),
                condition: data.condition,
                location: data.location,
                warrantyExpiry: data.warrantyExpiry,
                tags: data.tags,
                updatedAt: new Date(),
            })
            .where(eq(inventoryItems.id, id))
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

        await db.delete(inventoryItems).where(eq(inventoryItems.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
