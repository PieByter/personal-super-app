import { db } from "@/db";
import { and, eq, inArray, getTableColumns } from "drizzle-orm";
import type { PgTable } from "drizzle-orm/pg-core";

/**
 * Guards child-resource writes: returns true only when `id` exists in `table`
 * and belongs to `userId`. Prevents referencing another user's rows (IDOR).
 */
export async function ownsRecord(table: PgTable, userId: string, id: string): Promise<boolean> {
    const { id: idColumn, userId: userColumn } = getTableColumns(table) as Record<string, never>;
    const rows = await db
        .select({ id: idColumn })
        .from(table)
        .where(and(eq(idColumn, id), eq(userColumn, userId)))
        .limit(1);
    return rows.length > 0;
}

/** Same as `ownsRecord`, for a list of ids (order-insensitive). */
export async function ownsRecords(table: PgTable, userId: string, ids: string[]): Promise<boolean> {
    const unique = [...new Set(ids)];
    if (unique.length === 0) return true;

    const { id: idColumn, userId: userColumn } = getTableColumns(table) as Record<string, never>;
    const rows = await db
        .select({ id: idColumn })
        .from(table)
        .where(and(eq(userColumn, userId), inArray(idColumn, unique)));
    return rows.length === unique.length;
}
