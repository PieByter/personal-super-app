import { describe, it, expect } from "vitest";
import { generateToken, verifyToken, hashPassword, verifyPassword } from "./auth";

describe("auth helpers", () => {
    it("generates a token that verifies with the same payload", () => {
        const token = generateToken("user-123", "test@example.com", "user");
        const payload = verifyToken(token);
        expect(payload.userId).toBe("user-123");
        expect(payload.email).toBe("test@example.com");
        expect(payload.role).toBe("user");
        expect(payload.exp).toBeGreaterThan(payload.iat);
    });

    it("generates a token with role admin", () => {
        const token = generateToken("admin-1", "admin@example.com", "admin");
        expect(verifyToken(token).role).toBe("admin");
    });

    it("throws on invalid token", () => {
        expect(() => verifyToken("not-a-jwt")).toThrow();
    });

    it("hashes and verifies passwords", async () => {
        const hash = await hashPassword("super-secret-123");
        expect(hash).not.toBe("super-secret-123");
        expect(await verifyPassword("super-secret-123", hash)).toBe(true);
        expect(await verifyPassword("wrong-password", hash)).toBe(false);
    });
});
