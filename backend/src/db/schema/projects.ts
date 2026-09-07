import { pgTable, uuid, varchar, text, timestamp, decimal, boolean, date } from "drizzle-orm/pg-core";
import { users } from "./users";
import { projectStatusEnum, taskStatusEnum, priorityEnum } from "./enums";

export const projects = pgTable("projects", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    description: text("description"),
    goal: text("goal"),
    status: projectStatusEnum("status").default("active"),
    priority: priorityEnum("priority").default("medium"),
    progress: decimal("progress", { precision: 5, scale: 2 }).default("0"),
    startDate: date("start_date"),
    targetDate: date("target_date"),
    completedDate: date("completed_date"),
    techStack: varchar("tech_stack", { length: 50 }).array(),
    gitRepository: text("git_repository"),
    documentationUrl: text("documentation_url"),
    color: varchar("color", { length: 7 }).default("#8B5CF6"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

export const projectMilestones = pgTable("project_milestones", {
    id: uuid("id").primaryKey().defaultRandom(),
    projectId: uuid("project_id").references(() => projects.id, { onDelete: "cascade" }).notNull(),
    title: varchar("title", { length: 255 }).notNull(),
    description: text("description"),
    dueDate: date("due_date"),
    completedAt: timestamp("completed_at", { withTimezone: true }),
    isCompleted: boolean("is_completed").default(false),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const projectTasks = pgTable("project_tasks", {
    id: uuid("id").primaryKey().defaultRandom(),
    projectId: uuid("project_id").references(() => projects.id, { onDelete: "cascade" }).notNull(),
    milestoneId: uuid("milestone_id").references(() => projectMilestones.id),
    title: varchar("title", { length: 255 }).notNull(),
    description: text("description"),
    status: taskStatusEnum("status").default("todo"),
    priority: priorityEnum("priority").default("medium"),
    dueDate: date("due_date"),
    completedAt: timestamp("completed_at", { withTimezone: true }),
    tags: varchar("tags", { length: 50 }).array(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});