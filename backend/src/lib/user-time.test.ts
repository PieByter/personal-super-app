import { describe, it, expect } from "vitest";
import {
    addDays,
    dateInTimeZone,
    isValidTimeZone,
    monthStartInTimeZone,
    todayInTimeZone,
} from "./user-time";

// 2026-10-18T22:30:00Z is already the 19th in Jakarta (UTC+7).
const lateEveningUtc = new Date("2026-10-18T22:30:00Z");

describe("user-time", () => {
    it("resolves the day boundary in the user's timezone, not the server's", () => {
        expect(dateInTimeZone("UTC", lateEveningUtc)).toBe("2026-10-18");
        expect(dateInTimeZone("Asia/Jakarta", lateEveningUtc)).toBe("2026-10-19");
        expect(dateInTimeZone("America/Los_Angeles", lateEveningUtc)).toBe("2026-10-18");
        expect(dateInTimeZone("Pacific/Kiritimati", lateEveningUtc)).toBe("2026-10-19");
    });

    it("starts the month in the user's timezone", () => {
        // 2026-11-01T02:00Z is already November in Jakarta, still October in LA.
        const acrossMonthBoundary = new Date("2026-11-01T02:00:00Z");
        expect(monthStartInTimeZone("Asia/Jakarta", acrossMonthBoundary)).toBe("2026-11-01");
        expect(monthStartInTimeZone("UTC", acrossMonthBoundary)).toBe("2026-11-01");
        expect(monthStartInTimeZone("America/Los_Angeles", acrossMonthBoundary)).toBe("2026-10-01");
    });

    it("falls back to UTC for missing or invalid timezones", () => {
        expect(isValidTimeZone("Asia/Jakarta")).toBe(true);
        expect(isValidTimeZone("Mars/Olympus")).toBe(false);
        expect(isValidTimeZone(null)).toBe(false);
        expect(dateInTimeZone("Mars/Olympus", lateEveningUtc)).toBe("2026-10-18");
        expect(todayInTimeZone(undefined, lateEveningUtc)).toBe("2026-10-18");
    });

    it("adds calendar days across month and year boundaries", () => {
        expect(addDays("2026-10-18", 1)).toBe("2026-10-19");
        expect(addDays("2026-10-18", -7)).toBe("2026-10-11");
        expect(addDays("2026-10-01", -1)).toBe("2026-09-30");
        expect(addDays("2026-12-31", 1)).toBe("2027-01-01");
        expect(addDays("2026-03-01", -1)).toBe("2026-02-28");
    });
});
