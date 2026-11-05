#!/usr/bin/env node
/**
 * Seeds a RUNNING backend with sample data for every module.
 *
 *   docker compose up -d            # 1. database
 *   cd backend && npm run dev       # 2. API on :3000
 *   npm run seed                    # 3. this script (run from backend/)
 *
 * It talks to the real HTTP API, so every payload is validated by the same
 * zod schemas the app uses and the password is hashed by the server.
 *
 * Env overrides:
 *   API_URL        default http://localhost:3000/api
 *   SEED_EMAIL     default demo@example.com
 *   SEED_PASSWORD  default demo-password-123
 *   SEED_FORCE=1   seed again even when the demo data is already present
 */
const API_URL = (process.env.API_URL ?? "http://localhost:3000/api").replace(/\/+$/, "");
const EMAIL = process.env.SEED_EMAIL ?? "demo@example.com";
const PASSWORD = process.env.SEED_PASSWORD ?? "demo-password-123";
const NAME = process.env.SEED_NAME ?? "Demo User";
const FORCE = process.env.SEED_FORCE === "1";

/** Title used to detect an already-seeded account. */
const MARKER = "Contoh: dokumentasi Flutter";

let token = null;
let created = 0;

async function api(method, path, body) {
    const res = await fetch(`${API_URL}${path}`, {
        method,
        headers: {
            "Content-Type": "application/json",
            ...(token ? { Authorization: `Bearer ${token}` } : {}),
        },
        body: body === undefined ? undefined : JSON.stringify(body),
    });

    const text = await res.text();
    let payload = text;
    try {
        payload = text ? JSON.parse(text) : null;
    } catch {
        /* keep the raw text for the error message */
    }

    if (!res.ok) {
        const detail = typeof payload === "string" ? payload : JSON.stringify(payload);
        const error = new Error(`${method} ${path} -> ${res.status} ${detail}`);
        error.status = res.status;
        throw error;
    }
    return payload;
}

async function create(path, body, label) {
    const row = await api("POST", path, body);
    created++;
    console.log(`  + ${label ?? path}`);
    return row;
}

/** Local (device) calendar date, matching how the app sends dates. */
function localDate(offsetDays = 0) {
    const d = new Date();
    d.setDate(d.getDate() + offsetDays);
    const pad = (n) => String(n).padStart(2, "0");
    return `${d.getFullYear()}-${pad(d.getMonth() + 1)}-${pad(d.getDate())}`;
}

async function authenticate() {
    try {
        const result = await api("POST", "/auth", {
            action: "register",
            email: EMAIL,
            password: PASSWORD,
            fullName: NAME,
        });
        token = result.accessToken;
        console.log(`Registered ${EMAIL}`);
        return true;
    } catch (error) {
        if (error.status !== 409) throw error;
    }

    const result = await api("POST", "/auth", { action: "login", email: EMAIL, password: PASSWORD });
    token = result.accessToken;
    console.log(`Signed in as ${EMAIL}`);
    return false;
}

async function alreadySeeded() {
    const bookmarks = await api("GET", "/bookmarks");
    return Array.isArray(bookmarks) && bookmarks.some((b) => b.title === MARKER);
}

async function seedProjects() {
    console.log("Projects");
    const project = await create("/projects", {
        name: "Belajar Flutter",
        description: "Naik level dari dasar ke aplikasi nyata",
        priority: "high",
        techStack: ["flutter", "dart"],
        startDate: localDate(-14),
        targetDate: localDate(45),
    }, "project");

    await create("/projects/milestones", {
        projectId: project.id,
        title: "Selesai modul dasar",
        dueDate: localDate(14),
    }, "milestone");

    await create("/projects/tasks", {
        projectId: project.id,
        title: "Bikin 1 aplikasi latihan",
        status: "in_progress",
        priority: "medium",
        dueDate: localDate(7),
        tags: ["latihan"],
    }, "task");
}

async function seedHabits() {
    console.log("Habits");
    const habit = await create("/habits", {
        name: "Olahraga pagi",
        description: "Jalan cepat atau angkat beban",
        frequency: "daily",
        unit: "menit",
        targetValue: 30,
        color: "#F59E0B",
        icon: "fitness",
    }, "habit");

    for (let day = 0; day < 3; day++) {
        await create("/habits/logs", {
            habitId: habit.id,
            logDate: localDate(-day),
            value: "30",
            notes: day === 0 ? "Badan enak" : undefined,
            mood: "good",
        }, `habit log ${localDate(-day)}`);
    }

    await create("/habits/metrics", {
        metricDate: localDate(0),
        sleepHours: 7.5,
        codingHours: 2,
        exerciseMinutes: 30,
        mood: 8,
        energyLevel: 7,
    }, "daily metric");
}

