/**
 * Connection strings copied from Supabase's dashboard can carry parameters that
 * belong to other clients (`pgbouncer`, `connection_limit`, `pool_timeout`,
 * `schema` are Prisma-only). postgres.js forwards unknown query parameters as
 * PostgreSQL startup parameters, which Supavisor/pgbouncer rejects with
 * "unsupported startup parameter".
 *
 * Known parameters such as `sslmode` are intentionally kept: postgres.js
 * translates those itself.
 */
const CLIENT_ONLY_PARAMS = [
    "pgbouncer",
    "connection_limit",
    "pool_timeout",
    "schema",
    "statement_cache_size",
];

export function normalizeDatabaseUrl(connectionString: string): string {
    let url: URL;
    try {
        url = new URL(connectionString);
    } catch {
        return connectionString; // not a URL we understand — leave it untouched
    }

    let changed = false;
    for (const param of CLIENT_ONLY_PARAMS) {
        if (url.searchParams.has(param)) {
            url.searchParams.delete(param);
            changed = true;
        }
    }

    // Only rewrite when something was removed, so exotic (e.g. multi-host)
    // connection strings are passed through byte-for-byte.
    return changed ? url.toString() : connectionString;
}
