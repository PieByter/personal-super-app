import { NextRequest } from "next/server";
import { db } from "@/db";
import { habits, habitLogs, users } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, gte, inArray } from "drizzle-orm";
import { addDays, todayInTimeZone } from "@/lib/user-time";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const userHabits = await db
        .select()
        .from(habits)
        .where(eq(habits.userId, user.userId));

    const [profile] = await db
        .select({ timezone: users.timezone })
        .from(users)
        .where(eq(users.id, user.userId))
        .limit(1);

    // Day boundaries follow the user's timezone, not the server's.
    const today = todayInTimeZone(profile?.timezone);

    // Last 90 days of logs for streak + heatmap.
    const sinceStr = addDays(today, -90);

    const habitIds = userHabits.map((h) => h.id);
    const logs = habitIds.length === 0
        ? []
        : await db
            .select()
            .from(habitLogs)
            .where(and(inArray(habitLogs.habitId, habitIds), gte(habitLogs.logDate, sinceStr)));

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
            currentStreak: computeStreak(dates, today),
            longestStreak: computeLongestStreak(dates),
            totalLogs: dates.size,
            last90Days: Array.from(dates).sort(),
        };
    });

    return Response.json(result);
}

/** Consecutive days up to `today`; a missing today does not break the streak yet. */
function computeStreak(dates: Set<string>, today: string): number {
    let streak = 0;
    let day = dates.has(today) ? today : addDays(today, -1);
    while (dates.has(day)) {
        streak++;
        day = addDays(day, -1);
    }
    return streak;
}

function computeLongestStreak(dates: Set<string>): number {
    let longest = 0;
    let current = 0;
    let previous: string | null = null;
    for (const day of Array.from(dates).sort()) {
        current = previous && addDays(previous, 1) === day ? current + 1 : 1;
        if (current > longest) longest = current;
        previous = day;
    }
    return longest;
}
