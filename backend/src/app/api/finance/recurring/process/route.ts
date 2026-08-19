import { NextRequest } from "next/server";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { processDueRules } from "../route";

export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    try {
        const created = await processDueRules(user.userId);
        return Response.json({ success: true, created: created.length });
    } catch (e) {
        return Response.json({ error: "Internal server error" }, { status: 500 });
    }
}
