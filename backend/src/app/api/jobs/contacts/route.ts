import { NextRequest } from "next/server";
import { db } from "@/db";
import { jobContacts } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, desc } from "drizzle-orm";
import { z } from "zod";

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
    const conditions = jobId ? [eq(jobContacts.jobId, jobId)] : [];
    const rows = await db.select().from(jobContacts).where(conditions.length > 0 ? conditions[0] : undefined).orderBy(desc(jobContacts.createdAt));
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
    } catch (e) { return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 }); }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        const body = await req.json();
        const data = contactSchema.parse(body);
        const [updated] = await db.update(jobContacts).set({ name: data.name, role: data.role, email: data.email, phone: data.phone, linkedinUrl: data.linkedinUrl, notes: data.notes }).where(eq(jobContacts.id, id)).returning();
        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (e) { return Response.json({ error: e instanceof Error ? e.message : "Error" }, { status: 400 }); }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();
    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });
        await db.delete(jobContacts).where(eq(jobContacts.id, id));
        return Response.json({ success: true });
    } catch (e) { return Response.json({ error: "Internal server error" }, { status: 500 }); }
}
