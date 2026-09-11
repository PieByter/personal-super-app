import { NextRequest } from "next/server";
import { db } from "@/db";
import {
    users,
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
import { startOfMonth, format, subDays } from "date-fns";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    // Admin dashboard - return system-wide stats
    if (user.role === "admin") {
        const [userCount] = await db.select({ total: count(users.id) }).from(users);
        const [totalTransactions] = await db.select({ total: count(financeTransactions.id) }).from(financeTransactions);
        const [totalProjects] = await db.select({ total: count(projects.id) }).from(projects);
        const [totalTasks] = await db.select({ total: count(projectTasks.id) }).from(projectTasks);
        const [totalHabits] = await db.select({ total: count(habits.id) }).from(habits);
        const [totalJobs] = await db.select({ total: count(jobApplications.id) }).from(jobApplications);
        const [totalBugs] = await db.select({ total: count(bugEntries.id) }).from(bugEntries);
        const [totalSubscriptions] = await db.select({ total: count(subscriptions.id) }).from(subscriptions);

        return Response.json({
            isAdmin: true,
            systemStats: {
                totalUsers: userCount?.total || 0,
                totalTransactions: totalTransactions?.total || 0,
                totalProjects: totalProjects?.total || 0,
                totalTasks: totalTasks?.total || 0,
                totalHabits: totalHabits?.total || 0,
                totalJobs: totalJobs?.total || 0,
                totalBugs: totalBugs?.total || 0,
                totalSubscriptions: totalSubscriptions?.total || 0,
            },
        });
    }

    // Regular user dashboard
    const now = new Date();
    const monthStart = startOfMonth(now);
    const weekAgo = subDays(now, 7);

    // All independent queries run in parallel
    const [
        [incomeRow],
        [expenseRow],
        [projectStats],
        [taskStats],
        habitStats,
        [jobStats],
        [bugStats],
        [subSummary],
    ] = await Promise.all([
        // Income this month
        db
            .select({ total: sum(financeTransactions.amount) })
            .from(financeTransactions)
            .where(
                and(
                    eq(financeTransactions.userId, user.userId),
                    eq(financeTransactions.type, "income"),
                    gte(financeTransactions.transactionDate, format(monthStart, "yyyy-MM-dd"))
                )
            ),

        // Expense this month
        db
            .select({ total: sum(financeTransactions.amount) })
            .from(financeTransactions)
            .where(
                and(
                    eq(financeTransactions.userId, user.userId),
                    eq(financeTransactions.type, "expense"),
                    gte(financeTransactions.transactionDate, format(monthStart, "yyyy-MM-dd"))
                )
            ),

        // Project stats
        db
            .select({
                total: count(projects.id),
                active: count(sql`CASE WHEN ${projects.status} = 'active' THEN 1 END`),
            })
            .from(projects)
            .where(eq(projects.userId, user.userId)),

        // Task stats
        db
            .select({
                total: count(projectTasks.id),
                todo: count(sql`CASE WHEN ${projectTasks.status} = 'todo' THEN 1 END`),
                inProgress: count(sql`CASE WHEN ${projectTasks.status} = 'in_progress' THEN 1 END`),
                done: count(sql`CASE WHEN ${projectTasks.status} = 'done' THEN 1 END`),
            })
            .from(projectTasks)
            .innerJoin(projects, eq(projectTasks.projectId, projects.id))
            .where(eq(projects.userId, user.userId)),

        // Habit stats (last 7 days)
        db
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
            .limit(5),

        // Job stats
        db
            .select({
                total: count(jobApplications.id),
                interview: count(sql`CASE WHEN ${jobApplications.status} = 'interview' THEN 1 END`),
                offer: count(sql`CASE WHEN ${jobApplications.status} = 'offer' THEN 1 END`),
                rejected: count(sql`CASE WHEN ${jobApplications.status} = 'rejected' THEN 1 END`),
            })
            .from(jobApplications)
            .where(eq(jobApplications.userId, user.userId)),

        // Bug stats
        db
            .select({
                total: count(bugEntries.id),
                open: count(sql`CASE WHEN ${bugEntries.status} = 'open' THEN 1 END`),
                solved: count(sql`CASE WHEN ${bugEntries.status} = 'solved' THEN 1 END`),
            })
            .from(bugEntries)
            .where(eq(bugEntries.userId, user.userId)),

        // Subscription monthly cost
        db
            .select({ monthlyCost: sum(subscriptions.amount) })
            .from(subscriptions)
            .where(
                and(
                    eq(subscriptions.userId, user.userId),
                    eq(subscriptions.isActive, true),
                    eq(subscriptions.billingCycle, "monthly")
                )
            ),
    ]);

    return Response.json({
        isAdmin: false,
        finance: {
            monthIncome: incomeRow?.total || "0",
            monthExpense: expenseRow?.total || "0",
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
