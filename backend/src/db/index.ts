import { drizzle } from "drizzle-orm/postgres-js";
import postgres from "postgres";
import * as schema from "./schema";
import { normalizeDatabaseUrl } from "@/lib/db-url";

const connectionString = normalizeDatabaseUrl(process.env.DATABASE_URL!);

const client = postgres(connectionString, { prepare: false });
export const db = drizzle(client, { schema });

export type DB = typeof db;
