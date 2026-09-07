import { pgEnum } from "drizzle-orm/pg-core";

export const transactionTypeEnum = pgEnum("transaction_type", ["income", "expense"]);
export const frequencyEnum = pgEnum("frequency", ["daily", "weekly", "monthly", "yearly"]);
export const budgetPeriodEnum = pgEnum("budget_period", ["weekly", "monthly", "yearly"]);
export const bugStatusEnum = pgEnum("bug_status", ["open", "in_progress", "solved", "closed"]);
export const bugSeverityEnum = pgEnum("bug_severity", ["low", "medium", "high", "critical"]);
export const jobStatusEnum = pgEnum("job_status", ["applied", "screening", "interview", "technical_test", "offer", "rejected", "withdrawn", "accepted"]);
export const projectStatusEnum = pgEnum("project_status", ["active", "on_hold", "completed", "cancelled"]);
export const taskStatusEnum = pgEnum("task_status", ["todo", "in_progress", "review", "done"]);
export const priorityEnum = pgEnum("priority", ["low", "medium", "high"]);
export const habitFrequencyEnum = pgEnum("habit_frequency", ["daily", "weekly", "monthly"]);
export const itemConditionEnum = pgEnum("item_condition", ["excellent", "good", "fair", "poor", "broken"]);
export const bookmarkStatusEnum = pgEnum("bookmark_status", ["unread", "reading", "completed", "archived"]);
export const billingCycleEnum = pgEnum("billing_cycle", ["weekly", "monthly", "quarterly", "yearly", "lifetime"]);
export const userRoleEnum = pgEnum("user_role", ["user", "admin"]);
export const websiteStatusEnum = pgEnum("website_status", ["active", "inactive", "archived"]);