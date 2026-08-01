import { NextRequest } from "next/server";
import { db } from "@/db";
import { subscriptions } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { subscriptionSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(subscriptions)
        .where(eq(subscriptions.userId, user.userId))
        .orderBy(desc(subscriptions.createdAt));

    return Response.json(entries);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = subscriptionSchema.parse(body);

        const [entry] = await db
            .insert(subscriptions)
            .values({
                userId: user.userId,
                name: data.name,
                description: data.description,
                provider: data.provider,
                category: data.category,
                amount: data.amount.toString(),
                currency: data.currency,
                billingCycle: data.billingCycle,
                nextRenewalDate: data.nextRenewalDate,
                startDate: data.startDate,
                paymentMethod: data.paymentMethod,
                reminderDays: data.reminderDays,
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
        const data = subscriptionSchema.parse(body);

        const [updated] = await db
            .update(subscriptions)
            .set({
                name: data.name,
                description: data.description,
                provider: data.provider,
                category: data.category,
                amount: data.amount.toString(),
                currency: data.currency,
                billingCycle: data.billingCycle,
                nextRenewalDate: data.nextRenewalDate,
                startDate: data.startDate,
                paymentMethod: data.paymentMethod,
                reminderDays: data.reminderDays,
                updatedAt: new Date(),
            })
            .where(eq(subscriptions.id, id))
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

        await db.delete(subscriptions).where(eq(subscriptions.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
