import { describe, it, expect, beforeEach, afterEach, vi } from "vitest";

const state = vi.hoisted(() => ({
    rules: [] as Record<string, unknown>[],
    users: [] as Record<string, unknown>[],
    inserted: [] as Record<string, unknown>[],
    updates: [] as Record<string, unknown>[],
}));

vi.mock("@/db", async () => {
    const schema = await import("@/db/schema");
    return {
        db: {
            select: () => ({
                from: (table: unknown) => ({
                    where: () =>
                        Promise.resolve(table === schema.users ? state.users : state.rules),
                }),
            }),
            insert: () => ({
                values: (values: Record<string, unknown>) => ({
                    returning: () => {
                        state.inserted.push(values);
                        return Promise.resolve([{ id: `tx-${state.inserted.length}`, ...values }]);
                    },
                }),
            }),
            update: () => ({
                set: (values: Record<string, unknown>) => ({
                    where: () => {
                        state.updates.push(values);
                        return Promise.resolve([]);
                    },
                }),
            }),
        },
    };
});

const { processDueRules } = await import("./recurring");

function rule(overrides: Record<string, unknown> = {}) {
    return {
        id: "rule-1",
        userId: "user-1",
        categoryId: null,
        amount: "100.00",
        type: "expense",
        frequency: "monthly",
        interval: 1,
        description: null,
        nextExecution: "2026-10-01",
        endDate: null,
        isActive: true,
        ...overrides,
    };
}

describe("processDueRules", () => {
    beforeEach(() => {
        state.rules = [];
        state.users = [];
        state.inserted = [];
        state.updates = [];
    });

    afterEach(() => {
        vi.useRealTimers();
    });

    it("creates a transaction and advances nextExecution for an open-ended rule", async () => {
        state.rules = [rule()];

        const created = await processDueRules("user-1");

        expect(created).toHaveLength(1);
        expect(state.inserted[0]).toMatchObject({
            userId: "user-1",
            amount: "100.00",
            transactionDate: "2026-10-01",
            isRecurring: true,
        });
        expect(state.updates).toEqual([{ nextExecution: "2026-11-01" }]);
    });

    it("advances to endDate (inclusive) and only then deactivates", async () => {
        state.rules = [rule({ nextExecution: "2026-09-01", endDate: "2026-10-01" })];

        await processDueRules("user-1");

        expect(state.inserted).toHaveLength(1);
        expect(state.updates).toEqual([{ nextExecution: "2026-10-01" }]);
    });

    it("deactivates when the occurrence falls on endDate (no repeat next run)", async () => {
        state.rules = [rule({ nextExecution: "2026-10-01", endDate: "2026-10-01" })];

        await processDueRules("user-1");

        expect(state.inserted).toHaveLength(1);
        // The rule must not stay due (that would regenerate the same
        // transaction on every run).
        expect(state.updates).toEqual([{ isActive: false }]);
        expect(state.updates.some((u) => "nextExecution" in u)).toBe(false);
    });

    it("skips rules that already ended without creating transactions", async () => {
        state.rules = [rule({ nextExecution: "2026-10-01", endDate: "2026-09-01" })];

        const created = await processDueRules("user-1");

        expect(created).toHaveLength(0);
        expect(state.updates).toEqual([{ isActive: false }]);
    });

    it("uses each owner's timezone to decide whether a rule is due", async () => {
        // 22:30 UTC is already the 19th in Jakarta, still the 18th in Los Angeles.
        vi.useFakeTimers();
        vi.setSystemTime(new Date("2026-10-18T22:30:00Z"));

        state.rules = [
            rule({ id: "rule-jkt", userId: "user-jkt", nextExecution: "2026-10-19" }),
            rule({ id: "rule-la", userId: "user-la", nextExecution: "2026-10-19" }),
        ];
        state.users = [
            { id: "user-jkt", timezone: "Asia/Jakarta" },
            { id: "user-la", timezone: "America/Los_Angeles" },
        ];

        const created = await processDueRules(null);

        expect(created).toHaveLength(1);
        expect(state.inserted).toHaveLength(1);
        expect(state.inserted[0].userId).toBe("user-jkt");
        // The LA rule stays untouched and is picked up on a later run.
        expect(state.updates).toEqual([{ nextExecution: "2026-11-19" }]);
    });
});
