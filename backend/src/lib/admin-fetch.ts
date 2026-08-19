"use client";

/**
 * Client-side fetch helper for the admin area.
 * Stores both access + refresh tokens and transparently refreshes
 * the access token when it expires (401), then retries the request.
 */

const ACCESS_KEY = "admin_token";
const REFRESH_KEY = "admin_refresh_token";

export function getAdminToken(): string {
    return localStorage.getItem(ACCESS_KEY) || "";
}

export function clearAdminSession() {
    localStorage.removeItem(ACCESS_KEY);
    localStorage.removeItem(REFRESH_KEY);
}

export function setAdminSession(accessToken: string, refreshToken: string) {
    localStorage.setItem(ACCESS_KEY, accessToken);
    localStorage.setItem(REFRESH_KEY, refreshToken);
}

let refreshing: Promise<boolean> | null = null;

async function refreshAccessToken(): Promise<boolean> {
    if (refreshing) return refreshing;
    refreshing = (async () => {
        const refreshToken = localStorage.getItem(REFRESH_KEY);
        if (!refreshToken) return false;
        try {
            const res = await fetch("/api/auth/refresh", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ refreshToken }),
            });
            if (!res.ok) {
                clearAdminSession();
                return false;
            }
            const json = await res.json();
            localStorage.setItem(ACCESS_KEY, json.accessToken);
            localStorage.setItem(REFRESH_KEY, json.refreshToken);
            return true;
        } catch {
            clearAdminSession();
            return false;
        } finally {
            refreshing = null;
        }
    })();
    return refreshing;
}

export async function adminFetch(
    input: RequestInfo | URL,
    init?: RequestInit
): Promise<Response> {
    const token = getAdminToken();
    const headers = new Headers(init?.headers || {});
    if (token) headers.set("Authorization", `Bearer ${token}`);

    let res = await fetch(input, { ...init, headers });

    if (res.status === 401) {
        const ok = await refreshAccessToken();
        if (ok) {
            const newToken = getAdminToken();
            const retryHeaders = new Headers(init?.headers || {});
            if (newToken) retryHeaders.set("Authorization", `Bearer ${newToken}`);
            res = await fetch(input, { ...init, headers: retryHeaders });
        }
    }

    return res;
}
