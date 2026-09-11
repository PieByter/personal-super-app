import { pgTable, uuid, varchar, text, timestamp, decimal, boolean, integer, date, index } from "drizzle-orm/pg-core";
import { users } from "./users";
import { billingCycleEnum } from "./enums";

export const subscriptions = pgTable("subscriptions", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    description: text("description"),
    provider: varchar("provider", { length: 100 }),
    category: varchar("category", { length: 50 }),
    amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
    currency: varchar("currency", { length: 10 }).default("IDR"),
    billingCycle: billingCycleEnum("billing_cycle").notNull(),
    nextRenewalDate: date("next_renewal_date"),
    startDate: date("start_date"),
    paymentMethod: varchar("payment_method", { length: 100 }),
    isActive: boolean("is_active").default(true),
    reminderDays: integer("reminder_days").default(3),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("subscriptions_user_id_idx").on(t.userId),
    index("subscriptions_renewal_idx").on(t.userId, t.nextRenewalDate),
]);

export const subscriptionPayments = pgTable("subscription_payments", {
    id: uuid("id").primaryKey().defaultRandom(),
    subscriptionId: uuid("subscription_id").references(() => subscriptions.id, { onDelete: "cascade" }).notNull(),
    amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
    paymentDate: date("payment_date").notNull(),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("subscription_payments_subscription_id_idx").on(t.subscriptionId),
]);