import { pgTable, uuid, varchar, text, timestamp, decimal, boolean, integer, date } from "drizzle-orm/pg-core";
import { users } from "./users";
import { transactionTypeEnum, frequencyEnum, budgetPeriodEnum } from "./enums";

export const financeCategories = pgTable("finance_categories", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    type: transactionTypeEnum("type").notNull(),
    color: varchar("color", { length: 7 }).default("#3B82F6"),
    icon: varchar("icon", { length: 50 }),
    parentId: uuid("parent_id"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const financeTransactions = pgTable("finance_transactions", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    categoryId: uuid("category_id").references(() => financeCategories.id),
    amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
    type: transactionTypeEnum("type").notNull(),
    description: text("description"),
    transactionDate: date("transaction_date").notNull(),
    paymentMethod: varchar("payment_method", { length: 50 }),
    isRecurring: boolean("is_recurring").default(false),
    recurringRuleId: uuid("recurring_rule_id"),
    tags: varchar("tags", { length: 50 }).array(),
    attachmentUrl: text("attachment_url"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

export const financeRecurringRules = pgTable("finance_recurring_rules", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    categoryId: uuid("category_id").references(() => financeCategories.id),
    amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
    type: transactionTypeEnum("type").notNull(),
    frequency: frequencyEnum("frequency").notNull(),
    interval: integer("interval").default(1),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    description: text("description"),
    nextExecution: date("next_execution").notNull(),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const financeBudgets = pgTable("finance_budgets", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    categoryId: uuid("category_id").references(() => financeCategories.id),
    amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
    period: budgetPeriodEnum("period").notNull(),
    startDate: date("start_date").notNull(),
    endDate: date("end_date"),
    alertThreshold: decimal("alert_threshold", { precision: 5, scale: 2 }).default("80.00"),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const financeSavingGoals = pgTable("finance_saving_goals", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    targetAmount: decimal("target_amount", { precision: 15, scale: 2 }).notNull(),
    currentAmount: decimal("current_amount", { precision: 15, scale: 2 }).default("0"),
    deadline: date("deadline"),
    color: varchar("color", { length: 7 }).default("#10B981"),
    icon: varchar("icon", { length: 50 }),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

export const financeInvestments = pgTable("finance_investments", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    type: varchar("type", { length: 50 }).notNull(),
    symbol: varchar("symbol", { length: 20 }),
    quantity: decimal("quantity", { precision: 15, scale: 6 }).notNull(),
    purchasePrice: decimal("purchase_price", { precision: 15, scale: 2 }).notNull(),
    currentPrice: decimal("current_price", { precision: 15, scale: 2 }),
    purchaseDate: date("purchase_date").notNull(),
    broker: varchar("broker", { length: 100 }),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});