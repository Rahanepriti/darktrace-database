BEGIN;

CREATE TABLE users (
    usr_id TEXT PRIMARY KEY,
    username TEXT NOT NULL,
    email TEXT NOT NULL,
    password_hash TEXT NOT NULL,
    role TEXT NOT NULL DEFAULT 'analyst',
    mfa_enabled BOOLEAN NOT NULL DEFAULT false,
    status TEXT NOT NULL DEFAULT 'active',
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    last_login_at TIMESTAMPTZ,
    CONSTRAINT uq_users_username UNIQUE (username),
    CONSTRAINT uq_users_email UNIQUE (email),
    CONSTRAINT chk_users_role
        CHECK (role IN (
            'sysadmin', 'analyst', 'investigator',
            'supervisor', 'auditor', 'readonly'
        )),
    CONSTRAINT chk_users_status
        CHECK (status IN ('active', 'disabled'))
);

CREATE INDEX idx_users_role ON users(role);

CREATE TABLE source (
    source_id TEXT PRIMARY KEY,
    name TEXT NOT NULL,
    source_type TEXT NOT NULL,
    onion_addr TEXT,
    auth_ref TEXT NOT NULL,
    crawl_policy JSON NOT NULL DEFAULT '{}'::json,
    health JSON NOT NULL DEFAULT '{}'::json,
    status TEXT NOT NULL DEFAULT 'active',
    created_by TEXT NOT NULL,
    created_at TIMESTAMPTZ NOT NULL DEFAULT now(),
    CONSTRAINT chk_source_type
        CHECK (source_type IN (
            'onion_site', 'forum', 'marketplace',
            'paste', 'blog', 'i2p_site'
        )),
    CONSTRAINT chk_source_status
        CHECK (status IN ('active', 'paused', 'dead')),
    CONSTRAINT fk_source_created_by
        FOREIGN KEY (created_by) REFERENCES users(usr_id)
);

CREATE INDEX idx_source_status ON source(status);

CREATE TABLE crawl_job (
    job_id TEXT PRIMARY KEY,
    intent_id TEXT NOT NULL,
    source_id TEXT NOT NULL,
    kind TEXT NOT NULL,
    state TEXT NOT NULL DEFAULT 'queued',
    attempt INTEGER NOT NULL DEFAULT 0,
    stats JSON NOT NULL DEFAULT '{}'::json,
    error TEXT,
    started_at TIMESTAMPTZ,
    finished_at TIMESTAMPTZ,
    CONSTRAINT chk_crawl_job_kind
        CHECK (kind IN ('scheduled', 'incremental', 'manual')),
    CONSTRAINT chk_crawl_job_state
        CHECK (state IN ('queued', 'running', 'done', 'failed', 'dead')),
    CONSTRAINT chk_crawl_job_attempt_nonnegative
        CHECK (attempt >= 0),
    CONSTRAINT chk_crawl_job_timestamps
        CHECK (
            started_at IS NULL
            OR finished_at IS NULL
            OR finished_at >= started_at
        ),
    CONSTRAINT fk_crawl_job_source
        FOREIGN KEY (source_id) REFERENCES source(source_id)
);

CREATE INDEX idx_crawl_job_source ON crawl_job(source_id);
CREATE INDEX idx_crawl_job_state ON crawl_job(state);

COMMIT;
