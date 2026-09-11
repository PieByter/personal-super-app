import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeBudgets, financeTransactions, financeCategories } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, gte, lte, sql, sum } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const budgets = await db
        .select()
        .from(financeBudgets)
        .where(and(eq(financeBudgets.userId, user.userId), eq(financeBudgets.isActive, true)));

    if (budgets.length === 0) {
        return Response.json([]);
    }

    // Use last day of the month correctly (not hardcoded 31)
    const now = new Date();
    const year = now.getFullYear();
    const month = now.getMonth() + 1;
    const lastDay = new Date(year, month, 0).getDate();
    const monthStart = `${year}-${String(month).padStart(2, "0")}-01`;
    const monthEnd = `${year}-${String(month).padStart(2, "0")}-${String(lastDay).padStart(2, "0")}`;

    // Aggregate spending per category in SQL — no JS-side filtering loop
    const spendingRows = await db
        .select({
            categoryId: financeTransactions.categoryId,
            totalSpent: sum(financeTransactions.amount),
        })
        .from(financeTransactions)
        .where(
            and(
                eq(financeTransactions.userId, user.userId),
                eq(financeTransactions.type, "expense"),
                gte(financeTransactions.transactionDate, monthStart),
                lte(financeTransactions.transactionDate, monthEnd)
            )
        )
        .groupBy(financeTransactions.categoryId);

    // Build a categoryId → spent map
    const spentByCategory = new Map<string | null, number>(
        spendingRows.map((r) => [r.categoryId, parseFloat(r.totalSpent ?? "0")])
    );

    // Fetch category names for the budget categories in a single query
    const budgetCategoryIds = budgets
        .map((b) => b.categoryId)
        .filter((id): id is string => id !== null);

    const categoryNameMap = new Map<string, string>();
    if (budgetCategoryIds.length > 0) {
        const categories = await db
            .select({ id: financeCategories.id, name: financeCategories.name })
            .from(financeCategories)
            .where(
                and(
                    eq(financeCategories.userId, user.userId),
                    sql`${financeCategories.id} = ANY(${sql.raw(`ARRAY['${budgetCategoryIds.join("','")}']::uuid[]`)})`
                )
            );
        for (const c of categories) categoryNameMap.set(c.id, c.name);
    }

    const result = budgets.map((b) => {
        const spent = spentByCategory.get(b.categoryId) ?? 0;
        const amount = parseFloat(b.amount);
        const utilization = amount > 0 ? Math.round((spent / amount) * 100) : 0;
        const threshold = b.alertThreshold ? parseFloat(b.alertThreshold) : 80;
        return {
            id: b.id,
            categoryId: b.categoryId,
            categoryName: b.categoryId ? categoryNameMap.get(b.categoryId) ?? null : null,
            amount: b.amount,
            spent: spent.toFixed(2),
            utilization,
            alertThreshold: threshold,
            status: utilization >= 100 ? "exceeded" : utilization >= threshold ? "warning" : "ok",
        };
    });

    return Response.json(result);
}
