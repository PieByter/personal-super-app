import { NextRequest } from "next/server";
import { db } from "@/db";
import {
    users,
    financeCategories,
    financeTransactions,
    financeBudgets,
    financeSavingGoals,
    financeInvestments,
    journalEntries,
    journalTags,
    bugEntries,
    jobApplications,
    jobInterviews,
    jobContacts,
    projects,
    projectMilestones,
    projectTasks,
    habits,
    habitLogs,
    dailyMetrics,
    subscriptions,
    subscriptionPayments,
    inventoryCategories,
    inventoryItems,
    bookmarkCollections,
    bookmarks,
} from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const format = new URL(req.url).searchParams.get("format") || "json";

    const [profile] = await db
        .select({
            id: users.id,
            email: users.email,
            fullName: users.fullName,
            timezone: users.timezone,
            currency: users.currency,
            role: users.role,
            createdAt: users.createdAt,
        })
        .from(users)
        .where(eq(users.id, user.userId))
        .limit(1);

    const [financeCategoriesRows, financeTransactionsRows, financeBudgetsRows, financeSavingGoalsRows, financeInvestmentsRows] = await Promise.all([
        db.select().from(financeCategories).where(eq(financeCategories.userId, user.userId)),
        db.select().from(financeTransactions).where(eq(financeTransactions.userId, user.userId)),
        db.select().from(financeBudgets).where(eq(financeBudgets.userId, user.userId)),
        db.select().from(financeSavingGoals).where(eq(financeSavingGoals.userId, user.userId)),
        db.select().from(financeInvestments).where(eq(financeInvestments.userId, user.userId)),
    ]);

    const [journalEntriesRows, journalTagsRows, bugEntriesRows] = await Promise.all([
        db.select().from(journalEntries).where(eq(journalEntries.userId, user.userId)),
        db.select().from(journalTags).where(eq(journalTags.userId, user.userId)),
        db.select().from(bugEntries).where(eq(bugEntries.userId, user.userId)),
    ]);

    const [jobApplicationsRows, jobInterviewsRows, jobContactsRows] = await Promise.all([
        db.select().from(jobApplications).where(eq(jobApplications.userId, user.userId)),
        db.select().from(jobInterviews),
        db.select().from(jobContacts),
    ]);

    const [projectsRows, projectMilestonesRows, projectTasksRows] = await Promise.all([
        db.select().from(projects).where(eq(projects.userId, user.userId)),
        db.select().from(projectMilestones),
        db.select().from(projectTasks),
    ]);

    const [habitsRows, habitLogsRows, dailyMetricsRows] = await Promise.all([
        db.select().from(habits).where(eq(habits.userId, user.userId)),
        db.select().from(habitLogs),
        db.select().from(dailyMetrics).where(eq(dailyMetrics.userId, user.userId)),
    ]);

    const [subscriptionsRows, subscriptionPaymentsRows] = await Promise.all([
        db.select().from(subscriptions).where(eq(subscriptions.userId, user.userId)),
        db.select().from(subscriptionPayments),
    ]);

    const [inventoryCategoriesRows, inventoryItemsRows] = await Promise.all([
        db.select().from(inventoryCategories).where(eq(inventoryCategories.userId, user.userId)),
        db.select().from(inventoryItems).where(eq(inventoryItems.userId, user.userId)),
    ]);

    const [bookmarkCollectionsRows, bookmarksRows] = await Promise.all([
        db.select().from(bookmarkCollections).where(eq(bookmarkCollections.userId, user.userId)),
        db.select().from(bookmarks).where(eq(bookmarks.userId, user.userId)),
    ]);

    const data = {
        exportedAt: new Date().toISOString(),
        profile,
        finance: {
            categories: financeCategoriesRows,
            transactions: financeTransactionsRows,
            budgets: financeBudgetsRows,
            savingGoals: financeSavingGoalsRows,
            investments: financeInvestmentsRows,
        },
        journal: {
            entries: journalEntriesRows,
            tags: journalTagsRows,
        },
        bugs: bugEntriesRows,
        jobs: {
            applications: jobApplicationsRows,
            interviews: jobInterviewsRows,
            contacts: jobContactsRows,
        },
        projects: {
            projects: projectsRows,
            milestones: projectMilestonesRows,
            tasks: projectTasksRows,
        },
        habits: {
            habits: habitsRows,
            logs: habitLogsRows,
            dailyMetrics: dailyMetricsRows,
        },
        subscriptions: {
            subscriptions: subscriptionsRows,
            payments: subscriptionPaymentsRows,
        },
        inventory: {
            categories: inventoryCategoriesRows,
            items: inventoryItemsRows,
        },
        bookmarks: {
            collections: bookmarkCollectionsRows,
            bookmarks: bookmarksRows,
        },
    };

    if (format === "csv") {
        return exportCsv(data);
    }

    return Response.json(data, {
        headers: {
            "Content-Disposition": 'attachment; filename="personal-super-app-export.json"',
        },
    });
}

function exportCsv(data: Record<string, unknown>) {
    const lines: string[] = [];
    const flatten = (prefix: string, value: unknown): void => {
        if (value === null || value === undefined) return;
        if (Array.isArray(value)) {
            if (value.length === 0) return;
            // Use the first element's keys as the header.
            const first = value[0];
            if (typeof first === "object" && first !== null) {
                const keys = Object.keys(first as Record<string, unknown>);
                lines.push(`${prefix},${keys.join(",")}`);
                for (const item of value) {
                    const row = keys.map((k) => {
                        const v = (item as Record<string, unknown>)[k];
                        return v === null || v === undefined ? "" : String(v).replace(/,/g, ";");
                    });
                    lines.push(`${prefix},${row.join(",")}`);
                }
            }
            return;
        }
        if (typeof value === "object") {
            for (const [k, v] of Object.entries(value as Record<string, unknown>)) {
                flatten(prefix ? `${prefix}.${k}` : k, v);
            }
        }
    };

    flatten("", data);
    const csv = lines.join("\n");
    return new Response(csv, {
        headers: {
            "Content-Type": "text/csv; charset=utf-8",
            "Content-Disposition": 'attachment; filename="personal-super-app-export.csv"',
        },
    });
}