async function seedSubscriptions() {
    console.log("Subscriptions");
    const subscription = await create("/subscriptions", {
        name: "Musik premium",
        provider: "Spotify",
        category: "entertainment",
        amount: "54000",
        currency: "IDR",
        billingCycle: "monthly",
        startDate: localDate(-90),
        nextRenewalDate: localDate(9),
        reminderDays: 3,
    }, "subscription");

    await create("/subscriptions/payments", {
        subscriptionId: subscription.id,
        amount: "54000",
        paymentDate: localDate(-21),
        notes: "Pembayaran bulan lalu",
    }, "subscription payment");
}

async function seedJobs() {
    console.log("Jobs");
    const website = await create("/jobs/websites", {
        name: "LinkedIn",
        url: "https://www.linkedin.com/jobs",
        status: "active",
        notes: "Pakai email utama",
    }, "job website");

    const job = await create("/jobs", {
        companyName: "PT Contoh Sejahtera",
        position: "Backend Engineer",
        status: "screening",
        applicationDate: localDate(-5),
        location: "Jakarta (hybrid)",
        jobType: "Full-time",
        salaryRange: "15-20 juta",
        websiteId: website.id,
        url: "https://example.com/jobs/backend-engineer",
        notes: "Referral dari teman",
    }, "job application");

    await create("/jobs/contacts", {
        jobId: job.id,
        name: "Rina",
        role: "Recruiter",
        email: "rina@example.com",
        phone: "08123456789",
    }, "job contact");

    await create("/jobs/interviews", {
        jobId: job.id,
        round: 1,
        interviewType: "technical",
        scheduledAt: new Date(Date.now() + 2 * 86400000).toISOString(),
        durationMinutes: 60,
        location: "Google Meet",
        interviewerName: "Budi",
    }, "job interview");
}

async function seedJournalAndBugs() {
    console.log("Journal & bugs");
    const tag = await create("/journal/tags", { name: "flutter", color: "#6366F1" }, "journal tag");

    await create("/journal", {
        title: "JWT gagal diverifikasi di middleware",
        problem: "Semua request API dibalas 401 Invalid token.",
        rootCause: "jsonwebtoken butuh crypto Node, sedangkan middleware berjalan di Edge runtime.",
        solution: "Verifikasi HS256 memakai WebCrypto di lib/jwt-edge.ts.",
        conceptLearned: "Edge runtime tidak menyediakan modul crypto Node.",
        language: "typescript",
        projectName: "personal-super-app",
        tagIds: [tag.id],
    }, "journal entry");

    await create("/bugs", {
        title: "Dashboard admin tidak bisa dibuka di aplikasi",
        projectName: "personal-super-app",
        technology: "Flutter",
        errorMessage: "type 'Null' is not a subtype of type 'Map<String, dynamic>'",
        errorType: "TypeError",
        severity: "high",
        cause: "Endpoint dashboard mengembalikan bentuk berbeda untuk admin.",
        solution: "Dashboard pribadi tetap dikirim, systemStats ditambahkan.",
        tags: ["flutter", "api"],
    }, "bug entry");
}

async function seedInventoryAndBookmarks() {
    console.log("Inventory & bookmarks");
    const category = await create("/inventory/categories", {
        name: "Elektronik",
        description: "Barang elektronik pribadi",
        icon: "laptop",
    }, "inventory category");

    await create("/inventory", {
        name: "Laptop kerja",
        brand: "Lenovo",
        model: "ThinkPad T14",
        serialNumber: "SN-123456",
        categoryId: category.id,
        purchaseDate: localDate(-400),
        purchasePrice: 12000000,
        currentValue: 9500000,
        condition: "good",
        location: "Meja kerja",
        warrantyExpiry: localDate(30),
        tags: ["kerja"],
    }, "inventory item");

    const collection = await create("/bookmarks/collections", {
        name: "Belajar",
        description: "Materi belajar pribadi",
        color: "#F97316",
    }, "bookmark collection");

    await create("/bookmarks", {
        title: MARKER,
        url: "https://docs.flutter.dev",
        description: "Dokumentasi resmi Flutter",
        collectionId: collection.id,
        status: "unread",
        tags: ["flutter", "dokumentasi"],
    }, "bookmark");
}

async function main() {
    console.log(`API: ${API_URL}`);
    const isNewAccount = await authenticate();

    if (!isNewAccount && !FORCE && (await alreadySeeded())) {
        console.log("\nDemo data is already present. Re-run with SEED_FORCE=1 to add it again.");
        return;
    }

    console.log("\nSeeding sample data...");
    await seedProjects();
    await seedHabits();
    await seedSubscriptions();
    await seedJobs();
    await seedJournalAndBugs();
    await seedInventoryAndBookmarks();

    console.log(`\nDone: ${created} records created.`);
    console.log(`Login with ${EMAIL} / ${PASSWORD}`);
    console.log(
        `To make this account an admin (only works while no admin exists):\n` +
        `  curl -X POST ${API_URL}/admin/bootstrap -H "Authorization: Bearer <accessToken>"`
    );
}

main().catch((error) => {
    console.error(`\nSeed failed: ${error.message}`);
    process.exit(1);
});
