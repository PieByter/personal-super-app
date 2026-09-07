import { pgTable, uuid, varchar, text, timestamp, boolean, integer } from "drizzle-orm/pg-core";
import { users } from "./users";
import { bookmarkStatusEnum } from "./enums";

export const bookmarkCollections = pgTable("bookmark_collections", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    description: text("description"),
    color: varchar("color", { length: 7 }).default("#EC4899"),
    icon: varchar("icon", { length: 50 }),
    parentId: uuid("parent_id"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const bookmarks = pgTable("bookmarks", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    collectionId: uuid("collection_id").references(() => bookmarkCollections.id),
    title: varchar("title", { length: 255 }).notNull(),
    url: text("url").notNull(),
    description: text("description"),
    notes: text("notes"),
    status: bookmarkStatusEnum("status").default("unread"),
    rating: integer("rating"),
    isFavorite: boolean("is_favorite").default(false),
    tags: varchar("tags", { length: 50 }).array(),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});