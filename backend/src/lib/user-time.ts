/**
 * Date-only helpers anchored to a user's timezone.
 *
 * The API stores calendar data as plain `YYYY-MM-DD` strings, so "today",
 * "this month" and "N days ago" must be resolved in the user's timezone —
 * using the server clock shifts them by up to a day for users in other zones.
 */

const FALLBACK_TIMEZONE = "UTC";

export function isValidTimeZone(timeZone: string | null | undefined): timeZone is string {
    if (!timeZone) return false;
    try {
        new Intl.DateTimeFormat("en-US", { timeZone });
        return true;
    } catch {
        return false;
    }
}

/** `YYYY-MM-DD` for the moment `at`, as seen in `timeZone`. */
export function dateInTimeZone(timeZone: string | null | undefined, at: Date = new Date()): string {
    // en-CA renders as YYYY-MM-DD.
    return new Intl.DateTimeFormat("en-CA", {
        timeZone: isValidTimeZone(timeZone) ? timeZone : FALLBACK_TIMEZONE,
        year: "numeric",
        month: "2-digit",
        day: "2-digit",
    }).format(at);
}

/** Today's date in `timeZone`. */
export function todayInTimeZone(timeZone: string | null | undefined, at: Date = new Date()): string {
    return dateInTimeZone(timeZone, at);
}

/** First day of the current month in `timeZone`. */
export function monthStartInTimeZone(timeZone: string | null | undefined, at: Date = new Date()): string {
    return `${todayInTimeZone(timeZone, at).slice(0, 7)}-01`;
}

/**
 * Adds calendar days to a date-only string. Timezone-free on purpose: once the
 * day boundary is resolved in the user's zone, calendar arithmetic is exact.
 */
export function addDays(date: string, days: number): string {
    const d = new Date(`${date}T00:00:00Z`);
    d.setUTCDate(d.getUTCDate() + days);
    return d.toISOString().split("T")[0];
}
