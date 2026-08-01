-- =====================================================
-- PERSONAL SUPER APP - COMPLETE DATABASE SCHEMA
-- PostgreSQL (Compatible with Supabase/Neon/Vercel Postgres)
-- =====================================================

-- Enable UUID extension
CREATE EXTENSION IF NOT EXISTS "uuid-ossp";

-- =====================================================
-- 1. USERS & AUTH
-- =====================================================
CREATE TABLE users (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    email VARCHAR(255) UNIQUE NOT NULL,
    password_hash VARCHAR(255) NOT NULL,
    full_name VARCHAR(255),
    avatar_url TEXT,
    timezone VARCHAR(50) DEFAULT 'Asia/Jakarta',
    currency VARCHAR(10) DEFAULT 'IDR',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 2. PERSONAL FINANCE MODULE
-- =====================================================
CREATE TABLE finance_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    color VARCHAR(7) DEFAULT '#3B82F6',
    icon VARCHAR(50),
    parent_id UUID REFERENCES finance_categories(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE finance_transactions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES finance_categories(id),
    amount DECIMAL(15, 2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    description TEXT,
    transaction_date DATE NOT NULL,
    payment_method VARCHAR(50),
    is_recurring BOOLEAN DEFAULT FALSE,
    recurring_rule_id UUID,
    tags TEXT[],
    attachment_url TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE finance_recurring_rules (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES finance_categories(id),
    amount DECIMAL(15, 2) NOT NULL,
    type VARCHAR(20) NOT NULL CHECK (type IN ('income', 'expense')),
    frequency VARCHAR(20) NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly', 'yearly')),
    interval INTEGER DEFAULT 1,
    start_date DATE NOT NULL,
    end_date DATE,
    description TEXT,
    next_execution DATE NOT NULL,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE finance_budgets (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES finance_categories(id),
    amount DECIMAL(15, 2) NOT NULL,
    period VARCHAR(20) NOT NULL CHECK (period IN ('weekly', 'monthly', 'yearly')),
    start_date DATE NOT NULL,
    end_date DATE,
    alert_threshold DECIMAL(5, 2) DEFAULT 80.00,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE finance_saving_goals (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    target_amount DECIMAL(15, 2) NOT NULL,
    current_amount DECIMAL(15, 2) DEFAULT 0,
    deadline DATE,
    color VARCHAR(7) DEFAULT '#10B981',
    icon VARCHAR(50),
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE finance_investments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    type VARCHAR(50) NOT NULL,
    symbol VARCHAR(20),
    quantity DECIMAL(15, 6) NOT NULL,
    purchase_price DECIMAL(15, 2) NOT NULL,
    current_price DECIMAL(15, 2),
    purchase_date DATE NOT NULL,
    broker VARCHAR(100),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 3. DEVELOPER JOURNAL MODULE
-- =====================================================
CREATE TABLE journal_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    problem TEXT,
    root_cause TEXT,
    solution TEXT,
    concept_learned TEXT,
    code_snippet TEXT,
    language VARCHAR(50),
    project_name VARCHAR(100),
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE journal_tags (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(50) NOT NULL,
    color VARCHAR(7) DEFAULT '#6366F1',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE journal_entry_tags (
    journal_id UUID REFERENCES journal_entries(id) ON DELETE CASCADE,
    tag_id UUID REFERENCES journal_tags(id) ON DELETE CASCADE,
    PRIMARY KEY (journal_id, tag_id)
);

-- =====================================================
-- 4. BUG TRACKER MODULE
-- =====================================================
CREATE TABLE bug_entries (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    bug_code VARCHAR(20) UNIQUE,
    title VARCHAR(255) NOT NULL,
    project_name VARCHAR(100),
    technology VARCHAR(100),
    error_message TEXT,
    error_type VARCHAR(100),
    cause TEXT,
    solution TEXT,
    status VARCHAR(20) DEFAULT 'open' CHECK (status IN ('open', 'in_progress', 'solved', 'closed')),
    severity VARCHAR(20) DEFAULT 'medium' CHECK (severity IN ('low', 'medium', 'high', 'critical')),
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    solved_at TIMESTAMP WITH TIME ZONE
);

-- =====================================================
-- 5. JOB APPLICATION TRACKER MODULE
-- =====================================================
CREATE TABLE job_applications (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    company_name VARCHAR(255) NOT NULL,
    position VARCHAR(255) NOT NULL,
    salary_range VARCHAR(100),
    location VARCHAR(255),
    job_type VARCHAR(50),
    status VARCHAR(30) DEFAULT 'applied' CHECK (status IN ('applied', 'screening', 'interview', 'technical_test', 'offer', 'rejected', 'withdrawn', 'accepted')),
    application_date DATE NOT NULL,
    job_description TEXT,
    notes TEXT,
    url TEXT,
    is_favorite BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE job_interviews (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES job_applications(id) ON DELETE CASCADE,
    round INTEGER DEFAULT 1,
    interview_type VARCHAR(50) NOT NULL,
    scheduled_at TIMESTAMP WITH TIME ZONE,
    duration_minutes INTEGER,
    location VARCHAR(255),
    meeting_url TEXT,
    interviewer_name VARCHAR(255),
    interviewer_email VARCHAR(255),
    notes TEXT,
    status VARCHAR(20) DEFAULT 'scheduled' CHECK (status IN ('scheduled', 'completed', 'cancelled', 'no_show')),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE job_contacts (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    job_id UUID REFERENCES job_applications(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    role VARCHAR(100),
    email VARCHAR(255),
    phone VARCHAR(50),
    linkedin_url TEXT,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 6. PERSONAL PROJECT MANAGER MODULE
-- =====================================================
CREATE TABLE projects (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    goal TEXT,
    status VARCHAR(20) DEFAULT 'active' CHECK (status IN ('active', 'on_hold', 'completed', 'cancelled')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    progress DECIMAL(5, 2) DEFAULT 0,
    start_date DATE,
    target_date DATE,
    completed_date DATE,
    tech_stack TEXT[],
    git_repository TEXT,
    documentation_url TEXT,
    color VARCHAR(7) DEFAULT '#8B5CF6',
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE project_milestones (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    title VARCHAR(255) NOT NULL,
    description TEXT,
    due_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    is_completed BOOLEAN DEFAULT FALSE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE project_tasks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    project_id UUID REFERENCES projects(id) ON DELETE CASCADE,
    milestone_id UUID REFERENCES project_milestones(id),
    title VARCHAR(255) NOT NULL,
    description TEXT,
    status VARCHAR(20) DEFAULT 'todo' CHECK (status IN ('todo', 'in_progress', 'review', 'done')),
    priority VARCHAR(20) DEFAULT 'medium' CHECK (priority IN ('low', 'medium', 'high')),
    due_date DATE,
    completed_at TIMESTAMP WITH TIME ZONE,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 7. HABIT & PRODUCTIVITY TRACKER MODULE
-- =====================================================
CREATE TABLE habits (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    color VARCHAR(7) DEFAULT '#F59E0B',
    target_value DECIMAL(10, 2) DEFAULT 1,
    unit VARCHAR(50),
    frequency VARCHAR(20) NOT NULL CHECK (frequency IN ('daily', 'weekly', 'monthly')),
    target_days INTEGER[] DEFAULT '{1,2,3,4,5,6,7}',
    reminder_time TIME,
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE habit_logs (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    habit_id UUID REFERENCES habits(id) ON DELETE CASCADE,
    log_date DATE NOT NULL,
    value DECIMAL(10, 2) DEFAULT 1,
    notes TEXT,
    mood VARCHAR(20),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(habit_id, log_date)
);

CREATE TABLE daily_metrics (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    metric_date DATE NOT NULL,
    sleep_hours DECIMAL(4, 1),
    study_hours DECIMAL(4, 1),
    coding_hours DECIMAL(4, 1),
    exercise_minutes INTEGER,
    reading_minutes INTEGER,
    screen_time_minutes INTEGER,
    deep_work_hours DECIMAL(4, 1),
    mood INTEGER CHECK (mood BETWEEN 1 AND 10),
    energy_level INTEGER CHECK (energy_level BETWEEN 1 AND 10),
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    UNIQUE(user_id, metric_date)
);

-- =====================================================
-- 8. SUBSCRIPTION TRACKER MODULE
-- =====================================================
CREATE TABLE subscriptions (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    provider VARCHAR(100),
    category VARCHAR(50),
    amount DECIMAL(15, 2) NOT NULL,
    currency VARCHAR(10) DEFAULT 'IDR',
    billing_cycle VARCHAR(20) NOT NULL CHECK (billing_cycle IN ('weekly', 'monthly', 'quarterly', 'yearly', 'lifetime')),
    next_renewal_date DATE,
    start_date DATE,
    payment_method VARCHAR(100),
    is_active BOOLEAN DEFAULT TRUE,
    reminder_days INTEGER DEFAULT 3,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE subscription_payments (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    subscription_id UUID REFERENCES subscriptions(id) ON DELETE CASCADE,
    amount DECIMAL(15, 2) NOT NULL,
    payment_date DATE NOT NULL,
    notes TEXT,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 9. PERSONAL INVENTORY MODULE
-- =====================================================
CREATE TABLE inventory_categories (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(100) NOT NULL,
    description TEXT,
    icon VARCHAR(50),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE inventory_items (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    category_id UUID REFERENCES inventory_categories(id),
    name VARCHAR(255) NOT NULL,
    description TEXT,
    brand VARCHAR(100),
    model VARCHAR(100),
    serial_number VARCHAR(100),
    purchase_date DATE,
    purchase_price DECIMAL(15, 2),
    current_value DECIMAL(15, 2),
    currency VARCHAR(10) DEFAULT 'IDR',
    condition VARCHAR(20) DEFAULT 'good' CHECK (condition IN ('excellent', 'good', 'fair', 'poor', 'broken')),
    location VARCHAR(100),
    warranty_expiry DATE,
    receipt_url TEXT,
    photo_urls TEXT[],
    tags TEXT[],
    is_active BOOLEAN DEFAULT TRUE,
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- 10. BOOKMARK / RESOURCE MANAGER MODULE
-- =====================================================
CREATE TABLE bookmark_collections (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    name VARCHAR(255) NOT NULL,
    description TEXT,
    color VARCHAR(7) DEFAULT '#EC4899',
    icon VARCHAR(50),
    parent_id UUID REFERENCES bookmark_collections(id),
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

CREATE TABLE bookmarks (
    id UUID PRIMARY KEY DEFAULT uuid_generate_v4(),
    user_id UUID REFERENCES users(id) ON DELETE CASCADE,
    collection_id UUID REFERENCES bookmark_collections(id),
    title VARCHAR(255) NOT NULL,
    url TEXT NOT NULL,
    description TEXT,
    notes TEXT,
    status VARCHAR(20) DEFAULT 'unread' CHECK (status IN ('unread', 'reading', 'completed', 'archived')),
    rating INTEGER CHECK (rating BETWEEN 1 AND 5),
    is_favorite BOOLEAN DEFAULT FALSE,
    tags TEXT[],
    created_at TIMESTAMP WITH TIME ZONE DEFAULT NOW(),
    updated_at TIMESTAMP WITH TIME ZONE DEFAULT NOW()
);

-- =====================================================
-- INDEXES FOR PERFORMANCE
-- =====================================================
CREATE INDEX idx_transactions_user_date ON finance_transactions(user_id, transaction_date DESC);
CREATE INDEX idx_transactions_category ON finance_transactions(category_id);
CREATE INDEX idx_transactions_type ON finance_transactions(type);
CREATE INDEX idx_recurring_next_exec ON finance_recurring_rules(next_execution) WHERE is_active = TRUE;
CREATE INDEX idx_journal_entries_user ON journal_entries(user_id, created_at DESC);
CREATE INDEX idx_bugs_user_status ON bug_entries(user_id, status);
CREATE INDEX idx_bugs_tags ON bug_entries USING GIN(tags);
CREATE INDEX idx_job_applications_user ON job_applications(user_id, status);
CREATE INDEX idx_projects_user ON projects(user_id, status);
CREATE INDEX idx_habit_logs_habit_date ON habit_logs(habit_id, log_date DESC);
CREATE INDEX idx_daily_metrics_user_date ON daily_metrics(user_id, metric_date DESC);
CREATE INDEX idx_subscriptions_user ON subscriptions(user_id, next_renewal_date);
CREATE INDEX idx_inventory_user ON inventory_items(user_id, category_id);
CREATE INDEX idx_bookmarks_user ON bookmarks(user_id, collection_id);
CREATE INDEX idx_bookmarks_tags ON bookmarks USING GIN(tags);

-- =====================================================
-- FUNCTIONS & TRIGGERS
-- =====================================================
CREATE OR REPLACE FUNCTION update_updated_at_column()
RETURNS TRIGGER AS $$
BEGIN
    NEW.updated_at = NOW();
    RETURN NEW;
END;
$$ language 'plpgsql';

CREATE TRIGGER update_users_updated_at BEFORE UPDATE ON users
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_transactions_updated_at BEFORE UPDATE ON finance_transactions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_saving_goals_updated_at BEFORE UPDATE ON finance_saving_goals
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_investments_updated_at BEFORE UPDATE ON finance_investments
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_journal_entries_updated_at BEFORE UPDATE ON journal_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bug_entries_updated_at BEFORE UPDATE ON bug_entries
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_job_applications_updated_at BEFORE UPDATE ON job_applications
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_projects_updated_at BEFORE UPDATE ON projects
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_project_tasks_updated_at BEFORE UPDATE ON project_tasks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_habits_updated_at BEFORE UPDATE ON habits
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_daily_metrics_updated_at BEFORE UPDATE ON daily_metrics
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_subscriptions_updated_at BEFORE UPDATE ON subscriptions
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_inventory_items_updated_at BEFORE UPDATE ON inventory_items
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

CREATE TRIGGER update_bookmarks_updated_at BEFORE UPDATE ON bookmarks
    FOR EACH ROW EXECUTE FUNCTION update_updated_at_column();

-- Auto-generate bug code
CREATE OR REPLACE FUNCTION generate_bug_code()
RETURNS TRIGGER AS $$
DECLARE
    next_num INTEGER;
BEGIN
    SELECT COALESCE(MAX(CAST(SUBSTRING(bug_code FROM 5) AS INTEGER)), 0) + 1
    INTO next_num
    FROM bug_entries
    WHERE user_id = NEW.user_id;
    
    NEW.bug_code := 'BUG-' || LPAD(next_num::TEXT, 3, '0');
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

CREATE TRIGGER set_bug_code BEFORE INSERT ON bug_entries
    FOR EACH ROW WHEN (NEW.bug_code IS NULL)
    EXECUTE FUNCTION generate_bug_code();

-- =====================================================
-- ROW LEVEL SECURITY (RLS) POLICIES - For Supabase
-- =====================================================
ALTER TABLE users ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_transactions ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_recurring_rules ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_budgets ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_saving_goals ENABLE ROW LEVEL SECURITY;
ALTER TABLE finance_investments ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE journal_entry_tags ENABLE ROW LEVEL SECURITY;
ALTER TABLE bug_entries ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_applications ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_interviews ENABLE ROW LEVEL SECURITY;
ALTER TABLE job_contacts ENABLE ROW LEVEL SECURITY;
ALTER TABLE projects ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_milestones ENABLE ROW LEVEL SECURITY;
ALTER TABLE project_tasks ENABLE ROW LEVEL SECURITY;
ALTER TABLE habits ENABLE ROW LEVEL SECURITY;
ALTER TABLE habit_logs ENABLE ROW LEVEL SECURITY;
ALTER TABLE daily_metrics ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscriptions ENABLE ROW LEVEL SECURITY;
ALTER TABLE subscription_payments ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_categories ENABLE ROW LEVEL SECURITY;
ALTER TABLE inventory_items ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmark_collections ENABLE ROW LEVEL SECURITY;
ALTER TABLE bookmarks ENABLE ROW LEVEL SECURITY;

-- Note: Create policies in Supabase dashboard or via migration
-- Example: CREATE POLICY "Users can only access their own data" ON finance_transactions FOR ALL USING (auth.uid() = user_id);
