import { describe, it, expect } from "vitest";
import { normalizeDatabaseUrl } from "./db-url";

const SUPABASE_POOLER =
    "postgresql://postgres.abcdefgh:secret@aws-0-ap-southeast-1.pooler.supabase.com:6543/postgres?pgbouncer=true&connection_limit=1&sslmode=require";

describe("normalizeDatabaseUrl", () => {
    it("drops Prisma-only parameters that the pooler would reject", () => {
        const url = normalizeDatabaseUrl(SUPABASE_POOLER);

        expect(url).not.toContain("pgbouncer");
        expect(url).not.toContain("connection_limit");
        // sslmode must survive: postgres.js reads it to enable TLS.
        expect(url).toContain("sslmode=require");
        expect(url).toContain("pooler.supabase.com:6543");
    });

    it("returns the input untouched when there is nothing to strip", () => {
        const plain = "postgresql://user:password@localhost:5432/personal_super_app";
        expect(normalizeDatabaseUrl(plain)).toBe(plain);

        const withSsl = `${plain}?sslmode=require`;
        expect(normalizeDatabaseUrl(withSsl)).toBe(withSsl);
    });

    it("handles a single client-only parameter", () => {
        const url = normalizeDatabaseUrl("postgresql://user:pw@host:6543/db?pgbouncer=true");
        expect(url).toBe("postgresql://user:pw@host:6543/db");
    });

    it("leaves non-URL values alone", () => {
        expect(normalizeDatabaseUrl("not a url")).toBe("not a url");
        expect(normalizeDatabaseUrl("")).toBe("");
    });
});
