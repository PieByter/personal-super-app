import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { NextRequest } from "next/server";

const JWT_SECRET = process.env.JWT_SECRET || "your-super-secret-key-change-in-production";

export interface JWTPayload {
    userId: string;
    email: string;
    iat: number;
    exp: number;
}

export async function hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
}

export function generateToken(userId: string, email: string): string {
    return jwt.sign({ userId, email }, JWT_SECRET, { expiresIn: "7d" });
}

export function verifyToken(token: string): JWTPayload {
    return jwt.verify(token, JWT_SECRET) as JWTPayload;
}

export function getAuthUser(req: NextRequest): JWTPayload | null {
    try {
        const authHeader = req.headers.get("authorization");
        if (!authHeader?.startsWith("Bearer ")) return null;
        const token = authHeader.substring(7);
        return verifyToken(token);
    } catch {
        return null;
    }
}

export function unauthorizedResponse() {
    return Response.json({ error: "Unauthorized" }, { status: 401 });
}
