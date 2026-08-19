import { NextRequest } from "next/server";
import { db } from "@/db";
import { jobApplications } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, and, gte } from "drizzle-orm";

export async function GET(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const all = await db
        .select()
        .from(jobApplications)
        .where(eq(jobApplications.userId, user.userId));

    const total = all.length;
    const byStatus: Record<string, number> = {};
    for (const j of all) {
        const status = j.status || "applied";
        byStatus[status] = (byStatus[status] || 0) + 1;
    }

    // Response rate: applications that got any response (interview/offer/rejected)
    const responded = all.filter((j) =>
        ["interview", "technical_test", "offer", "rejected", "accepted"].includes(j.status || "")
    ).length;
    const responseRate = total > 0 ? Math.round((responded / total) * 100) : 0;

    // Interview rate
    const interviewed = all.filter((j) =>
        ["interview", "technical_test", "offer", "accepted"].includes(j.status || "")
    ).length;
    const interviewRate = total > 0 ? Math.round((interviewed / total) * 100) : 0;

    // Offer rate
    const offered = all.filter((j) => ["offer", "accepted"].includes(j.status || "")).length;
    const offerRate = total > 0 ? Math.round((offered / total) * 100) : 0;

    // Applications in the last 30 days
    const thirtyDaysAgo = new Date();
    thirtyDaysAgo.setDate(thirtyDaysAgo.getDate() - 30);
    const recent = all.filter((j) => {
        const d = new Date(j.applicationDate + "T00:00:00");
        return d >= thirtyDaysAgo;
    }).length;

    return Response.json({
        total,
        byStatus,
        responseRate,
        interviewRate,
        offerRate,
        recent30Days: recent,
    });
}
