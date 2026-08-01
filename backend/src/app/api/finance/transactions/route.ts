import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeTransactions, financeCategories } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { transactionSchema } from "@/lib/validation";
import { eq, and, desc, gte, lte } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const { searchParams } = new URL(req.url);
    const type = searchParams.get("type");
    const from = searchParams.get("from");
    const to = searchParams.get("to");
    const categoryId = searchParams.get("categoryId");

    const conditions = [eq(financeTransactions.userId, user.userId)];
    if (type) conditions.push(eq(financeTransactions.type, type));
    if (from) conditions.push(gte(financeTransactions.transactionDate, from));
    if (to) conditions.push(lte(financeTransactions.transactionDate, to));
    if (categoryId) conditions.push(eq(financeTransactions.categoryId, categoryId));

    const transactions = await db
        .select({
            id: financeTransactions.id,
            amount: financeTransactions.amount,
            type: financeTransactions.type,
            description: financeTransactions.description,
            transactionDate: financeTransactions.transactionDate,
            paymentMethod: financeTransactions.paymentMethod,
            tags: financeTransactions.tags,
            createdAt: financeTransactions.createdAt,
            category: {
                id: financeCategories.id,
                name: financeCategories.name,
                color: financeCategories.color,
                icon: financeCategories.icon,
            },
        })
        .from(financeTransactions)
        .leftJoin(financeCategories, eq(financeTransactions.categoryId, financeCategories.id))
        .where(and(...conditions))
        .orderBy(desc(financeTransactions.transactionDate));

    return Response.json({ data: transactions });
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = transactionSchema.parse(body);

        const [transaction] = await db
            .insert(financeTransactions)
            .values({
                userId: user.userId,
                categoryId: data.categoryId,
                amount: data.amount.toString(),
                type: data.type,
                description: data.description,
                transactionDate: data.transactionDate,
                paymentMethod: data.paymentMethod,
                tags: data.tags,
            })
            .returning();

        return Response.json({ data: transaction }, { status: 201 });
    } catch (error) {
        if (error instanceof Error) {
            return Response.json({ error: error.message }, { status: 400 });
        }
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
