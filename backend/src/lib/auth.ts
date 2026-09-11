import jwt from "jsonwebtoken";
import bcrypt from "bcryptjs";
import { randomBytes } from "crypto";
import { NextRequest } from "next/server";

const JWT_SECRET = process.env.JWT_SECRET;
if (!JWT_SECRET) {
    throw new Error(
        "JWT_SECRET environment variable is not set. " +
        "Set it in your .env file or deployment environment before starting the server."
    );
}
// After the guard above, JWT_SECRET is guaranteed to be a non-empty string.
const SECRET = JWT_SECRET as string;

export interface JWTPayload {
    userId: string;
    email: string;
    role: string;
    iat: number;
    exp: number;
}

export async function hashPassword(password: string): Promise<string> {
    return bcrypt.hash(password, 12);
}

export async function verifyPassword(password: string, hash: string): Promise<boolean> {
    return bcrypt.compare(password, hash);
}

/**
 * Short-lived access token (15 minutes).
 * Used in the Authorization header for every API request.
 */
export function generateAccessToken(userId: string, email: string, role: string = "user"): string {
    return jwt.sign({ userId, email, role }, SECRET, { expiresIn: "15m" });
}

/**
 * Opaque refresh token (30 days). Stored in the DB so it can be revoked.
 */
export function generateRefreshToken(): string {
    return randomBytes(48).toString("hex");
}

export function generateToken(userId: string, email: string, role: string = "user"): string {
    return jwt.sign({ userId, email, role }, SECRET, { expiresIn: "7d" });
}

export function verifyToken(token: string): JWTPayload {
    return jwt.verify(token, SECRET) as JWTPayload;
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

export function forbiddenResponse() {
    return Response.json({ error: "Forbidden" }, { status: 403 });
}

export function requireAdmin(user: JWTPayload | null) {
    if (!user) return unauthorizedResponse();
    if (user.role !== "admin") return forbiddenResponse();
    return null;
}
