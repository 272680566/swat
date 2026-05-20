-- Versions table
CREATE TABLE IF NOT EXISTS versions (
    id            BIGSERIAL    PRIMARY KEY,
    version_code  VARCHAR(50)  NOT NULL UNIQUE,
    sites         TEXT         DEFAULT '',
    release_date  DATE,
    status        VARCHAR(20)  DEFAULT 'dev',
    notes         TEXT         DEFAULT '',
    created_at    TIMESTAMP    DEFAULT NOW(),
    updated_at    TIMESTAMP    DEFAULT NOW()
);
