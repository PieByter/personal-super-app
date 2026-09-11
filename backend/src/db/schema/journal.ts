import { pgTable, uuid, varchar, text, timestamp, boolean, index } from "drizzle-orm/pg-core";
import { users } from "./users";

export const journalEntries = pgTable("journal_entries", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    title: varchar("title", { length: 255 }).notNull(),
    problem: text("problem"),
    rootCause: text("root_cause"),
    solution: text("solution"),
    conceptLearned: text("concept_learned"),
    codeSnippet: text("code_snippet"),
    language: varchar("language", { length: 50 }),
    projectName: varchar("project_name", { length: 100 }),
    isFavorite: boolean("is_favorite").default(false),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("journal_entries_user_id_idx").on(t.userId),
]);

export const journalTags = pgTable("journal_tags", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 50 }).notNull(),
    color: varchar("color", { length: 7 }).default("#6366F1"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("journal_tags_user_id_idx").on(t.userId),
]);

export const journalEntryTags = pgTable("journal_entry_tags", {
    journalId: uuid("journal_id").references(() => journalEntries.id, { onDelete: "cascade" }).notNull(),
    tagId: uuid("tag_id").references(() => journalTags.id, { onDelete: "cascade" }).notNull(),
}, (table) => ({
    pk: { primaryKey: { columns: [table.journalId, table.tagId] } },
}));