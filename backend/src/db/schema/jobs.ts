import { pgTable, uuid, varchar, text, timestamp, boolean, integer, date, index } from "drizzle-orm/pg-core";
import { users } from "./users";
import { jobStatusEnum, websiteStatusEnum } from "./enums";

export const jobWebsites = pgTable("job_websites", {
    id: uuid("id").primaryKey().defaultRandom(),
    userId: uuid("user_id").references(() => users.id, { onDelete: "cascade" }).notNull(),
    name: varchar("name", { length: 255 }).notNull(),
    url: text("url"),
    status: websiteStatusEnum("status").default("active"),
    notes: text("notes"),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("job_websites_user_id_idx").on(t.userId),
]);

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
    websiteId: uuid("website_id").references(() => jobWebsites.id, { onDelete: "set null" }),
    createdAt: timestamp("created_at", { withTimezone: true }).defaultNow(),
    updatedAt: timestamp("updated_at", { withTimezone: true }).defaultNow(),
}, (t) => [
    index("job_applications_user_id_idx").on(t.userId),
    index("job_applications_status_idx").on(t.userId, t.status),
]);

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
}, (t) => [
    index("job_interviews_job_id_idx").on(t.jobId),
]);

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
}, (t) => [
    index("job_contacts_job_id_idx").on(t.jobId),
]);