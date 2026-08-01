import { NextRequest } from "next/server";
import { db } from "@/db";
import {
    financeTransactions,
    projects,
    projectTasks,
    habits,
    habitLogs,
    jobApplications,
    bugEntries,
    subscriptions,
} from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, gte, sql, count, sum } from "drizzle-orm";
import { startOfMonth, endOfMonth, format, subDays } from "date-fns";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const now = new Date();
    const monthStart = startOfMonth(now);
    const monthEnd = endOfMonth(now);
    const weekAgo = subDays(now, 7);

    // Finance summary
    const [financeSummary] = await db
        .select({
            totalIncome: sum(financeTransactions.amount),
            totalExpense: sum(financeTransactions.amount),
        })
        .from(financeTransactions)
        .where(
            and(
                eq(financeTransactions.userId, user.userId),
                gte(financeTransactions.transactionDate, format(monthStart, "yyyy-MM-dd"))
            )
        );

    // Project stats
    const [projectStats] = await db
        .select({
            total: count(projects.id),
            active: count(sql`CASE WHEN ${projects.status} = 'active' THEN 1 END`),
        })
        .from(projects)
        .where(eq(projects.userId, user.userId));

    // Task stats
    const [taskStats] = await db
        .select({
            total: count(projectTasks.id),
            todo: count(sql`CASE WHEN ${projectTasks.status} = 'todo' THEN 1 END`),
            inProgress: count(sql`CASE WHEN ${projectTasks.status} = 'in_progress' THEN 1 END`),
            done: count(sql`CASE WHEN ${projectTasks.status} = 'done' THEN 1 END`),
        })
        .from(projectTasks)
        .innerJoin(projects, eq(projectTasks.projectId, projects.id))
        .where(eq(projects.userId, user.userId));

    // Habit stats (last 7 days)
    const habitStats = await db
        .select({
            habitId: habits.id,
            habitName: habits.name,
            completedDays: count(habitLogs.id),
        })
        .from(habits)
        .leftJoin(habitLogs, eq(habits.id, habitLogs.habitId))
        .where(
            and(
                eq(habits.userId, user.userId),
                gte(habitLogs.logDate, format(weekAgo, "yyyy-MM-dd"))
            )
        )
        .groupBy(habits.id, habits.name)
        .limit(5);

    // Job stats
    const [jobStats] = await db
        .select({
            total: count(jobApplications.id),
            interview: count(sql`CASE WHEN ${jobApplications.status} = 'interview' THEN 1 END`),
            offer: count(sql`CASE WHEN ${jobApplications.status} = 'offer' THEN 1 END`),
            rejected: count(sql`CASE WHEN ${jobApplications.status} = 'rejected' THEN 1 END`),
        })
        .from(jobApplications)
        .where(eq(jobApplications.userId, user.userId));

    // Bug stats
    const [bugStats] = await db
        .select({
            total: count(bugEntries.id),
            open: count(sql`CASE WHEN ${bugEntries.status} = 'open' THEN 1 END`),
            solved: count(sql`CASE WHEN ${bugEntries.status} = 'solved' THEN 1 END`),
        })
        .from(bugEntries)
        .where(eq(bugEntries.userId, user.userId));

    // Subscription monthly cost
    const [subSummary] = await db
        .select({
            monthlyCost: sum(subscriptions.amount),
        })
        .from(subscriptions)
        .where(
            and(
                eq(subscriptions.userId, user.userId),
                eq(subscriptions.isActive, true),
                eq(subscriptions.billingCycle, "monthly")
            )
        );

    return Response.json({
        finance: {
            monthIncome: financeSummary?.totalIncome || "0",
            monthExpense: financeSummary?.totalExpense || "0",
        },
        projects: projectStats,
        tasks: taskStats,
        habits: habitStats,
        jobs: jobStats,
        bugs: bugStats,
        subscriptions: {
            monthlyCost: subSummary?.monthlyCost || "0",
        },
    });
}
