import { NextRequest } from "next/server";
import { db } from "@/db";
import { users } from "@/db/schema";
import { getAuthUser, unauthorizedResponse } from "@/lib/auth";
import { eq, count } from "drizzle-orm";

/**
 * Bootstrap admin: promotes the calling user to admin, but ONLY if no admin
 * exists yet. This solves the chicken-and-egg problem of the first admin.
 * Once an admin exists, this endpoint refuses to work.
 */
export async function POST(req: NextRequest) {
    const user = getAuthUser(req);
    if (!user) return unauthorizedResponse();

    const [adminCount] = await db
        .select({ value: count() })
        .from(users)
        .where(eq(users.role, "admin"));

    if ((adminCount?.value ?? 0) > 0) {
        return Response.json(
            { error: "An admin already exists. Ask an existing admin to promote you." },
            { status: 403 }
        );
    }

    const [updated] = await db
        .update(users)
        .set({ role: "admin", updatedAt: new Date() })
        .where(eq(users.id, user.userId))
        .returning({ id: users.id, email: users.email, role: users.role });

    if (!updated) return Response.json({ error: "User not found" }, { status: 404 });
    return Response.json({ success: true, user: updated });
}
