import { NextRequest } from "next/server";
import { db } from "@/db";
import { financeInvestments } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, isNotNull } from "drizzle-orm";

/**
 * Refreshes current prices for the user's investments using Yahoo Finance's
 * public chart API (no API key required for basic quotes).
 */
export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const investments = await db
        .select()
        .from(financeInvestments)
        .where(
            and(
                eq(financeInvestments.userId, user.userId),
                isNotNull(financeInvestments.symbol)
            )
        );

    const updated: string[] = [];
    const failed: string[] = [];

    for (const inv of investments) {
        if (!inv.symbol) continue;
        try {
            const price = await fetchYahooPrice(inv.symbol);
            if (price !== null) {
                await db
                    .update(financeInvestments)
                    .set({ currentPrice: price.toFixed(2), updatedAt: new Date() })
                    .where(eq(financeInvestments.id, inv.id));
                updated.push(inv.symbol);
            } else {
                failed.push(inv.symbol);
            }
        } catch {
            failed.push(inv.symbol);
        }
    }

    return Response.json({ success: true, updated, failed });
}

async function fetchYahooPrice(symbol: string): Promise<number | null> {
    const url = `https://query1.finance.yahoo.com/v8/finance/chart/${encodeURIComponent(symbol)}?interval=1d&range=1d`;
    const res = await fetch(url, {
        headers: { "User-Agent": "Mozilla/5.0" },
        signal: AbortSignal.timeout(8000),
    });
    if (!res.ok) return null;
    const json = await res.json();
    const result = json?.chart?.result?.[0];
    const meta = result?.meta;
    const price = meta?.regularMarketPrice ?? meta?.previousClose;
    return typeof price === "number" ? price : null;
}
