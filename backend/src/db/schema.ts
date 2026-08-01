import { pgTable, uuid, varchar, text, timestamp, decimal, boolean, integer, date, time, jsonb, array, pgEnum } from "drizzle-orm/pg-core";

// Enums
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

// Users
export const users = pgTable("users", {
    id: uuid("id").primaryKey().defaultRandom(),
    email: varchar("email", { length: 255 }).notNull().unique(),
    passwordHash: varchar("password_hash", { length: 255 }).notNull(),
    fullName: varchar("full_name", { length: 255 }),
    avatarUrl: text("avatar_url"),
    timezone: varchar("timezone", { length: 50 }).default("Asia/Jakarta"),
    currency: varchar("currency", { length: 10 }).default("IDR"),
    role: userRoleEnum("role").default("user"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

// Finance
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
    tags: array(varchar("tags", { length: 50 })),
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

// Journal
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
});

export const journalTags = pgTable("journal_tags", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 50 }).notNull(),
    color: varchar("color", { length: 7 }).default("#6366F1"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const journalEntryTags = pgTable("journal_entry_tags", {
    journalId: uuid("journal_id").references(() => journalEntries.id, { onDelete: "cascade" }).notNull(),
    tagId: uuid("tag_id").references(() => journalTags.id, { onDelete: "cascade" }).notNull(),
}, (table) => ({
    pk: { primaryKey: { columns: [table.journalId, table.tagId] } },
}));

// Bug Tracker
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
    tags: array(varchar("tags", { length: 50 })),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
    solvedAt: timestamp("solved_at", { withTimezone: true }),
});

// Job Tracker
export const jobApplications = pgTable("job_applications", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    companyName: varchar("company_name", { length: 255 }).notNull(),
    position: varchar("position", { length: 255 }).notNull(),
    salaryRange: varchar("salary_range", { length: 100 }),
    location: varchar("location", { length: 255 }),
    jobType: varchar("job_type", { length: 50 }),
    status: jobStatusEnum("status").default("applied"),
    applicationDate: date("application_date").notNull(),
    jobDescription: text("job_description"),
    notes: text("notes"),
    url: text("url"),
    isFavorite: boolean("is_favorite").default(false),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

export const jobInterviews = pgTable("job_interviews", {
    id: uuid("id").primaryKey().defaultRandom(),
    jobId: uuid("job_id").references(() => jobApplications.id, { onDelete: "cascade" }).notNull(),
    round: integer("round").default(1),
    interviewType: varchar("interview_type", { length: 50 }).notNull(),
    scheduledAt: timestamp("scheduled_at", { withTimezone: true }),
    durationMinutes: integer("duration_minutes"),
    location: varchar("location", { length: 255 }),
    meetingUrl: text("meeting_url"),
    interviewerName: varchar("interviewer_name", { length: 255 }),
    interviewerEmail: varchar("interviewer_email", { length: 255 }),
    notes: text("notes"),
    status: varchar("status", { length: 20 }).default("scheduled"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

export const jobContacts = pgTable("job_contacts", {
    id: uuid("id").primaryKey().defaultRandom(),
    jobId: uuid("job_id").references(() => jobApplications.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    role: varchar("role", { length: 100 }),
    email: varchar("email", { length: 255 }),
    phone: varchar("phone", { length: 50 }),
    linkedinUrl: text("linkedin_url"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

// Projects
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
    techStack: array(varchar("tech_stack", { length: 50 })),
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
    tags: array(varchar("tags", { length: 50 })),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

// Habits
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
    targetDays: array(integer("target_days")).default([1, 2, 3, 4, 5, 6, 7]),
    reminderTime: time("reminder_time"),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

export const habitLogs = pgTable("habit_logs", {
    id: uuid("id").primaryKey().defaultRandom(),
    habitId: uuid("habit_id").references(() => habits.id, { onDelete: "cascade" }).notNull(),
    logDate: date("log_date").notNull(),
    value: decimal("value", { precision: 10, scale: 2 }).default("1"),
    notes: text("notes"),
    mood: varchar("mood", { length: 20 }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

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
});

// Subscriptions
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
});

export const subscriptionPayments = pgTable("subscription_payments", {
    id: uuid("id").primaryKey().defaultRandom(),
    subscriptionId: uuid("subscription_id").references(() => subscriptions.id, { onDelete: "cascade" }).notNull(),
    amount: decimal("amount", { precision: 15, scale: 2 }).notNull(),
    paymentDate: date("payment_date").notNull(),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

// Inventory
export const inventoryCategories = pgTable("inventory_categories", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 100 }).notNull(),
    description: text("description"),
    icon: varchar("icon", { length: 50 }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
});

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
    photoUrls: array(text("photo_urls")),
    tags: array(varchar("tags", { length: 50 })),
    isActive: boolean("is_active").default(true),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});

// Bookmarks
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
    tags: array(varchar("tags", { length: 50 })),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
});
