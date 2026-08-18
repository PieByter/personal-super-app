import { NextRequest } from "next/server";
import { db } from "@/db";
import { users } from "@/db/schema";
import { hashPassword, verifyPassword, generateToken } from "@/lib/auth";
import { loginSchema, registerSchema } from "@/lib/validation";
import { rateLimit, rateLimitResponse } from "@/lib/rate-limit";
import { eq } from "drizzle-orm";
import { apiError } from "@/lib/api-error";

export async function POST(req: NextRequest) {
    const limit = rateLimit(req, { windowMs: 60_000, max: 10 });
    if (!limit.success) {
        return rateLimitResponse(limit.retryAfterSeconds ?? 60);
    }

    try {
        const body = await req.json();
        const { action } = body;

        if (action === "register") {
            const data = registerSchema.parse(body);
            const existing = await db.select().from(users).where(eq(users.email, data.email)).limit(1);
            if (existing.length > 0) {
                return Response.json({ error: "Email already registered" }, { status: 409 });
            }

            const passwordHash = await hashPassword(data.password);
            const [user] = await db
                .insert(users)
                .values({
                    email: data.email,
                    passwordHash,
                    fullName: data.fullName,
                })
                .returning({ id: users.id, email: users.email, fullName: users.fullName, role: users.role });

            const token = generateToken(user.id, user.email, user.role || "user");
            return Response.json({ user: { ...user, role: user.role || "user" }, token });
        }

        if (action === "login") {
            const data = loginSchema.parse(body);
            const [user] = await db.select().from(users).where(eq(users.email, data.email)).limit(1);
            if (!user) {
                return Response.json({ error: "Invalid credentials" }, { status: 401 });
            }

            const valid = await verifyPassword(data.password, user.passwordHash);
            if (!valid) {
                return Response.json({ error: "Invalid credentials" }, { status: 401 });
            }

            const token = generateToken(user.id, user.email, user.role || "user");
            return Response.json({
                user: { id: user.id, email: user.email, fullName: user.fullName, role: user.role || "user" },
                token,
            });
        }

        return Response.json({ error: "Invalid action" }, { status: 400 });
    } catch (error) {
        return apiError(error);
    }
}
