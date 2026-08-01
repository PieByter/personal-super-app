import { NextRequest } from "next/server";
import { db } from "@/db";
import { jobApplications } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { jobApplicationSchema } from "@/lib/validation";
import { eq, desc } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const entries = await db
        .select()
        .from(jobApplications)
        .where(eq(jobApplications.userId, user.userId))
        .orderBy(desc(jobApplications.createdAt));

    return Response.json(entries);
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const body = await req.json();
        const data = jobApplicationSchema.parse(body);

        const [entry] = await db
            .insert(jobApplications)
            .values({
                userId: user.userId,
                companyName: data.companyName,
                position: data.position,
                salaryRange: data.salaryRange,
                location: data.location,
                jobType: data.jobType,
                status: data.status,
                applicationDate: data.applicationDate,
                jobDescription: data.jobDescription,
                notes: data.notes,
                url: data.url,
            })
            .returning();

        return Response.json(entry, { status: 201 });
    } catch (error) {
        if (error instanceof Error) {
            return Response.json({ error: error.message }, { status: 400 });
        }
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const { searchParams } = new URL(req.url);
        const id = searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        const body = await req.json();
        const data = jobApplicationSchema.parse(body);

        const [updated] = await db
            .update(jobApplications)
            .set({
                companyName: data.companyName,
                position: data.position,
                salaryRange: data.salaryRange,
                location: data.location,
                jobType: data.jobType,
                status: data.status,
                applicationDate: data.applicationDate,
                jobDescription: data.jobDescription,
                notes: data.notes,
                url: data.url,
                updatedAt: new Date(),
            })
            .where(eq(jobApplications.id, id))
            .returning();

        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });

        return Response.json(updated);
    } catch (error) {
        if (error instanceof Error) {
            return Response.json({ error: error.message }, { status: 400 });
        }
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const { searchParams } = new URL(req.url);
        const id = searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        await db.delete(jobApplications).where(eq(jobApplications.id, id));

        return Response.json({ success: true });
    } catch (error) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
