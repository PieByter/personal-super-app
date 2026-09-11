import { z } from "zod";

// Auth
export const loginSchema = z.object({
    email: z.string().email(),
    password: z.string().min(6).max(128),
});

export const registerSchema = z.object({
    email: z.string().email(),
    password: z.string().min(6).max(128),
    fullName: z.string().min(2).max(255).optional(),
});

// Finance
export const transactionSchema = z.object({
    categoryId: z.string().uuid().optional(),
    amount: z.string().or(z.number()),
    type: z.enum(["income", "expense"]),
    description: z.string().max(500).optional(),
    transactionDate: z.string(),
    paymentMethod: z.string().max(100).optional(),
    tags: z.array(z.string().max(50)).max(20).optional(),
});

export const categorySchema = z.object({
    name: z.string().min(1).max(100),
    type: z.enum(["income", "expense"]),
    color: z.string().max(7).optional(),
    icon: z.string().max(50).optional(),
    parentId: z.string().uuid().optional(),
});

// Journal
export const journalEntrySchema = z.object({
    title: z.string().min(1).max(255),
    problem: z.string().max(5000).optional(),
    rootCause: z.string().max(5000).optional(),
    solution: z.string().max(5000).optional(),
    conceptLearned: z.string().max(5000).optional(),
    codeSnippet: z.string().max(20000).optional(),
    language: z.string().max(50).optional(),
    projectName: z.string().max(255).optional(),
    tagIds: z.array(z.string().uuid()).max(20).optional(),
});

// Bug
export const bugEntrySchema = z.object({
    title: z.string().min(1).max(255),
    projectName: z.string().max(255).optional(),
    technology: z.string().max(100).optional(),
    errorMessage: z.string().max(2000).optional(),
    errorType: z.string().max(100).optional(),
    cause: z.string().max(5000).optional(),
    solution: z.string().max(5000).optional(),
    severity: z.enum(["low", "medium", "high", "critical"]).optional(),
    tags: z.array(z.string().max(50)).max(20).optional(),
});

// Job
export const jobWebsiteSchema = z.object({
    name: z.string().min(1).max(255),
    url: z.string().url().max(2048).optional(),
    status: z.enum(["active", "inactive", "archived"]).optional(),
    notes: z.string().max(2000).optional(),
});

export const jobApplicationSchema = z.object({
    companyName: z.string().min(1).max(255),
    position: z.string().min(1).max(255),
    salaryRange: z.string().max(100).optional(),
    location: z.string().max(255).optional(),
    jobType: z.string().max(50).optional(),
    status: z.enum(["applied", "screening", "interview", "technical_test", "offer", "rejected", "withdrawn", "accepted"]).optional(),
    applicationDate: z.string(),
    jobDescription: z.string().max(20000).optional(),
    notes: z.string().max(5000).optional(),
    url: z.string().url().max(2048).optional(),
    websiteId: z.string().uuid().optional(),
});

// Project
export const projectSchema = z.object({
    name: z.string().min(1).max(255),
    description: z.string().max(5000).optional(),
    goal: z.string().max(5000).optional(),
    priority: z.enum(["low", "medium", "high"]).optional(),
    startDate: z.string().optional(),
    targetDate: z.string().optional(),
    techStack: z.array(z.string().max(50)).max(30).optional(),
    gitRepository: z.string().max(2048).optional(),
    color: z.string().max(7).optional(),
});

export const projectTaskSchema = z.object({
    projectId: z.string().uuid(),
    milestoneId: z.string().uuid().optional(),
    title: z.string().min(1).max(255),
    description: z.string().max(5000).optional(),
    status: z.enum(["todo", "in_progress", "review", "done"]).optional(),
    priority: z.enum(["low", "medium", "high"]).optional(),
    dueDate: z.string().optional(),
    tags: z.array(z.string().max(50)).max(20).optional(),
});

// Habit
export const habitSchema = z.object({
    name: z.string().min(1).max(255),
    description: z.string().max(2000).optional(),
    icon: z.string().max(50).optional(),
    color: z.string().max(7).optional(),
    targetValue: z.number().or(z.string()).optional(),
    unit: z.string().max(50).optional(),
    frequency: z.enum(["daily", "weekly", "monthly"]),
    targetDays: z.array(z.number()).max(7).optional(),
    reminderTime: z.string().optional(),
});

export const habitLogSchema = z.object({
    habitId: z.string().uuid(),
    logDate: z.string(),
    value: z.number().or(z.string()).optional(),
    notes: z.string().max(2000).optional(),
    mood: z.string().max(20).optional(),
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
    notes: z.string().max(2000).optional(),
});

// Subscription
export const subscriptionSchema = z.object({
    name: z.string().min(1).max(255),
    description: z.string().max(2000).optional(),
    provider: z.string().max(100).optional(),
    category: z.string().max(50).optional(),
    amount: z.string().or(z.number()),
    currency: z.string().max(10).optional(),
    billingCycle: z.enum(["weekly", "monthly", "quarterly", "yearly", "lifetime"]),
    nextRenewalDate: z.string().optional(),
    startDate: z.string().optional(),
    paymentMethod: z.string().max(100).optional(),
    reminderDays: z.number().optional(),
});

// Inventory
export const inventoryItemSchema = z.object({
    categoryId: z.string().uuid().optional(),
    name: z.string().min(1).max(255),
    description: z.string().max(5000).optional(),
    brand: z.string().max(100).optional(),
    model: z.string().max(100).optional(),
    serialNumber: z.string().max(100).optional(),
    purchaseDate: z.string().optional(),
    purchasePrice: z.number().or(z.string()).optional(),
    currentValue: z.number().or(z.string()).optional(),
    condition: z.enum(["excellent", "good", "fair", "poor", "broken"]).optional(),
    location: z.string().max(255).optional(),
    warrantyExpiry: z.string().optional(),
    tags: z.array(z.string().max(50)).max(20).optional(),
    photoUrls: z.array(z.string().url().max(2048)).max(5).optional(),
});

// Bookmark
export const bookmarkSchema = z.object({
    collectionId: z.string().uuid().optional(),
    title: z.string().min(1).max(255),
    url: z.string().url().max(2048),
    description: z.string().max(2000).optional(),
    notes: z.string().max(5000).optional(),
    status: z.enum(["unread", "reading", "completed", "archived"]).optional(),
    rating: z.number().min(1).max(5).optional(),
    tags: z.array(z.string().max(50)).max(20).optional(),
});
