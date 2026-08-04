"use client";

import { useEffect, useState } from "react";
import { usePathname, useRouter } from "next/navigation";
import { s, sidebarLinkStyle, btnStyle } from "@/lib/admin-styles";

const navItems = [
  { label: "Dashboard", href: "/admin", icon: "📊" },
  { label: "Manage Users", href: "/admin/users", icon: "👥" },
  { label: "Settings", href: "/admin/settings", icon: "⚙️" },
  { label: "Reports", href: "/admin/reports", icon: "📈" },
];

export default function AdminLayout({ children }: { children: React.ReactNode }) {
  const pathname = usePathname();
  const router = useRouter();
  const [authenticated, setAuthenticated] = useState<boolean | null>(null);
  const [loginError, setLoginError] = useState<string | null>(null);

  useEffect(() => {
    const token = localStorage.getItem("admin_token");
    setAuthenticated(!!token);
  }, []);

  function isActive(href: string) {
    if (href === "/admin") return pathname === "/admin";
    return pathname.startsWith(href);
  }

  function handleLogout() {
    localStorage.removeItem("admin_token");
    setAuthenticated(false);
    router.push("/admin");
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
        setAuthenticated(true);
        setLoginError(null);
      } else {
        setLoginError(json.error || "Login failed. Only admin accounts can access.");
      }
    } catch (e) {
      setLoginError(e instanceof Error ? e.message : "Login failed");
    }
  }

  // Still checking auth
  if (authenticated === null) {
    return (
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", minHeight: "100vh", fontFamily: "system-ui, -apple-system, sans-serif", background: "#f1f5f9" }}>
        <div style={{ textAlign: "center", color: "#64748b", fontSize: 16 }}>Loading...</div>
      </div>
    );
  }

  // Not authenticated — show login form
  if (!authenticated) {
    return (
      <div style={{ display: "flex", alignItems: "center", justifyContent: "center", minHeight: "100vh", fontFamily: "system-ui, -apple-system, sans-serif", background: "#f1f5f9" }}>
        <div style={{ maxWidth: 400, width: "100%", padding: 32, borderRadius: 12, background: "#fff", boxShadow: "0 4px 6px -1px rgb(0 0 0 / 0.1)" }}>
          <div style={{ textAlign: "center", marginBottom: 24 }}>
            <div style={{ fontSize: 40, marginBottom: 8 }}>⚡</div>
            <h1 style={{ fontSize: 24, fontWeight: 700, color: "#1e293b", margin: 0 }}>Admin Login</h1>
            <p style={{ fontSize: 14, color: "#64748b", marginTop: 8 }}>Only admin accounts can access this area.</p>
          </div>
          {loginError && (
            <div style={{ padding: "10px 14px", borderRadius: 6, background: "#fef2f2", color: "#dc2626", fontSize: 13, marginBottom: 16 }}>
              {loginError}
            </div>
          )}
          <form onSubmit={handleLogin} style={{ display: "flex", flexDirection: "column", gap: 12 }}>
            <input
              name="email"
              type="email"
              placeholder="Email"
              required
              style={{ padding: "12px 14px", borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 14 }}
            />
            <input
              name="password"
              type="password"
              placeholder="Password"
              required
              style={{ padding: "12px 14px", borderRadius: 8, border: "1px solid #e2e8f0", fontSize: 14 }}
            />
            <button type="submit" style={{ padding: "12px", borderRadius: 8, border: "none", background: "#6366f1", color: "#fff", fontSize: 14, fontWeight: 600, cursor: "pointer" }}>
              Sign In
            </button>
          </form>
          <div style={{ marginTop: 16, textAlign: "center" }}>
            <a href="/" style={{ color: "#6366f1", fontSize: 13, textDecoration: "none" }}>← Back to App</a>
          </div>
        </div>
      </div>
    );
  }

  // Authenticated — show layout with sidebar
  return (
    <div style={s.container}>
      <aside style={s.sidebar}>
        <div style={s.sidebarLogo}>⚡ Super Admin</div>
        <nav style={s.sidebarNav}>
          {navItems.map((item) => (
            <div
              key={item.href}
              style={sidebarLinkStyle(isActive(item.href))}
              onClick={() => router.push(item.href)}
            >
              <span>{item.icon}</span>
              <span>{item.label}</span>
            </div>
          ))}
        </nav>
        <div style={s.sidebarFooter}>
          <a href="/" style={{ color: "#94a3b8", fontSize: 13, textDecoration: "none" }}>
            ← Back to App
          </a>
          <div style={{ marginTop: 12 }}>
            <button onClick={handleLogout} style={btnStyle("secondary")}>
              🚪 Sign Out
            </button>
          </div>
        </div>
      </aside>
      <main style={s.main}>{children}</main>
    </div>
  );
}
