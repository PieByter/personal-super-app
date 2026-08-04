import type { CSSProperties } from "react";

// ============ Static styles ============

export const s: Record<string, CSSProperties> = {
    container: {
        display: "flex",
        minHeight: "100vh",
        fontFamily: "system-ui, -apple-system, sans-serif",
        background: "#f1f5f9",
    },
    sidebar: {
        width: 240,
        background: "#1e293b",
        color: "#e2e8f0",
        display: "flex",
        flexDirection: "column",
        padding: "24px 0",
        flexShrink: 0,
    },
    sidebarLogo: {
        fontSize: 16,
        fontWeight: 700,
        color: "#fff",
        padding: "0 20px 24px",
        borderBottom: "1px solid #334155",
        marginBottom: 16,
    },
    sidebarNav: { flex: 1 },
    sidebarFooter: { padding: "16px 20px 0", borderTop: "1px solid #334155" },
    main: { flex: 1, display: "flex", flexDirection: "column" },
    topBar: {
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        padding: "16px 32px",
        background: "#fff",
        borderBottom: "1px solid #e2e8f0",
    },
    pageTitle: { fontSize: 22, fontWeight: 700, color: "#1e293b", margin: 0 },
    content: { flex: 1, padding: 32, overflowY: "auto" as const },
    grid: {
        display: "grid",
        gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
        gap: 16,
        marginBottom: 32,
    },
    statValue: { fontSize: 32, fontWeight: 700, color: "#1e293b", marginBottom: 4 },
    statLabel: {
        fontSize: 14,
        color: "#64748b",
        textTransform: "uppercase" as const,
        letterSpacing: 0.5,
    },
    table: {
        width: "100%",
        borderCollapse: "collapse" as const,
        background: "#fff",
        borderRadius: 8,
        overflow: "hidden",
        boxShadow: "0 1px 3px 0 rgb(0 0 0 / 0.1)",
    },
    th: {
        textAlign: "left" as const,
        padding: "12px 16px",
        fontSize: 12,
        fontWeight: 600,
        color: "#64748b",
        textTransform: "uppercase" as const,
        letterSpacing: 0.5,
        borderBottom: "2px solid #e2e8f0",
        background: "#f8fafc",
    },
    td: {
        padding: "12px 16px",
        fontSize: 14,
        color: "#334155",
        borderBottom: "1px solid #f1f5f9",
    },
    formGroup: { marginBottom: 16 },
    label: {
        display: "block",
        fontSize: 13,
        fontWeight: 600,
        color: "#475569",
        marginBottom: 6,
    },
    input: {
        width: "100%",
        padding: "10px 14px",
        borderRadius: 6,
        border: "1px solid #e2e8f0",
        fontSize: 14,
        color: "#1e293b",
        background: "#fff",
        boxSizing: "border-box" as const,
    },
    select: {
        width: "100%",
        padding: "10px 14px",
        borderRadius: 6,
        border: "1px solid #e2e8f0",
        fontSize: 14,
        color: "#1e293b",
        background: "#fff",
        cursor: "pointer",
    },
    card: {
        background: "#fff",
        borderRadius: 8,
        padding: 24,
        boxShadow: "0 1px 3px 0 rgb(0 0 0 / 0.1)",
        marginBottom: 24,
    },
    cardTitle: { fontSize: 16, fontWeight: 600, color: "#1e293b", marginBottom: 16 },
    empty: { textAlign: "center" as const, padding: 48, color: "#94a3b8", fontSize: 15 },
    error: {
        padding: "12px 16px",
        borderRadius: 6,
        background: "#fef2f2",
        color: "#dc2626",
        fontSize: 13,
        marginBottom: 16,
    },
    loading: { textAlign: "center" as const, padding: 64, fontSize: 16, color: "#94a3b8" },
    flexRow: { display: "flex", alignItems: "center", gap: 12 },
    sectionTitle: { fontSize: 18, fontWeight: 600, marginBottom: 16, color: "#1e293b" },
    modalOverlay: {
        position: "fixed" as const,
        inset: 0,
        background: "rgba(0,0,0,0.5)",
        display: "flex",
        alignItems: "center",
        justifyContent: "center",
        zIndex: 100,
    },
    modal: {
        background: "#fff",
        borderRadius: 12,
        padding: 32,
        width: "100%",
        maxWidth: 500,
        maxHeight: "80vh",
        overflowY: "auto" as const,
        boxShadow: "0 20px 60px rgb(0 0 0 / 0.2)",
    },
    modalTitle: { fontSize: 18, fontWeight: 700, marginBottom: 20, color: "#1e293b" },
};

// ============ Dynamic style helpers ============

export function sidebarLinkStyle(active: boolean): CSSProperties {
    return {
        display: "flex",
        alignItems: "center",
        gap: 10,
        padding: "10px 20px",
        fontSize: 14,
        color: active ? "#fff" : "#94a3b8",
        background: active ? "rgba(99,102,241,0.3)" : "transparent",
        borderRight: active ? "3px solid #6366f1" : "3px solid transparent",
        cursor: "pointer",
        textDecoration: "none",
        transition: "all 0.15s",
    };
}

export function statCardStyle(color: string): CSSProperties {
    return {
        padding: 20,
        borderRadius: 8,
        background: "#fff",
        boxShadow: "0 1px 3px 0 rgb(0 0 0 / 0.1)",
        borderLeft: `4px solid ${color}`,
    };
}

export function btnStyle(variant: "primary" | "secondary" | "danger"): CSSProperties {
    const base: CSSProperties = {
        padding: "8px 16px",
        borderRadius: 6,
        border: "none",
        fontSize: 13,
        fontWeight: 600,
        cursor: "pointer",
        display: "inline-flex",
        alignItems: "center",
        gap: 6,
    };
    switch (variant) {
        case "primary":
            return { ...base, background: "#6366f1", color: "#fff" };
        case "danger":
            return { ...base, background: "#ef4444", color: "#fff" };
        default:
            return { ...base, background: "#fff", color: "#334155", border: "1px solid #e2e8f0" };
    }
}

export function badgeStyle(color: string): CSSProperties {
    return {
        display: "inline-block",
        padding: "2px 8px",
        borderRadius: 12,
        fontSize: 11,
        fontWeight: 600,
        background: `${color}20`,
        color,
        textTransform: "capitalize",
    };
}
