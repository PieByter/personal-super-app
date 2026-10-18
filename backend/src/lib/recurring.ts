import { db } from "@/db";
import { financeRecurringRules, financeTransactions } from "@/db/schema";
import { eq, and, lte } from "drizzle-orm";

/**
 * Processes all due recurring rules and generates transactions.
 * Pass a userId to process only that user; pass null to process everyone
 * (used by the scheduled cron).
 */
export async function processDueRules(userId: string | null) {
    const today = new Date().toISOString().split("T")[0];

    const conditions = [
        eq(financeRecurringRules.isActive, true),
        lte(financeRecurringRules.nextExecution, today),
    ];
    if (userId) conditions.push(eq(financeRecurringRules.userId, userId));

    const dueRules = await db
        .select()
        .from(financeRecurringRules)
        .where(and(...conditions));

    const created: (typeof financeTransactions.$inferSelect)[] = [];

    for (const rule of dueRules) {
        // Rule already past its end date: deactivate without generating.
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

        // Advance next execution, deactivating the rule once it runs past endDate.
        const next = advanceDate(rule.nextExecution, rule.frequency, rule.interval ?? 1);
        if (rule.endDate && next > rule.endDate) {
            await db
                .update(financeRecurringRules)
                .set({ isActive: false })
                .where(eq(financeRecurringRules.id, rule.id));
        } else {
            await db
                .update(financeRecurringRules)
                .set({ nextExecution: next })
                .where(eq(financeRecurringRules.id, rule.id));
        }
    }

    return created;
}

function advanceDate(dateStr: string, frequency: string, interval: number): string {
    // Date-only strings: do the arithmetic in UTC so the result does not
    // depend on the server timezone.
    const d = new Date(`${dateStr}T00:00:00Z`);
    switch (frequency) {
        case "daily":
            d.setUTCDate(d.getUTCDate() + interval);
            break;
        case "weekly":
            d.setUTCDate(d.getUTCDate() + 7 * interval);
            break;
        case "monthly":
            d.setUTCMonth(d.getUTCMonth() + interval);
            break;
        case "yearly":
            d.setUTCFullYear(d.getUTCFullYear() + interval);
            break;
    }
    return d.toISOString().split("T")[0];
}
