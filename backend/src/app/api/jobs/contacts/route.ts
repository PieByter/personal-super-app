import { NextRequest } from "next/server";
import { db } from "@/db";
import { jobContacts, jobApplications } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, desc, inArray, getTableColumns } from "drizzle-orm";
import { z } from "zod";
import { apiError } from "@/lib/api-error";

const contactSchema = z.object({
    jobId: z.string().uuid(),
    name: z.string().min(1),
    role: z.string().optional(),
    email: z.string().optional(),
    phone: z.string().optional(),
    linkedinUrl: z.string().optional(),
    notes: z.string().optional(),
});

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    const { searchParams } = new URL(req.url);
    const jobId = searchParams.get("jobId");
    const conditions = [eq(jobApplications.userId, user.userId)];
    if (jobId) conditions.push(eq(jobContacts.jobId, jobId));
    const rows = await db
        .select({ ...getTableColumns(jobContacts) })
        .from(jobContacts)
        .innerJoin(jobApplications, eq(jobContacts.jobId, jobApplications.id))
        .where(and(...conditions))
        .orderBy(desc(jobContacts.createdAt));
    return Response.json(rows);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const body = await req.json();
        const data = contactSchema.parse(body);
        const [row] = await db.insert(jobContacts).values({ jobId: data.jobId, name: data.name, role: data.role, email: data.email, phone: data.phone, linkedinUrl: data.linkedinUrl, notes: data.notes }).returning();
        return Response.json(row, { status: 201 });
    } catch (e) { return apiError(e); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = contactSchema.parse(body);
        const [updated] = await db.update(jobContacts).set({ name: data.name, role: data.role, email: data.email, phone: data.phone, linkedinUrl: data.linkedinUrl, notes: data.notes }).from(jobApplications).where(and(eq(jobContacts.id, id), eq(jobContacts.jobId, jobApplications.id), eq(jobApplications.userId, user.userId))).returning();
        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) { return apiError(e); }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        await db.delete(jobContacts).where(and(
            eq(jobContacts.id, id),
            inArray(jobContacts.jobId, db.select({ id: jobApplications.id }).from(jobApplications).where(eq(jobApplications.userId, user.userId)))
        ));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
