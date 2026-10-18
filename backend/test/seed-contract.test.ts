import { describe, it, expect } from "vitest";
import { createServer } from "node:http";
import { spawn } from "node:child_process";
import path from "node:path";
import type { AddressInfo } from "node:net";
import type { ZodTypeAny } from "zod";
import {
    bookmarkSchema,
    bugEntrySchema,
    categorySchema,
    dailyMetricSchema,
    habitLogSchema,
    habitSchema,
    inventoryItemSchema,
    jobApplicationSchema,
    jobWebsiteSchema,
    journalEntrySchema,
    loginSchema,
    projectSchema,
    projectTaskSchema,
    registerSchema,
    subscriptionSchema,
    transactionSchema,
} from "@/lib/validation";

/** Endpoints whose schema lives in the route file, keyed by required fields. */
const REQUIRED_FIELDS: Record<string, string[]> = {
    "/finance/budgets": ["amount", "period", "startDate"],
    "/finance/goals": ["name", "targetAmount"],
    "/finance/recurring": ["amount", "type", "frequency", "startDate"],
    "/finance/investments": ["name", "type", "quantity", "purchasePrice", "purchaseDate"],
    "/projects/milestones": ["projectId", "title"],
    "/subscriptions/payments": ["subscriptionId", "amount", "paymentDate"],
    "/jobs/contacts": ["jobId", "name"],
    "/jobs/interviews": ["jobId", "interviewType"],
    "/journal/tags": ["name"],
    "/inventory/categories": ["name"],
    "/bookmarks/collections": ["name"],
};

const SCHEMAS: Record<string, ZodTypeAny> = {
    "/finance/categories": categorySchema,
    "/finance/transactions": transactionSchema,
    "/projects": projectSchema,
    "/projects/tasks": projectTaskSchema,
    "/habits": habitSchema,
    "/habits/logs": habitLogSchema,
    "/habits/metrics": dailyMetricSchema,
    "/subscriptions": subscriptionSchema,
    "/jobs/websites": jobWebsiteSchema,
    "/jobs": jobApplicationSchema,
    "/journal": journalEntrySchema,
    "/bugs": bugEntrySchema,
    "/inventory": inventoryItemSchema,
    "/bookmarks": bookmarkSchema,
};

interface Recorded {
    method: string;
    path: string;
    error?: string;
}

const EXPECTED_PATHS = [
    "/auth",
    "/finance/categories",
    "/finance/transactions",
    "/finance/budgets",
    "/finance/goals",
    "/finance/recurring",
    "/finance/investments",
    "/projects",
    "/projects/milestones",
    "/projects/tasks",
    "/habits",
    "/habits/logs",
    "/habits/metrics",
    "/subscriptions",
    "/subscriptions/payments",
    "/jobs/websites",
    "/jobs",
    "/jobs/contacts",
    "/jobs/interviews",
    "/journal/tags",
    "/journal",
    "/bugs",
    "/inventory/categories",
    "/inventory",
    "/bookmarks/collections",
    "/bookmarks",
];

/** Stub API that validates every seeded payload against the real schemas. */
function startStub(recorded: Recorded[]) {
    const server = createServer((req, res) => {
        let raw = "";
        req.on("data", (chunk) => (raw += chunk));
        req.on("end", () => {
            const url = new URL(req.url ?? "/", "http://127.0.0.1");
            const route = url.pathname.replace(/^\/api/, "");
            const body = raw ? JSON.parse(raw) : undefined;

            const send = (status: number, payload: unknown) => {
                res.writeHead(status, { "Content-Type": "application/json" });
                res.end(JSON.stringify(payload));
            };

            let error: string | undefined;
            if (req.method !== "GET") {
                const schema = route === "/auth" && body?.action === "login" ? loginSchema : SCHEMAS[route];
                if (schema) {
                    const result = schema.safeParse(body);
                    if (!result.success) {
                        error = `${route}: ${result.error.issues.map((i) => `${i.path.join(".")} ${i.message}`).join("; ")}`;
                    }
                } else if (route === "/auth" && body?.action === "register") {
                    const result = registerSchema.safeParse(body);
                    if (!result.success) error = `${route}: ${result.error.issues[0]?.message}`;
                } else if (REQUIRED_FIELDS[route]) {
                    const missing = REQUIRED_FIELDS[route].filter((field) => body?.[field] === undefined);
                    if (missing.length > 0) error = `${route}: missing ${missing.join(", ")}`;
                } else if (route !== "/auth") {
                    error = `${route}: no contract registered for this endpoint`;
                }
            }

            recorded.push({ method: req.method ?? "", path: route, error });
            if (error) return send(400, { error: "Invalid request data", details: [error] });

            if (req.method === "GET") return send(200, []);
            send(201, { id: "00000000-0000-4000-8000-000000000001", accessToken: "stub-token", refreshToken: "stub-refresh", ...body });
        });
    });

    return new Promise<{ port: number; close: () => Promise<void> }>((resolve) => {
        server.listen(0, "127.0.0.1", () => {
            const { port } = server.address() as AddressInfo;
            resolve({
                port,
                close: () => new Promise((done) => server.close(() => done())),
            });
        });
    });
}

describe("database/seed.mjs contract", () => {
    it("only calls real endpoints with payloads the backend accepts", async () => {
        const recorded: Recorded[] = [];
        const stub = await startStub(recorded);

        const seedPath = path.join(process.cwd(), "..", "database", "seed.mjs");
        const child = spawn(process.execPath, [seedPath], {
            env: { ...process.env, API_URL: `http://127.0.0.1:${stub.port}/api` },
        });

        let output = "";
        child.stdout.on("data", (d) => (output += d));
        child.stderr.on("data", (d) => (output += d));
        const exitCode = await new Promise<number>((resolve) => child.on("close", resolve));
        await stub.close();

        const failures = recorded.filter((r) => r.error);
        expect(failures.map((f) => f.error)).toEqual([]);
        expect(output).toContain("records created");

        const called = new Set(recorded.map((r) => r.path));
        const missing = EXPECTED_PATHS.filter((p) => !called.has(p));
        expect(missing, `seed did not call: ${missing.join(", ")}\n${output}`).toEqual([]);
        expect(exitCode, output).toBe(0);
    }, 30_000);
});
