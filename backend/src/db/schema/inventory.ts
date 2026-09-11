import { pgTable, uuid, varchar, text, timestamp, decimal, boolean, date, index } from "drizzle-orm/pg-core";
import { users } from "./users";
import { itemConditionEnum } from "./enums";

export const inventoryCategories = pgTable("inventory_categories", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    description: text("description"),
    icon: varchar("icon", { length: 50 }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("inventory_categories_user_id_idx").on(t.userId),
]);

export const inventoryItems = pgTable("inventory_items", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    categoryId: uuid("category_id").references(() => inventoryCategories.id),
    name: varchar("name", { length: 255 }).notNull(),
    description: text("description"),
    brand: varchar("brand", { length: 100 }),
    model: varchar("model", { length: 100 }),
    serialNumber: varchar("serial_number", { length: 100 }),
    purchaseDate: date("purchase_date"),
    purchasePrice: decimal("purchase_price", { precision: 15, scale: 2 }),
    currentValue: decimal("current_value", { precision: 15, scale: 2 }),
    currency: varchar("currency", { length: 10 }).default("IDR"),
    condition: itemConditionEnum("condition").default("good"),
    location: varchar("location", { length: 100 }),
    warrantyExpiry: date("warranty_expiry"),
    receiptUrl: text("receipt_url"),
    photoUrls: text("photo_urls").array(),
    tags: varchar("tags", { length: 50 }).array(),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("inventory_items_user_id_idx").on(t.userId),
]);