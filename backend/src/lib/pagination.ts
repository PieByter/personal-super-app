import { NextRequest } from "next/server";

export interface PaginationParams {
    page: number;
    pageSize: number;
    offset: number;
    enabled: boolean;
}

/**
 * Parses pagination query params from a request.
 * Pagination is only enabled when `page` is provided.
 * Without it, the endpoint returns the full list (backward compatible).
 */
export function getPagination(req: NextRequest, defaultPageSize = 20): PaginationParams {
    const searchParams = new URL(req.url).searchParams;
    const pageParam = searchParams.get("page");
    if (!pageParam) {
        return { page: 1, pageSize: defaultPageSize, offset: 0, enabled: false };
    }
    const page = Math.max(1, parseInt(pageParam, 10) || 1);
    const pageSize = Math.min(
        100,
        Math.max(1, parseInt(searchParams.get("pageSize") || String(defaultPageSize), 10) || defaultPageSize)
    );
    return { page, pageSize, offset: (page - 1) * pageSize, enabled: true };
}

/**
 * Wraps a full result set into a paginated response when pagination is enabled,
 * otherwise returns the raw array (backward compatible).
 */
export function paginateResponse<T>(
    rows: T[],
    total: number,
    pagination: PaginationParams
): T[] | { data: T[]; total: number; page: number; pageSize: number; totalPages: number } {
    if (!pagination.enabled) {
        return rows;
    }
    return {
        data: rows,
        total,
        page: pagination.page,
        pageSize: pagination.pageSize,
        totalPages: Math.ceil(total / pagination.pageSize),
    };
}
