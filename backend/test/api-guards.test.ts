import { describe, it, expect, beforeEach, vi } from "vitest";
import jwt from "jsonwebtoken";

// Matches the JWT_SECRET provided by vitest.config.ts.
const SECRET = "test-secret-for-vitest-do-not-use-in-production";

const state = vi.hoisted(() => ({
    /** Rows returned by any select (empty = the user does not own the row). */
    rows: [] as Record<string, unknown>[],
    inserted: [] as Record<string, unknown>[],
}));

/** Thenable mock that supports the Drizzle chains the routes use. */
function chain(result: unknown) {
    const node: Record<string, unknown> = {};
    const self = () => node;
    Object.assign(node, {
        then: (resolve: (value: unknown) => unknown) => Promise.resolve(result).then(resolve),
        limit: self,
        offset: self,
        orderBy: self,
        groupBy: self,
        innerJoin: self,
        leftJoin: self,
        returning: () => Promise.resolve(result),
    });
    return node;
}

vi.mock("@/db", () => ({
    db: {
        select: () => ({ from: () => ({ where: () => chain(state.rows) }) }),
        insert: () => ({
            values: (values: Record<string, unknown>) => {
                state.inserted.push(values);
                return chain([{ id: "created-1", ...values }]);
            },
        }),
        update: () => ({ set: () => ({ where: () => chain([]) }) }),
        delete: () => ({ where: () => chain([]) }),
    },
}));

const { POST: postHabitLog } = await import("@/app/api/habits/logs/route");
const { POST: postJobContact } = await import("@/app/api/jobs/contacts/route");
const { POST: postProjectTask } = await import("@/app/api/projects/tasks/route");
const { PUT: putBug } = await import("@/app/api/bugs/route");

const USER_ID = "11111111-1111-1111-1111-111111111111";
const OTHER_ID = "99999999-9999-9999-9999-999999999999";

function authToken(userId = USER_ID) {
    return jwt.sign({ userId, email: "test@example.com", role: "user" }, SECRET, { expiresIn: "5m" });
}

function request(url: string, body: unknown, method = "POST", withToken = true) {
    const headers: Record<string, string> = { "Content-Type": "application/json" };
    if (withToken) headers.Authorization = `Bearer ${authToken()}`;
    return new Request(url, { method, headers, body: JSON.stringify(body) });
}

describe("route auth + ownership guards", () => {
    beforeEach(() => {
        state.rows = [];
        state.inserted = [];
    });

    it("rejects requests without a bearer token", async () => {
        const res = await postHabitLog(
            request("http://localhost/api/habits/logs", { habitId: OTHER_ID, logDate: "2026-10-18" }, "POST", false) as never
        );

        expect(res.status).toBe(401);
        await expect(res.json()).resolves.toMatchObject({ error: "Unauthorized" });
    });

    it("refuses to log a habit owned by another user", async () => {
        state.rows = [];

        const res = await postHabitLog(
            request("http://localhost/api/habits/logs", { habitId: OTHER_ID, logDate: "2026-10-18" }) as never
        );

        expect(res.status).toBe(404);
        expect(state.inserted).toHaveLength(0);
    });

    it("logs a habit the user owns", async () => {
        state.rows = [{ id: OTHER_ID }];

        const res = await postHabitLog(
            request("http://localhost/api/habits/logs", { habitId: OTHER_ID, logDate: "2026-10-18" }) as never
        );

        expect(res.status).toBe(201);
        expect(state.inserted[0]).toMatchObject({ habitId: OTHER_ID, logDate: "2026-10-18" });
    });

    it("refuses contacts and tasks that reference another user's parent", async () => {
        state.rows = [];

        const contact = await postJobContact(
            request("http://localhost/api/jobs/contacts", { jobId: OTHER_ID, name: "Recruiter" }) as never
        );
        const task = await postProjectTask(
            request("http://localhost/api/projects/tasks", { projectId: OTHER_ID, title: "Task" }) as never
        );

        expect(contact.status).toBe(404);
        expect(task.status).toBe(404);
        expect(state.inserted).toHaveLength(0);
    });

    it("rejects an invalid update body on the id-parameter contract", async () => {
        const res = await putBug(
            request(`http://localhost/api/bugs?id=${OTHER_ID}`, { title: "" }, "PUT") as never
        );

        expect(res.status).toBe(400);
        await expect(res.json()).resolves.toMatchObject({ error: "Invalid request data" });
    });

    it("rejects a timezone that would break day/month boundaries", async () => {
        const { PUT: putProfile } = await import("@/app/api/profile/route");

        const invalid = await putProfile(
            request("http://localhost/api/profile", { timezone: "WIB" }, "PUT") as never
        );
        const valid = await putProfile(
            request("http://localhost/api/profile", { timezone: "Asia/Jakarta" }, "PUT") as never
        );

        expect(invalid.status).toBe(400);
        // The mocked db returns no rows, so a valid body falls through to 404 —
        // what matters is that the schema did not reject it.
        expect(valid.status).not.toBe(400);
    });
});
