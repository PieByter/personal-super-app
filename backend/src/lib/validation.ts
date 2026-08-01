import { z } from "zod";

// Auth
export const loginSchema = z.object({
    email: z.string().email(),
    password: z.string().min(6),
});

export const registerSchema = z.object({
    email: z.string().email(),
    password: z.string().min(6),
    fullName: z.string().min(2).optional(),
});

// Finance
export const transactionSchema = z.object({
    categoryId: z.string().uuid().optional(),
    amount: z.string().or(z.number()),
    type: z.enum(["income", "expense"]),
    description: z.string().optional(),
    transactionDate: z.string(),
    paymentMethod: z.string().optional(),
    tags: z.array(z.string()).optional(),
});

export const categorySchema = z.object({
    name: z.string().min(1),
    type: z.enum(["income", "expense"]),
    color: z.string().optional(),
    icon: z.string().optional(),
    parentId: z.string().uuid().optional(),
});

// Journal
export const journalEntrySchema = z.object({
    title: z.string().min(1),
    problem: z.string().optional(),
    rootCause: z.string().optional(),
    solution: z.string().optional(),
    conceptLearned: z.string().optional(),
    codeSnippet: z.string().optional(),
    language: z.string().optional(),
    projectName: z.string().optional(),
    tagIds: z.array(z.string().uuid()).optional(),
});

// Bug
export const bugEntrySchema = z.object({
    title: z.string().min(1),
    projectName: z.string().optional(),
    technology: z.string().optional(),
    errorMessage: z.string().optional(),
    errorType: z.string().optional(),
    cause: z.string().optional(),
    solution: z.string().optional(),
    severity: z.enum(["low", "medium", "high", "critical"]).optional(),
    tags: z.array(z.string()).optional(),
});

// Job
export const jobApplicationSchema = z.object({
    companyName: z.string().min(1),
    position: z.string().min(1),
    salaryRange: z.string().optional(),
    location: z.string().optional(),
    jobType: z.string().optional(),
    status: z.enum(["applied", "screening", "interview", "technical_test", "offer", "rejected", "withdrawn", "accepted"]).optional(),
    applicationDate: z.string(),
    jobDescription: z.string().optional(),
    notes: z.string().optional(),
    url: z.string().url().optional(),
});

// Project
export const projectSchema = z.object({
    name: z.string().min(1),
    description: z.string().optional(),
    goal: z.string().optional(),
    priority: z.enum(["low", "medium", "high"]).optional(),
    startDate: z.string().optional(),
    targetDate: z.string().optional(),
    techStack: z.array(z.string()).optional(),
    gitRepository: z.string().optional(),
    color: z.string().optional(),
});

export const projectTaskSchema = z.object({
    projectId: z.string().uuid(),
    milestoneId: z.string().uuid().optional(),
    title: z.string().min(1),
    description: z.string().optional(),
    status: z.enum(["todo", "in_progress", "review", "done"]).optional(),
    priority: z.enum(["low", "medium", "high"]).optional(),
    dueDate: z.string().optional(),
    tags: z.array(z.string()).optional(),
});

// Habit
export const habitSchema = z.object({
    name: z.string().min(1),
    description: z.string().optional(),
    icon: z.string().optional(),
    color: z.string().optional(),
    targetValue: z.number().or(z.string()).optional(),
    unit: z.string().optional(),
    frequency: z.enum(["daily", "weekly", "monthly"]),
    targetDays: z.array(z.number()).optional(),
    reminderTime: z.string().optional(),
});

export const habitLogSchema = z.object({
    habitId: z.string().uuid(),
    logDate: z.string(),
    value: z.number().or(z.string()).optional(),
    notes: z.string().optional(),
    mood: z.string().optional(),
});

export const dailyMetricSchema = z.object({
    metricDate: z.string(),
    sleepHours: z.number().optional(),
    studyHours: z.number().optional(),
    codingHours: z.number().optional(),
    exerciseMinutes: z.number().optional(),
    readingMinutes: z.number().optional(),
    screenTimeMinutes: z.number().optional(),
    deepWorkHours: z.number().optional(),
    mood: z.number().min(1).max(10).optional(),
    energyLevel: z.number().min(1).max(10).optional(),
    notes: z.string().optional(),
});

// Subscription
export const subscriptionSchema = z.object({
    name: z.string().min(1),
    description: z.string().optional(),
    provider: z.string().optional(),
    category: z.string().optional(),
    amount: z.string().or(z.number()),
    currency: z.string().optional(),
    billingCycle: z.enum(["weekly", "monthly", "quarterly", "yearly", "lifetime"]),
    nextRenewalDate: z.string().optional(),
    startDate: z.string().optional(),
    paymentMethod: z.string().optional(),
    reminderDays: z.number().optional(),
});

// Inventory
export const inventoryItemSchema = z.object({
    categoryId: z.string().uuid().optional(),
    name: z.string().min(1),
    description: z.string().optional(),
    brand: z.string().optional(),
    model: z.string().optional(),
    serialNumber: z.string().optional(),
    purchaseDate: z.string().optional(),
    purchasePrice: z.number().or(z.string()).optional(),
    currentValue: z.number().or(z.string()).optional(),
    condition: z.enum(["excellent", "good", "fair", "poor", "broken"]).optional(),
    location: z.string().optional(),
    warrantyExpiry: z.string().optional(),
    tags: z.array(z.string()).optional(),
});

// Bookmark
export const bookmarkSchema = z.object({
    collectionId: z.string().uuid().optional(),
    title: z.string().min(1),
    url: z.string().url(),
    description: z.string().optional(),
    notes: z.string().optional(),
    status: z.enum(["unread", "reading", "completed", "archived"]).optional(),
    rating: z.number().min(1).max(5).optional(),
    tags: z.array(z.string()).optional(),
});
