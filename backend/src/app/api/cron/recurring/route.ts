import { NextRequest } from "next/server";
import { processDueRules } from "../../finance/recurring/route";

/**
 * Scheduled cron endpoint (Vercel Cron) that processes due recurring
 * transactions for ALL users. Protected by CRON_SECRET.
 */
export async function GET(req: NextRequest) {
    const secret = process.env.CRON_SECRET;
    const auth = req.headers.get("authorization");
    if (!secret || auth !== `Bearer ${secret}`) {
        return Response.json({ error: "Unauthorized" }, { status: 401 });
    }

    try {
        const created = await processDueRules(null);
        return Response.json({ success: true, created: created.length });
    } catch (e) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
