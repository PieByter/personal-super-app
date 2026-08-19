import { NextRequest } from "next/server";
import { parse } from "csv-parse/sync";
import { db } from "@/db";
import { financeTransactions, financeCategories } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const importSchema = z.object({
    csv: z.string().min(1),
    // Optional column mapping. Defaults to a common bank statement layout.
    dateColumn: z.string().default("date"),
    descriptionColumn: z.string().default("description"),
    amountColumn: z.string().default("amount"),
    typeColumn: z.string().optional(),
});

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = importSchema.parse(body);

        const records = parse(data.csv, {
            columns: true,
            skip_empty_lines: true,
            trim: true,
        }) as Record<string, string>[];

        if (records.length === 0) {
            return Response.json({ error: "No rows found in CSV" }, { status: 400 });
        }

        // Load the user's categories to map by name.
        const categories = await db
            .select()
            .from(financeCategories)
            .where(eq(financeCategories.userId, user.userId));
        const categoryByName = new Map(
            categories.map((c) => [c.name.toLowerCase(), c])
        );

        let created = 0;
        let skipped = 0;
        const errors: string[] = [];

        for (let i = 0; i < records.length; i++) {
            const row = records[i];
            const date = row[data.dateColumn!]?.trim();
            const description = row[data.descriptionColumn!]?.trim();
            const amountRaw = row[data.amountColumn!]?.trim();
            const typeRaw = data.typeColumn ? row[data.typeColumn]?.trim() : undefined;

            if (!date || !amountRaw) {
                skipped++;
                continue;
            }

            const amount = parseAmount(amountRaw);
            if (amount === null) {
                errors.push(`Row ${i + 2}: invalid amount "${amountRaw}"`);
                skipped++;
                continue;
            }

            // Determine type: explicit column, sign of amount, or default expense.
            let type: "income" | "expense";
            if (typeRaw) {
                const t = typeRaw.toLowerCase();
                type = t.includes("income") || t.includes("credit") || t.includes("masuk")
                    ? "income"
                    : "expense";
            } else {
                type = amount >= 0 ? "income" : "expense";
            }

            const absAmount = Math.abs(amount).toFixed(2);

            // Map category by description keyword (optional, best-effort).
            let categoryId: string | null = null;
            if (description) {
                const lower = description.toLowerCase();
                categoryByName.forEach((cat, name) => {
                    if (categoryId === null && lower.includes(name)) {
                        categoryId = cat.id;
                    }
                });
            }

            await db.insert(financeTransactions).values({
                userId: user.userId,
                categoryId,
                amount: absAmount,
                type,
                description: description || "Imported transaction",
                transactionDate: normalizeDate(date),
            });
            created++;
        }

        return Response.json({
            success: true,
            created,
            skipped,
            errors: errors.slice(0, 20),
        });
    } catch (e) {
        return apiError(e);
    }
}

function parseAmount(raw: string): number | null {
    // Handle "1.234,56" (IDR) and "1234.56" and "-1,234.56"
    let s = raw.trim().replace(/[Rp\s]/gi, "");
    if (s.includes(",") && s.includes(".")) {
        // Determine which is the decimal separator.
        const lastComma = s.lastIndexOf(",");
        const lastDot = s.lastIndexOf(".");
        if (lastComma > lastDot) {
            // "1.234,56" → decimal is comma
            s = s.replace(/\./g, "").replace(",", ".");
        } else {
            // "1,234.56" → decimal is dot
            s = s.replace(/,/g, "");
        }
    } else if (s.includes(",")) {
        s = s.replace(",", ".");
    }
    const n = Number(s);
    return Number.isFinite(n) ? n : null;
}

function normalizeDate(raw: string): string {
    // Accepts YYYY-MM-DD, DD/MM/YYYY, DD-MM-YYYY
    const trimmed = raw.trim();
    if (/^\d{4}-\d{2}-\d{2}$/.test(trimmed)) return trimmed;
    const m = trimmed.match(/^(\d{1,2})[\/\-](\d{1,2})[\/\-](\d{4})$/);
    if (m) {
        return `${m[3]}-${m[2].padStart(2, "0")}-${m[1].padStart(2, "0")}`;
    }
    return trimmed;
}
