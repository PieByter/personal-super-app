import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { verifyToken } from "./lib/auth";

const PUBLIC_PATHS = ["/api/auth"];

// CORS headers. The app uses Bearer tokens (not cookies), so allowing any
// origin is safe here — the browser only sends the token when the Flutter
// app explicitly sets the Authorization header.
const CORS_HEADERS: Record<string, string> = {
    "Access-Control-Allow-Origin": "*",
    "Access-Control-Allow-Methods": "GET, POST, PUT, DELETE, OPTIONS",
    "Access-Control-Allow-Headers": "Content-Type, Authorization",
    "Access-Control-Max-Age": "86400",
};

function withCors(response: NextResponse): NextResponse {
    for (const [key, value] of Object.entries(CORS_HEADERS)) {
        response.headers.set(key, value);
    }
    return response;
}

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    // Handle CORS preflight requests.
    if (request.method === "OPTIONS") {
        return withCors(new NextResponse(null, { status: 204 }));
    }

    if (PUBLIC_PATHS.some((path) => pathname.startsWith(path))) {
        return withCors(NextResponse.next());
    }

    const authHeader = request.headers.get("authorization");
    if (!authHeader?.startsWith("Bearer ")) {
        return withCors(
            NextResponse.json({ error: "Unauthorized" }, { status: 401 })
        );
    }

    try {
        const token = authHeader.substring(7);
        verifyToken(token);
        return withCors(NextResponse.next());
    } catch {
        return withCors(
            NextResponse.json({ error: "Invalid token" }, { status: 401 })
        );
    }
}

export const config = {
    matcher: "/api/:path*",
};
