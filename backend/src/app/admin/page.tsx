"use client";

import { useEffect, useState } from "react";
import { s, statCardStyle, btnStyle } from "@/lib/admin-styles";

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

export default function AdminDashboard() {
  const [stats, setStats] = useState<SystemStats | null>(null);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);

  useEffect(() => {
    const token = localStorage.getItem("admin_token");
    if (token) {
      fetchDashboard(token);
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
          window.location.href = "/admin";
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
      setStats(json.systemStats);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to load");
    } finally {
      setLoading(false);
    }
  }

  if (loading) return <div style={s.loading}>Loading dashboard...</div>;
  if (error) return <div style={{ padding: 64, textAlign: "center" }}><div style={s.error}>{error}</div></div>;
  if (!stats) return null;

  const statCards = [
    { label: "Users", value: stats.totalUsers, color: "#64748B", icon: "👥" },
    { label: "Transactions", value: stats.totalTransactions, color: "#10B981", icon: "💳" },
    { label: "Projects", value: stats.totalProjects, color: "#8B5CF6", icon: "📁" },
    { label: "Tasks", value: stats.totalTasks, color: "#3B82F6", icon: "✅" },
    { label: "Habits", value: stats.totalHabits, color: "#F59E0B", icon: "🔄" },
    { label: "Jobs", value: stats.totalJobs, color: "#3B82F6", icon: "💼" },
    { label: "Bugs", value: stats.totalBugs, color: "#EF4444", icon: "🐛" },
    { label: "Subscriptions", value: stats.totalSubscriptions, color: "#EC4899", icon: "📦" },
  ];

  const quickActions = [
    { label: "Manage Users", href: "/admin/users", icon: "👥", variant: "primary" as const },
    { label: "View Reports", href: "/admin/reports", icon: "📈", variant: "primary" as const },
    { label: "Settings", href: "/admin/settings", icon: "⚙️", variant: "secondary" as const },
  ];

  return (
    <div>
      <div style={s.topBar}>
        <h1 style={s.pageTitle}>📊 Dashboard</h1>
        <span style={{ fontSize: 14, color: "#64748b" }}>
          {new Date().toLocaleDateString("en-US", { weekday: "long", year: "numeric", month: "long", day: "numeric" })}
        </span>
      </div>
      <div style={s.content}>
        <h2 style={s.sectionTitle}>System Overview</h2>
        <div style={s.grid}>
          {statCards.map((card) => (
            <div key={card.label} style={statCardStyle(card.color)}>
              <div style={{ fontSize: 24, marginBottom: 8 }}>{card.icon}</div>
              <div style={s.statValue}>{card.value.toLocaleString()}</div>
              <div style={s.statLabel}>{card.label}</div>
            </div>
          ))}
        </div>

        <h2 style={s.sectionTitle}>Quick Actions</h2>
        <div style={s.flexRow}>
          {quickActions.map((action) => (
            <a key={action.href} href={action.href} style={{ textDecoration: "none" }}>
              <button style={btnStyle(action.variant)}>
                {action.icon} {action.label}
              </button>
            </a>
          ))}
        </div>
      </div>
    </div>
  );
}
