import { NextRequest } from "next/server";
import { db } from "@/db";
import { jobWebsites, jobApplications } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { jobWebsiteSchema } from "@/lib/validation";
import { eq, and, desc, count, max } from "drizzle-orm";
import { apiError } from "@/lib/api-error";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const websites = await db
        .select()
        .from(jobWebsites)
        .where(eq(jobWebsites.userId, user.userId))
        .orderBy(desc(jobWebsites.createdAt));

    // Stats per website: total applications + last application date
    const stats = await db
        .select({
            websiteId: jobApplications.websiteId,
            total: count(),
            lastAppliedAt: max(jobApplications.applicationDate),
        })
        .from(jobApplications)
        .where(eq(jobApplications.userId, user.userId))
        .groupBy(jobApplications.websiteId);

    const statsMap = new Map(stats.map((s) => [s.websiteId, s]));

    return Response.json(
        websites.map((w) => {
            const s = statsMap.get(w.id);
            return {
                ...w,
                totalApplications: Number(s?.total ?? 0),
                lastAppliedAt: s?.lastAppliedAt ?? null,
            };
        })
    );
}

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const data = jobWebsiteSchema.parse(await req.json());
        const [entry] = await db
            .insert(jobWebsites)
            .values({ userId: user.userId, ...data })
            .returning();
        return Response.json(entry, { status: 201 });
    } catch (error) {
        return apiError(error);
    }
}

export async function PUT(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        const data = jobWebsiteSchema.parse(await req.json());
        const [updated] = await db
            .update(jobWebsites)
            .set({ ...data, updatedAt: new Date() })
            .where(and(eq(jobWebsites.id, id), eq(jobWebsites.userId, user.userId)))
            .returning();

        if (!updated) return Response.json({ error: "Not found" }, { status: 404 });
        return Response.json(updated);
    } catch (error) {
        return apiError(error);
    }
}

export async function DELETE(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const id = new URL(req.url).searchParams.get("id");
        if (!id) return Response.json({ error: "ID required" }, { status: 400 });

        await db.delete(jobWebsites).where(and(eq(jobWebsites.id, id), eq(jobWebsites.userId, user.userId)));
        return Response.json({ success: true });
    } catch (error) {
        return apiError(error);
    }
}
