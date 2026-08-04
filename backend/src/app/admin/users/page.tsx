"use client";

import { useEffect, useState } from "react";
import { s, badgeStyle, btnStyle } from "@/lib/admin-styles";

interface UserRecord {
  id: string;
  email: string;
  fullName: string | null;
  role: string;
  timezone: string;
  currency: string;
  createdAt: string;
}

export default function AdminUsersPage() {
  const [users, setUsers] = useState<UserRecord[]>([]);
  const [loading, setLoading] = useState(true);
  const [error, setError] = useState<string | null>(null);
  const [editUser, setEditUser] = useState<UserRecord | null>(null);

  useEffect(() => {
    fetchUsers();
  }, []);

  function getToken() {
    return localStorage.getItem("admin_token") || "";
  }

  async function fetchUsers() {
    setLoading(true);
    try {
      const res = await fetch("/api/admin/users", {
        headers: { Authorization: `Bearer ${getToken()}` },
      });
      if (res.status === 401 || res.status === 403) {
        setError("Access denied. Admin only.");
        setLoading(false);
        return;
      }
      const data = await res.json();
      setUsers(data);
      setError(null);
    } catch (e) {
      setError(e instanceof Error ? e.message : "Failed to load users");
    } finally {
      setLoading(false);
    }
  }

  async function handleDelete(id: string, email: string) {
    if (!confirm(`Delete user "${email}"? This cannot be undone.`)) return;
    try {
      const res = await fetch(`/api/admin/users?id=${id}`, {
        method: "DELETE",
        headers: { Authorization: `Bearer ${getToken()}` },
      });
      if (!res.ok) throw new Error("Delete failed");
      setUsers((prev) => prev.filter((u) => u.id !== id));
    } catch (e) {
      alert(e instanceof Error ? e.message : "Delete failed");
    }
  }

  async function handleUpdateRole(id: string, role: string) {
    try {
      const res = await fetch(`/api/admin/users?id=${id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${getToken()}`,
        },
        body: JSON.stringify({ role }),
      });
      if (!res.ok) throw new Error("Update failed");
      setUsers((prev) =>
        prev.map((u) => (u.id === id ? { ...u, role } : u))
      );
    } catch (e) {
      alert(e instanceof Error ? e.message : "Update failed");
    }
  }

  if (loading) return <div style={s.loading}>Loading users...</div>;

  return (
    <div>
      <div style={s.topBar}>
        <h1 style={s.pageTitle}>👥 Manage Users</h1>
        <span style={{ fontSize: 14, color: "#64748b" }}>{users.length} total users</span>
      </div>
      <div style={s.content}>
        {error && <div style={s.error}>{error}</div>}

        <div style={s.card}>
          <div style={s.cardTitle}>All Users</div>
          {users.length === 0 ? (
            <div style={s.empty}>No users found.</div>
          ) : (
            <table style={s.table}>
              <thead>
                <tr>
                  <th style={s.th}>Email</th>
                  <th style={s.th}>Name</th>
                  <th style={s.th}>Role</th>
                  <th style={s.th}>Timezone</th>
                  <th style={s.th}>Joined</th>
                  <th style={s.th}>Actions</th>
                </tr>
              </thead>
              <tbody>
                {users.map((user) => (
                  <tr key={user.id}>
                    <td style={s.td}>{user.email}</td>
                    <td style={s.td}>{user.fullName || "—"}</td>
                    <td style={s.td}>
                      <span style={badgeStyle(user.role === "admin" ? "#6366f1" : "#94a3b8")}>
                        {user.role}
                      </span>
                    </td>
                    <td style={s.td}>{user.timezone}</td>
                    <td style={s.td}>
                      {new Date(user.createdAt).toLocaleDateString()}
                    </td>
                    <td style={s.td}>
                      <div style={s.flexRow}>
                        <button
                          style={btnStyle("primary")}
                          onClick={() => setEditUser(user)}
                        >
                          ✏️ Edit
                        </button>
                        {user.role !== "admin" && (
                          <button
                            style={btnStyle("danger")}
                            onClick={() => handleDelete(user.id, user.email)}
                          >
                            🗑️ Delete
                          </button>
                        )}
                      </div>
                    </td>
                  </tr>
                ))}
              </tbody>
            </table>
          )}
        </div>

        {/* Edit User Modal */}
        {editUser && (
          <EditUserModal
            user={editUser}
            onClose={() => setEditUser(null)}
            onSave={(updated) => {
              setUsers((prev) =>
                prev.map((u) => (u.id === updated.id ? updated : u))
              );
              setEditUser(null);
            }}
            onRoleChange={handleUpdateRole}
          />
        )}
      </div>
    </div>
  );
}

function EditUserModal({
  user,
  onClose,
  onSave,
  onRoleChange,
}: {
  user: UserRecord;
  onClose: () => void;
  onSave: (u: UserRecord) => void;
  onRoleChange: (id: string, role: string) => Promise<void>;
}) {
  const [fullName, setFullName] = useState(user.fullName || "");
  const [role, setRole] = useState(user.role);
  const [timezone, setTimezone] = useState(user.timezone);
  const [currency, setCurrency] = useState(user.currency);
  const [saving, setSaving] = useState(false);

  async function handleSave() {
    setSaving(true);
    try {
      const token = localStorage.getItem("admin_token") || "";
      const res = await fetch(`/api/admin/users?id=${user.id}`, {
        method: "PUT",
        headers: {
          "Content-Type": "application/json",
          Authorization: `Bearer ${token}`,
        },
        body: JSON.stringify({ fullName, role, timezone, currency }),
      });
      if (!res.ok) throw new Error("Save failed");
      const updated = await res.json();
      onSave({ ...user, ...updated });
    } catch (e) {
      alert(e instanceof Error ? e.message : "Save failed");
    } finally {
      setSaving(false);
    }
  }

  return (
    <div style={s.modalOverlay} onClick={onClose}>
      <div style={s.modal} onClick={(e) => e.stopPropagation()}>
        <h2 style={s.modalTitle}>Edit User</h2>
        <div style={s.formGroup}>
          <label style={s.label}>Email</label>
          <input style={{ ...s.input, background: "#f1f5f9" }} value={user.email} disabled />
        </div>
        <div style={s.formGroup}>
          <label style={s.label}>Full Name</label>
          <input style={s.input} value={fullName} onChange={(e) => setFullName(e.target.value)} />
        </div>
        <div style={s.formGroup}>
          <label style={s.label}>Role</label>
          <select style={s.select} value={role} onChange={(e) => setRole(e.target.value)}>
            <option value="user">User</option>
            <option value="admin">Admin</option>
          </select>
        </div>
        <div style={s.formGroup}>
          <label style={s.label}>Timezone</label>
          <input style={s.input} value={timezone} onChange={(e) => setTimezone(e.target.value)} />
        </div>
        <div style={s.formGroup}>
          <label style={s.label}>Currency</label>
          <input style={s.input} value={currency} onChange={(e) => setCurrency(e.target.value)} />
        </div>
        <div style={{ ...s.flexRow, justifyContent: "flex-end", marginTop: 24 }}>
          <button style={btnStyle("secondary")} onClick={onClose}>Cancel</button>
          <button style={btnStyle("primary")} onClick={handleSave} disabled={saving}>
            {saving ? "Saving..." : "💾 Save Changes"}
          </button>
        </div>
      </div>
    </div>
  );
}
