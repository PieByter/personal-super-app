import { ZodError } from "zod";

/**
 * Sanitized API error response.
 * - Zod validation errors: return a generic message + safe field messages (no internals).
 * - Any other error: return a generic 500 without leaking internal details.
 */
export function apiError(error: unknown) {
    if (error instanceof ZodError) {
        return Response.json(
            {
                error: "Invalid request data",
                details: error.issues.map((issue) => issue.message),
            },
            { status: 400 }
        );
    }
    return Response.json({ error: "Internal server error" }, { status: 500 });
}
