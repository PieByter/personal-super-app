import { defineConfig } from "vitest/config";

export default defineConfig({
    test: {
        // Provide a stable secret so auth.ts module-load guard passes in tests.
        // This value is test-only and never used in production.
        env: {
            JWT_SECRET: "test-secret-for-vitest-do-not-use-in-production",
        },
    },
});
