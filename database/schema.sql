CREATE TABLE users (
    usr_id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'analyst'
        CHECK (role IN ('sysadmin', 'analyst', 'investigator', 'supervisor', 'auditor', 'readonly')),
    mfa_enabled BOOLEAN NOT NULL DEFAULT false,
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'disabled')),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at TIMESTAMPTZ,
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email)
);

CREATE INDEX idx_users_role ON users(role);

CREATE TABLE source (
    source_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    source_type TEXT NOT NULL
        CHECK (source_type IN ('onion_site', 'forum', 'marketplace', 'paste', 'blog', 'i2p_site')),
    onion_addr TEXT,
    auth_ref TEXT NOT NULL,
    crawl_policy JSONB NOT NULL DEFAULT '{}'::jsonb,
    health JSONB NOT NULL DEFAULT '{}'::jsonb,
    status TEXT NOT NULL DEFAULT 'active'
        CHECK (status IN ('active', 'paused', 'dead')),
    created_by TEXT NOT NULL REFERENCES users(usr_id),
    created_at TIMESTAMPTZ NOT NULL DEFAULT now()
);

CREATE INDEX idx_source_status ON source(status);

CREATE TABLE crawl_job (
    job_id TEXT PRIMARY KEY,
    intent_id TEXT NOT NULL,
    source_id TEXT NOT NULL REFERENCES source(source_id),
    kind TEXT NOT NULL
        CHECK (kind IN ('scheduled', 'incremental', 'manual')),
    state TEXT NOT NULL DEFAULT 'queued'
        CHECK (state IN ('queued', 'running', 'done', 'failed', 'dead')),
    attempt INT NOT NULL DEFAULT 0,
    stats JSONB NOT NULL DEFAULT '{}'::jsonb,
    error TEXT,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    CONSTRAINT chk_crawl_job_attempt_nonnegative
        CHECK (attempt >= 0),
    CONSTRAINT chk_crawl_job_timestamps
        CHECK (
            started_at IS NULL
            OR finished_at IS NULL
            OR finished_at >= started_at
        )
);

CREATE INDEX idx_crawl_job_source ON crawl_job(source_id);
CREATE INDEX idx_crawl_job_state ON crawl_job(state);
