"use client";

import { useEffect, useState } from "react";
import { s, statCardStyle } from "@/lib/admin-styles";

interface ReportData {
  label: string;
  value: number;
}

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

export default function AdminReportsPage() {
  const [stats, setStats] = useState<SystemStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    fetchStats();
  }, []);

  async function fetchStats() {
    try {
      const token = localStorage.getItem("admin_token") || "";
      const res = await fetch("/api/dashboard", {
        headers: { Authorization: `Bearer ${token}` },
      });
      if (res.status === 401 || res.status === 403) {
        setError("Access denied. Admin only.");
        setLoading(false);
        return;
      }
      const json = await res.json();
      if (!json.isAdmin) {
        setError("Access denied. Admin only.");
        setLoading(false);
        return;
      }
      setStats(json.systemStats);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to load");
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <div style={s.loading}>Loading reports...</div>;

  const reportCards = stats
    ? [
        { label: "Total Users", value: stats.totalUsers, color: "#64748B", icon: "👥" },
        { label: "Transactions", value: stats.totalTransactions, color: "#10B981", icon: "💳" },
        { label: "Projects", value: stats.totalProjects, color: "#8B5CF6", icon: "📁" },
        { label: "Tasks", value: stats.totalTasks, color: "#3B82F6", icon: "✅" },
        { label: "Habits", value: stats.totalHabits, color: "#F59E0B", icon: "🔄" },
        { label: "Jobs", value: stats.totalJobs, color: "#3B82F6", icon: "💼" },
        { label: "Bugs", value: stats.totalBugs, color: "#EF4444", icon: "🐛" },
        { label: "Subscriptions", value: stats.totalSubscriptions, color: "#EC4899", icon: "📦" },
      ]
    : [];

  const totalActivities =
    stats
      ? stats.totalTransactions +
        stats.totalProjects +
        stats.totalTasks +
        stats.totalHabits +
        stats.totalJobs +
        stats.totalBugs
      : 0;

  return (
    <div>
      <div style={s.topBar}>
        <h1 style={s.pageTitle}>📈 Reports & Analytics</h1>
        <span style={{ fontSize: 14, color: "#64748b" }}>
          {new Date().toLocaleDateString("en-US", { year: "numeric", month: "long", day: "numeric" })}
        </span>
      </div>
      <div style={s.content}>
        {error && <div style={s.error}>{error}</div>}
        {stats && (
          <>
            {/* Stat Cards */}
            <div style={s.grid}>
              {reportCards.map((card) => (
                <div key={card.label} style={statCardStyle(card.color)}>
                  <div style={{ fontSize: 24, marginBottom: 8 }}>{card.icon}</div>
                  <div style={s.statValue}>{card.value.toLocaleString()}</div>
                  <div style={s.statLabel}>{card.label}</div>
                </div>
              ))}
            </div>

            {/* Summary Section */}
            <div style={s.card}>
              <h2 style={s.cardTitle}>System Health</h2>
              <div style={{ display: "grid", gridTemplateColumns: "repeat(auto-fit, minmax(200px, 1fr))", gap: 16 }}>
                <HealthMetric label="Total Activities" value={totalActivities.toLocaleString()} color="#6366f1" />
                <HealthMetric
                  label="Avg per User"
                  value={stats.totalUsers > 0 ? Math.round(totalActivities / stats.totalUsers).toLocaleString() : "0"}
                  color="#10b981"
                />
                <HealthMetric
                  label="User Engagement"
                  value={stats.totalUsers > 0 ? `${Math.round((stats.totalHabits / stats.totalUsers) * 100)}%` : "0%"}
                  color="#f59e0b"
                />
                <HealthMetric label="Active Subscriptions" value={stats.totalSubscriptions.toLocaleString()} color="#ec4899" />
              </div>
            </div>

            {/* Activity Breakdown */}
            <div style={s.card}>
              <h2 style={s.cardTitle}>Activity Distribution</h2>
              <div style={{ display: "flex", flexDirection: "column", gap: 12 }}>
                {reportCards
                  .filter((c) => c.label !== "Total Users" && c.label !== "Subscriptions")
                  .map((card) => {
                    const pct = totalActivities > 0 ? (card.value / totalActivities) * 100 : 0;
                    return (
                      <div key={card.label}>
                        <div style={{ display: "flex", justifyContent: "space-between", marginBottom: 4 }}>
                          <span style={{ fontSize: 13, color: "#475569" }}>{card.label}</span>
                          <span style={{ fontSize: 13, fontWeight: 600, color: card.color }}>
                            {card.value} ({pct.toFixed(1)}%)
                          </span>
                        </div>
                        <div style={{ height: 8, borderRadius: 4, background: "#f1f5f9" }}>
                          <div
                            style={{
                              height: "100%",
                              borderRadius: 4,
                              background: card.color,
                              width: `${Math.max(pct, 2)}%`,
                              transition: "width 0.5s",
                            }}
                          />
                        </div>
                      </div>
                    );
                  })}
              </div>
            </div>
          </>
        )}
      </div>
    </div>
  );
}

function HealthMetric({ label, value, color }: { label: string; value: string; color: string }) {
  return (
    <div
      style={{
        padding: 16,
        borderRadius: 8,
        background: "#f8fafc",
        borderLeft: `3px solid ${color}`,
      }}
    >
      <div style={{ fontSize: 24, fontWeight: 700, color: "#1e293b" }}>{value}</div>
      <div style={{ fontSize: 13, color: "#64748b" }}>{label}</div>
    </div>
  );
}
