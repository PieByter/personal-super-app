import { NextResponse } from "next/server";
import type { NextRequest } from "next/server";
import { verifyToken } from "./lib/auth";

const PUBLIC_PATHS = ["/api/auth"];

export function middleware(request: NextRequest) {
    const { pathname } = request.nextUrl;

    if (PUBLIC_PATHS.some((path) => pathname.startsWith(path))) {
        return NextResponse.next();
    }

    const authHeader = request.headers.get("authorization");
    if (!authHeader?.startsWith("Bearer ")) {
        return NextResponse.json({ error: "Unauthorized" }, { status: 401 });
    }

    try {
        const token = authHeader.substring(7);
        verifyToken(token);
        return NextResponse.next();
    } catch {
        return NextResponse.json({ error: "Invalid token" }, { status: 401 });
    }
}

export const config = {
    matcher: "/api/:path*",
};
