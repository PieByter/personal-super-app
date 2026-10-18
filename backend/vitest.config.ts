import { defineConfig } from "vitest/config";
import path from "node:path";

export default defineConfig({
    resolve: {
        // Mirrors the "@/*" -> "src/*" alias from tsconfig.json.
        alias: { "@": path.resolve(__dirname, "src") },
    },
    test: {
        // Provide a stable secret so auth.ts module-load guard passes in tests.
        // This value is test-only and never used in production.
        env: {
            JWT_SECRET: "test-secret-for-vitest-do-not-use-in-production",
        },
    },
});
