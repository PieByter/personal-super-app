import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeBudgets, financeTransactions, financeCategories } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, gte, lte } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const budgets = await db
        .select()
        .from(financeBudgets)
        .where(and(eq(financeBudgets.userId, user.userId), eq(financeBudgets.isActive, true)));

    const now = new Date();
    const monthStart = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-01`;
    const monthEnd = `${now.getFullYear()}-${String(now.getMonth() + 1).padStart(2, "0")}-31`;

    const transactions = await db
        .select()
        .from(financeTransactions)
        .where(
            and(
                eq(financeTransactions.userId, user.userId),
                eq(financeTransactions.type, "expense"),
                gte(financeTransactions.transactionDate, monthStart),
                lte(financeTransactions.transactionDate, monthEnd)
            )
        );

    const categories = await db
        .select()
        .from(financeCategories)
        .where(eq(financeCategories.userId, user.userId));
    const categoryName = new Map(categories.map((c) => [c.id, c.name]));

    const result = budgets.map((b) => {
        const spent = transactions
            .filter((t) => t.categoryId === b.categoryId)
            .reduce((sum, t) => sum + parseFloat(t.amount), 0);
        const amount = parseFloat(b.amount);
        const utilization = amount > 0 ? Math.round((spent / amount) * 100) : 0;
        const threshold = b.alertThreshold ? parseFloat(b.alertThreshold) : 80;
        return {
            id: b.id,
            categoryId: b.categoryId,
            categoryName: b.categoryId ? categoryName.get(b.categoryId) || null : null,
            amount: b.amount,
            spent: spent.toFixed(2),
            utilization,
            alertThreshold: threshold,
            status: utilization >= 100 ? "exceeded" : utilization >= threshold ? "warning" : "ok",
        };
    });

    return Response.json(result);
}
