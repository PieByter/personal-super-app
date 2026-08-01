"use client";

import { useEffect, useState } from "react";

interface SystemStats {
    totalUsers: number;
    totalTransactions: number;
    totalProjects: number;
    totalTasks: number;
    totalHabits: number;
    totalJobs: number;
    totalBugs: number;
    totalSubscriptions: number;
}

interface DashboardResponse {
    isAdmin: boolean;
    systemStats: SystemStats;
}

export default function AdminDashboard() {
    const [data, setData] = useState<DashboardResponse | null>(null);
    const [loading, setLoading] = useState(true);
    const [error, setError] = useState<string | null>(null);
    const [token, setToken] = useState("");

    useEffect(() => {
        const stored = localStorage.getItem("admin_token");
        if (stored) {
            setToken(stored);
            fetchDashboard(stored);
        } else {
            setLoading(false);
        }
    }, []);

    async function fetchDashboard(authToken: string) {
        try {
            const res = await fetch("/api/dashboard", {
                headers: { Authorization: `Bearer ${authToken}` },
            });
            if (!res.ok) {
                if (res.status === 401) {
                    localStorage.removeItem("admin_token");
                    setToken("");
                    setError("Unauthorized. Please login again.");
                    setLoading(false);
                    return;
                }
                throw new Error(`HTTP ${res.status}`);
            }
            const json = await res.json();
            if (!json.isAdmin) {
                setError("Access denied. Admin only.");
                setLoading(false);
                return;
            }
            setData(json);
            setError(null);
        } catch (e) {
            setError(e instanceof Error ? e.message : "Failed to load");
        } finally {
            setLoading(false);
        }
    }

    async function handleLogin(e: React.FormEvent) {
        e.preventDefault();
        const form = e.target as HTMLFormElement;
        const email = (form.elements.namedItem("email") as HTMLInputElement).value;
        const password = (form.elements.namedItem("password") as HTMLInputElement).value;

        try {
            const res = await fetch("/api/auth", {
                method: "POST",
                headers: { "Content-Type": "application/json" },
                body: JSON.stringify({ action: "login", email, password }),
            });
            const json = await res.json();
            if (json.token) {
                localStorage.setItem("admin_token", json.token);
                setToken(json.token);
                fetchDashboard(json.token);
            } else {
                setError(json.error || "Login failed");
            }
        } catch (e) {
            setError(e instanceof Error ? e.message : "Login failed");
        }
    }

    function handleLogout() {
        localStorage.removeItem("admin_token");
        setToken("");
        setData(null);
        setError(null);
    }

    if (loading) {
        return (
            <div style={styles.container}>
                <div style={styles.loading}>Loading...</div>
            </div>
        );
    }

    if (!token) {
        return (
            <div style={styles.container}>
                <div style={styles.card}>
                    <h1 style={styles.title}>Admin Login</h1>
                    {error && <div style={styles.error}>{error}</div>}
                    <form onSubmit={handleLogin} style={styles.form}>
                        <input name="email" type="email" placeholder="Email" required style={styles.input} />
                        <input name="password" type="password" placeholder="Password" required style={styles.input} />
                        <button type="submit" style={styles.button}>Login</button>
                    </form>
                </div>
            </div>
        );
    }

    if (error) {
        return (
            <div style={styles.container}>
                <div style={styles.card}>
                    <h1 style={styles.title}>Admin Dashboard</h1>
                    <div style={styles.error}>{error}</div>
                    <button onClick={handleLogout} style={styles.button}>Logout</button>
                </div>
            </div>
        );
    }

    const stats = data?.systemStats;
    if (!stats) return null;

    const statCards = [
        { label: "Users", value: stats.totalUsers, color: "#64748B" },
        { label: "Transactions", value: stats.totalTransactions, color: "#10B981" },
        { label: "Projects", value: stats.totalProjects, color: "#8B5CF6" },
        { label: "Tasks", value: stats.totalTasks, color: "#3B82F6" },
        { label: "Habits", value: stats.totalHabits, color: "#F59E0B" },
        { label: "Jobs", value: stats.totalJobs, color: "#3B82F6" },
        { label: "Bugs", value: stats.totalBugs, color: "#EF4444" },
        { label: "Subscriptions", value: stats.totalSubscriptions, color: "#EC4899" },
    ];

    return (
        <div style={styles.container}>
            <div style={styles.header}>
                <h1 style={styles.title}>Admin Dashboard</h1>
                <button onClick={handleLogout} style={styles.logoutBtn}>Logout</button>
            </div>

            <div style={styles.grid}>
                {statCards.map((s) => (
                    <div key={s.label} style={{ ...styles.statCard, borderLeft: `4px solid ${s.color}` }}>
                        <div style={styles.statValue}>{s.value}</div>
                        <div style={styles.statLabel}>{s.label}</div>
                    </div>
                ))}
            </div>

            <div style={styles.section}>
                <h2 style={styles.sectionTitle}>Quick Actions</h2>
                <div style={styles.actions}>
                    <button style={styles.actionBtn}>Manage Users</button>
                    <button style={styles.actionBtn}>System Settings</button>
                    <button style={styles.actionBtn}>View Reports</button>
                </div>
            </div>
        </div>
    );
}

