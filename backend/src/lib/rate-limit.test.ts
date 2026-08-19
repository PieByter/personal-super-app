import { describe, it, expect, beforeEach } from "vitest";
import type { NextRequest } from "next/server";
import { rateLimit, rateLimitResponse } from "./rate-limit";

function makeReq(ip: string): NextRequest {
    const req = new Request("http://localhost/api/auth", {
        headers: { "x-forwarded-for": ip },
    });
    return req as unknown as NextRequest;
}

// Note: rate-limit uses a module-level Map, so use a fresh key per test
// to avoid cross-test pollution.
let counter = 0;

describe("rateLimit", () => {
    beforeEach(() => {
        counter++;
    });

    it("allows requests under the limit", () => {
        const req = makeReq(`192.168.0.${counter}`);
        for (let i = 0; i < 9; i++) {
            const result = rateLimit(req, { windowMs: 60_000, max: 10 });
            expect(result.success).toBe(true);
        }
    });

    it("blocks requests over the limit and returns retryAfterSeconds", () => {
        const req = makeReq(`10.0.0.${counter}`);
        for (let i = 0; i < 10; i++) {
            rateLimit(req, { windowMs: 60_000, max: 10 });
        }
        const blocked = rateLimit(req, { windowMs: 60_000, max: 10 });
        expect(blocked.success).toBe(false);
        expect(blocked.retryAfterSeconds).toBeGreaterThan(0);
        expect(blocked.retryAfterSeconds).toBeLessThanOrEqual(60);
    });

    it("treats different IPs independently", () => {
        const a = makeReq(`172.16.1.${counter}`);
        const b = makeReq(`172.16.2.${counter}`);
        for (let i = 0; i < 10; i++) rateLimit(a, { windowMs: 60_000, max: 10 });
        expect(rateLimit(a, { windowMs: 60_000, max: 10 }).success).toBe(false);
        expect(rateLimit(b, { windowMs: 60_000, max: 10 }).success).toBe(true);
    });

    it("rateLimitResponse returns 429 with Retry-After header", async () => {
        const res = rateLimitResponse(42);
        expect(res.status).toBe(429);
        expect(res.headers.get("Retry-After")).toBe("42");
        const body = await res.json();
        expect(body.error).toContain("Too many requests");
    });
});
