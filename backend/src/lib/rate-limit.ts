import { NextRequest } from "next/server";

interface RateLimitEntry {
    count: number;
    resetAt: number;
}

// Simple in-memory fixed-window rate limiter.
// Note: on serverless (Vercel) this is per-instance, but still a meaningful
// first line of defense against brute-force. For production multi-instance,
// replace with a Redis-backed limiter.
const store = new Map<string, RateLimitEntry>();

// Periodically clean up expired entries to avoid unbounded growth.
setInterval(() => {
    const now = Date.now();
    store.forEach((entry, key) => {
        if (entry.resetAt <= now) store.delete(key);
    });
}, 60_000).unref?.();

export interface RateLimitOptions {
    windowMs?: number;
    max?: number;
}

export function rateLimit(
    req: NextRequest,
    { windowMs = 60_000, max = 10 }: RateLimitOptions = {}
): { success: boolean; retryAfterSeconds?: number } {
    const ip =
        req.headers.get("x-forwarded-for")?.split(",")[0]?.trim() ||
        req.headers.get("x-real-ip") ||
        "unknown";

    const key = `${ip}`;
    const now = Date.now();
    const entry = store.get(key);

    if (!entry || entry.resetAt <= now) {
        store.set(key, { count: 1, resetAt: now + windowMs });
        return { success: true };
    }

    if (entry.count >= max) {
        const retryAfterSeconds = Math.ceil((entry.resetAt - now) / 1000);
        return { success: false, retryAfterSeconds };
    }

    entry.count += 1;
    return { success: true };
}

export function rateLimitResponse(retryAfterSeconds: number) {
    return Response.json(
        {
            error: "Too many requests. Please try again later.",
        },
        {
            status: 429,
            headers: { "Retry-After": String(retryAfterSeconds) },
        }
    );
}