const styles: Record<string, React.CSSProperties> = {
    container: {
        maxWidth: 1200,
        margin: "0 auto",
        padding: 32,
        fontFamily: "system-ui, -apple-system, sans-serif",
    },
    header: {
        display: "flex",
        justifyContent: "space-between",
        alignItems: "center",
        marginBottom: 32,
    },
    title: {
        fontSize: 28,
        fontWeight: 700,
        margin: 0,
        color: "#1e293b",
    },
    loading: {
        textAlign: "center",
        padding: 64,
        fontSize: 18,
        color: "#64748b",
    },
    card: {
        maxWidth: 400,
        margin: "64px auto",
        padding: 32,
        borderRadius: 12,
        background: "#fff",
        boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)",
    },
    error: {
        color: "#dc2626",
        marginBottom: 16,
        fontSize: 14,
    },
    form: {
        display: "flex",
        flexDirection: "column",
        gap: 12,
    },
    input: {
        padding: "12px 16px",
        borderRadius: 8,
        border: "1px solid #e2e8f0",
        fontSize: 14,
    },
    button: {
        padding: "12px 16px",
        borderRadius: 8,
        border: "none",
        background: "#6366f1",
        color: "#fff",
        fontSize: 14,
        fontWeight: 600,
        cursor: "pointer",
    },
    logoutBtn: {
        padding: "8px 16px",
        borderRadius: 8,
        border: "1px solid #e2e8f0",
        background: "#fff",
        color: "#64748b",
        fontSize: 14,
        cursor: "pointer",
    },
    grid: {
        display: "grid",
        gridTemplateColumns: "repeat(auto-fill, minmax(220px, 1fr))",
        gap: 16,
        marginBottom: 32,
    },
    statCard: {
        padding: 20,
        borderRadius: 8,
        background: "#fff",
        boxShadow: "0 1px 3px 0 rgb(0 0 0 / 0.1)",
    },
    statValue: {
        fontSize: 32,
        fontWeight: 700,
        color: "#1e293b",
        marginBottom: 4,
    },
    statLabel: {
        fontSize: 14,
        color: "#64748b",
        textTransform: "uppercase",
        letterSpacing: 0.5,
    },
    section: {
        marginTop: 16,
    },
    sectionTitle: {
        fontSize: 20,
        fontWeight: 600,
        marginBottom: 16,
        color: "#1e293b",
    },
    actions: {
        display: "flex",
        gap: 12,
        flexWrap: "wrap",
    },
    actionBtn: {
        padding: "12px 24px",
        borderRadius: 8,
        border: "1px solid #e2e8f0",
        background: "#fff",
        color: "#334155",
        fontSize: 14,
        cursor: "pointer",
    },
};
