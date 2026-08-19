import { describe, it, expect } from "vitest";
import { apiError } from "./api-error";
import { ZodError, z } from "zod";

describe("apiError", () => {
    it("returns generic message + safe details for Zod errors", async () => {
        const schema = z.object({ email: z.string().email() });
        try {
            schema.parse({ email: "not-an-email" });
        } catch (e) {
            const res = apiError(e);
            expect(res.status).toBe(400);
            const body = await res.json();
            expect(body.error).toBe("Invalid request data");
            expect(Array.isArray(body.details)).toBe(true);
            expect(body.details.length).toBeGreaterThan(0);
        }
    });

    it("returns generic 500 without leaking internals for unknown errors", async () => {
        const res = apiError(new Error("DATABASE_CONNECTION_REFUSED secret=xyz"));
        expect(res.status).toBe(500);
        const body = await res.json();
        expect(body.error).toBe("Internal server error");
        expect(JSON.stringify(body)).not.toContain("secret");
    });

    it("returns generic 500 for non-Error values", async () => {
        const res = apiError("random string");
        expect(res.status).toBe(500);
    });
});
