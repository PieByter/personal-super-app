"use client";

import { useState } from "react";
import { s, btnStyle } from "@/lib/admin-styles";

export default function AdminSettingsPage() {
  const [saved, setSaved] = useState(false);

  function handleSave(e: React.FormEvent) {
    e.preventDefault();
    setSaved(true);
    setTimeout(() => setSaved(false), 2000);
  }

  return (
    <div>
      <div style={s.topBar}>
        <h1 style={s.pageTitle}>⚙️ System Settings</h1>
      </div>
      <div style={s.content}>
        <div style={s.card}>
          <h2 style={s.cardTitle}>General</h2>
          <form onSubmit={handleSave}>
            <div style={s.formGroup}>
              <label style={s.label}>App Name</label>
              <input style={s.input} defaultValue="Personal Super App" />
            </div>
            <div style={s.formGroup}>
              <label style={s.label}>Default Currency</label>
              <select style={s.select} defaultValue="IDR">
                <option value="IDR">IDR - Indonesian Rupiah</option>
                <option value="USD">USD - US Dollar</option>
                <option value="EUR">EUR - Euro</option>
                <option value="SGD">SGD - Singapore Dollar</option>
              </select>
            </div>
            <div style={s.formGroup}>
              <label style={s.label}>Default Timezone</label>
              <select style={s.select} defaultValue="Asia/Jakarta">
                <option value="Asia/Jakarta">Asia/Jakarta (WIB)</option>
                <option value="Asia/Singapore">Asia/Singapore</option>
                <option value="UTC">UTC</option>
                <option value="America/New_York">America/New York</option>
              </select>
            </div>
            <div style={s.formGroup}>
              <label style={s.label}>Items Per Page</label>
              <input style={s.input} type="number" defaultValue="20" />
            </div>
            <button type="submit" style={btnStyle("primary")}>
              {saved ? "✅ Saved!" : "💾 Save Settings"}
            </button>
          </form>
        </div>

        <div style={s.card}>
          <h2 style={s.cardTitle}>Security</h2>
          <div style={s.formGroup}>
            <label style={s.label}>JWT Secret</label>
            <input style={s.input} type="password" value="••••••••••••" readOnly />
            <span style={{ fontSize: 12, color: "#94a3b8", marginTop: 4, display: "block" }}>
              Set via JWT_SECRET environment variable
            </span>
          </div>
          <div style={s.formGroup}>
            <label style={s.label}>Session Expiry (days)</label>
            <select style={s.select} defaultValue="7">
              <option value="1">1 day</option>
              <option value="7">7 days</option>
              <option value="30">30 days</option>
              <option value="90">90 days</option>
            </select>
          </div>
        </div>

        <div style={s.card}>
          <h2 style={s.cardTitle}>Danger Zone</h2>
          <p style={{ fontSize: 14, color: "#64748b", marginBottom: 16 }}>
            These actions cannot be undone. Proceed with caution.
          </p>
          <div style={s.flexRow}>
            <button style={btnStyle("danger")} onClick={() => alert("Feature coming soon")}>
              🗑️ Reset All Data
            </button>
            <button style={btnStyle("secondary")} onClick={() => alert("Feature coming soon")}>
              📤 Export Database
            </button>
          </div>
        </div>
      </div>
    </div>
  );
}
