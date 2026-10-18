import { describe, it, expect } from "vitest";
import jwt from "jsonwebtoken";
import { verifyAccessToken } from "./jwt-edge";

// Matches the JWT_SECRET provided by vitest.config.ts.
const SECRET = "test-secret-for-vitest-do-not-use-in-production";

function tamperPayload(token: string, payload: Record<string, unknown>): string {
    const [header, , signature] = token.split(".");
    const forged = Buffer.from(JSON.stringify(payload)).toString("base64url");
    return `${header}.${forged}.${signature}`;
}

describe("verifyAccessToken (edge-compatible)", () => {
    it("accepts a token signed with the configured secret", async () => {
        const token = jwt.sign({ userId: "u1" }, SECRET, { expiresIn: "5m" });
        await expect(verifyAccessToken(token)).resolves.toBe(true);
    });

    it("rejects a token signed with a different secret", async () => {
        const token = jwt.sign({ userId: "u1" }, "some-other-secret", { expiresIn: "5m" });
        await expect(verifyAccessToken(token)).resolves.toBe(false);
    });

    it("rejects an expired token", async () => {
        const token = jwt.sign({ userId: "u1" }, SECRET, { expiresIn: "-1m" });
        await expect(verifyAccessToken(token)).resolves.toBe(false);
    });

    it("rejects a token whose payload was modified", async () => {
        const token = jwt.sign({ userId: "u1" }, SECRET, { expiresIn: "5m" });
        const forged = tamperPayload(token, {
            userId: "someone-else",
            exp: Math.floor(Date.now() / 1000) + 300,
        });
        await expect(verifyAccessToken(forged)).resolves.toBe(false);
    });

    it("rejects malformed tokens", async () => {
        await expect(verifyAccessToken("")).resolves.toBe(false);
        await expect(verifyAccessToken("not-a-jwt")).resolves.toBe(false);
        await expect(verifyAccessToken("a.b.c")).resolves.toBe(false);
    });
});
