import { NextRequest } from "next/server";
import { db } from "@/db";
import { habits, habitLogs } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, gte } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const userHabits = await db
        .select()
        .from(habits)
        .where(eq(habits.userId, user.userId));

    // Last 90 days of logs for streak + heatmap.
    const since = new Date();
    since.setDate(since.getDate() - 90);
    const sinceStr = since.toISOString().split("T")[0];

    const logs = await db
        .select()
        .from(habitLogs)
        .where(and(gte(habitLogs.logDate, sinceStr)));

    const logsByHabit = new Map<string, Set<string>>();
    for (const log of logs) {
        if (!logsByHabit.has(log.habitId)) logsByHabit.set(log.habitId, new Set());
        logsByHabit.get(log.habitId)!.add(log.logDate);
    }

    const result = userHabits.map((h) => {
        const dates = logsByHabit.get(h.id) || new Set<string>();
        return {
            id: h.id,
            name: h.name,
            currentStreak: computeStreak(dates),
            longestStreak: computeLongestStreak(dates),
            totalLogs: dates.size,
            last90Days: Array.from(dates).sort(),
        };
    });

    return Response.json(result);
}

function computeStreak(dates: Set<string>): number {
    let streak = 0;
    const d = new Date();
    // If today not logged, start from yesterday.
    const todayStr = toDateStr(d);
    if (!dates.has(todayStr)) {
        d.setDate(d.getDate() - 1);
    }
    while (dates.has(toDateStr(d))) {
        streak++;
        d.setDate(d.getDate() - 1);
    }
    return streak;
}

function computeLongestStreak(dates: Set<string>): number {
    const sorted = Array.from(dates).sort();
    let longest = 0;
    let current = 0;
    let prev: Date | null = null;
    for (const s of sorted) {
        const d = new Date(s + "T00:00:00");
        if (prev && (d.getTime() - prev.getTime()) === 86400000) {
            current++;
        } else {
            current = 1;
        }
        if (current > longest) longest = current;
        prev = d;
    }
    return longest;
}

function toDateStr(d: Date): string {
    return `${d.getFullYear()}-${String(d.getMonth() + 1).padStart(2, "0")}-${String(d.getDate()).padStart(2, "0")}`;
}
