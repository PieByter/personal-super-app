import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeRecurringRules, financeTransactions } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { getPagination, paginateResponse } from "@/lib/pagination";
import { eq, and, desc, count, lte } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const recurringSchema = z.object({
    categoryId: z.string().uuid().optional().nullable(),
    amount: z.string().or(z.number()),
    type: z.enum(["income", "expense"]),
    frequency: z.enum(["daily", "weekly", "monthly", "yearly"]),
    interval: z.number().int().min(1).default(1),
    startDate: z.string(),
    endDate: z.string().optional().nullable(),
    description: z.string().optional(),
    nextExecution: z.string().optional(),
    isActive: z.boolean().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const pagination = getPagination(req);
    const baseQuery = db
        .select()
        .from(financeRecurringRules)
        .where(eq(financeRecurringRules.userId, user.userId))
        .orderBy(desc(financeRecurringRules.createdAt));

    if (pagination.enabled) {
        const [totalRow] = await db
            .select({ value: count() })
            .from(financeRecurringRules)
            .where(eq(financeRecurringRules.userId, user.userId));
        const total = totalRow?.value ?? 0;
        const rows = await baseQuery.limit(pagination.pageSize).offset(pagination.offset);
        return Response.json(paginateResponse(rows, total, pagination));
    }

    const rows = await baseQuery;
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = recurringSchema.parse(body);

        const [row] = await db
            .insert(financeRecurringRules)
            .values({
                userId: user.userId,
                categoryId: data.categoryId,
                amount: data.amount.toString(),
                type: data.type,
                frequency: data.frequency,
                interval: data.interval,
                startDate: data.startDate,
                endDate: data.endDate,
                description: data.description,
                nextExecution: data.nextExecution || data.startDate,
                isActive: data.isActive,
            })
            .returning();

        return Response.json(row, { status: 201 });
    } catch (e) {
        return apiError(e);
    }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = recurringSchema.parse(body);

        const [updated] = await db
            .update(financeRecurringRules)
            .set({
                categoryId: data.categoryId,
                amount: data.amount.toString(),
                type: data.type,
                frequency: data.frequency,
                interval: data.interval,
                startDate: data.startDate,
                endDate: data.endDate,
                description: data.description,
                nextExecution: data.nextExecution,
                isActive: data.isActive,
            })
            .where(and(eq(financeRecurringRules.id, id), eq(financeRecurringRules.userId, user.userId)))
            .returning();

        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) {
        return apiError(e);
    }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        await db
            .delete(financeRecurringRules)
            .where(and(eq(financeRecurringRules.id, id), eq(financeRecurringRules.userId, user.userId)));
        return Response.json({ success: true });
    } catch (e) {
        return apiError(e);
    }
}

/**
 * Processes all due recurring rules and generates transactions.
 * Pass a userId to process only that user; pass null to process everyone
 * (used by the scheduled cron).
 */
export async function processDueRules(userId: string | null) {
    const now = new Date();
    const today = now.toISOString().split("T")[0];

    const conditions = [
        eq(financeRecurringRules.isActive, true),
        lte(financeRecurringRules.nextExecution, today),
    ];
    if (userId) conditions.push(eq(financeRecurringRules.userId, userId));

    const dueRules = await db
        .select()
        .from(financeRecurringRules)
        .where(and(...conditions));

    const created: typeof financeTransactions.$inferSelect[] = [];

    for (const rule of dueRules) {
        // Skip if the rule has ended.
        if (rule.endDate && rule.nextExecution > rule.endDate) {
            await db
                .update(financeRecurringRules)
                .set({ isActive: false })
                .where(eq(financeRecurringRules.id, rule.id));
            continue;
        }

        const [tx] = await db
            .insert(financeTransactions)
            .values({
                userId: rule.userId,
                categoryId: rule.categoryId,
                amount: rule.amount,
                type: rule.type,
                description: rule.description || `Recurring ${rule.frequency}`,
                transactionDate: rule.nextExecution,
                isRecurring: true,
                recurringRuleId: rule.id,
            })
            .returning();
        created.push(tx);

        // Advance next execution.
        const next = advanceDate(rule.nextExecution, rule.frequency, rule.interval ?? 1);
        const nextExecution = rule.endDate && next > rule.endDate ? rule.endDate : next;
        await db
            .update(financeRecurringRules)
            .set({ nextExecution })
            .where(eq(financeRecurringRules.id, rule.id));
    }

    return created;
}

function advanceDate(dateStr: string, frequency: string, interval: number): string {
    const d = new Date(dateStr + "T00:00:00");
    switch (frequency) {
        case "daily":
            d.setDate(d.getDate() + interval);
            break;
        case "weekly":
            d.setDate(d.getDate() + 7 * interval);
            break;
        case "monthly":
            d.setMonth(d.getMonth() + interval);
            break;
        case "yearly":
            d.setFullYear(d.getFullYear() + interval);
            break;
    }
    return d.toISOString().split("T")[0];
}
