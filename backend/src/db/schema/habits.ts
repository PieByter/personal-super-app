import { pgTable, uuid, varchar, text, timestamp, decimal, boolean, integer, date, time, index } from "drizzle-orm/pg-core";
import { users } from "./users";
import { habitFrequencyEnum } from "./enums";

export const habits = pgTable("habits", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    description: text("description"),
    icon: varchar("icon", { length: 50 }),
    color: varchar("color", { length: 7 }).default("#F59E0B"),
    targetValue: decimal("target_value", { precision: 10, scale: 2 }).default("1"),
    unit: varchar("unit", { length: 50 }),
    frequency: habitFrequencyEnum("frequency").notNull(),
    targetDays: integer("target_days").array().default([1, 2, 3, 4, 5, 6, 7]),
    reminderTime: time("reminder_time"),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("habits_user_id_idx").on(t.userId),
]);

export const habitLogs = pgTable("habit_logs", {
    id: uuid("id").primaryKey().defaultRandom(),
    habitId: uuid("habit_id").references(() => habits.id, { onDelete: "cascade" }).notNull(),
    logDate: date("log_date").notNull(),
    value: decimal("value", { precision: 10, scale: 2 }).default("1"),
    notes: text("notes"),
    mood: varchar("mood", { length: 20 }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("habit_logs_habit_id_idx").on(t.habitId),
    index("habit_logs_habit_date_idx").on(t.habitId, t.logDate),
]);

export const dailyMetrics = pgTable("daily_metrics", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    metricDate: date("metric_date").notNull(),
    sleepHours: decimal("sleep_hours", { precision: 4, scale: 1 }),
    studyHours: decimal("study_hours", { precision: 4, scale: 1 }),
    codingHours: decimal("coding_hours", { precision: 4, scale: 1 }),
    exerciseMinutes: integer("exercise_minutes"),
    readingMinutes: integer("reading_minutes"),
    screenTimeMinutes: integer("screen_time_minutes"),
    deepWorkHours: decimal("deep_work_hours", { precision: 4, scale: 1 }),
    mood: integer("mood"),
    energyLevel: integer("energy_level"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("daily_metrics_user_id_idx").on(t.userId),
    index("daily_metrics_user_date_idx").on(t.userId, t.metricDate),
]);