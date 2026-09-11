import { pgTable, uuid, varchar, text, timestamp, index } from "drizzle-orm/pg-core";
import { users } from "./users";
import { bugStatusEnum, bugSeverityEnum } from "./enums";

export const bugEntries = pgTable("bug_entries", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    bugCode: varchar("bug_code", { length: 20 }).unique(),
    title: varchar("title", { length: 255 }).notNull(),
    projectName: varchar("project_name", { length: 100 }),
    technology: varchar("technology", { length: 100 }),
    errorMessage: text("error_message"),
    errorType: varchar("error_type", { length: 100 }),
    cause: text("cause"),
    solution: text("solution"),
    status: bugStatusEnum("status").default("open"),
    severity: bugSeverityEnum("severity").default("medium"),
    tags: varchar("tags", { length: 50 }).array(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
    solvedAt: timestamp("solved_at", { withTimezone: true }),
}, (t) => [
    index("bug_entries_user_id_idx").on(t.userId),
    index("bug_entries_status_idx").on(t.userId, t.status),
]);