-- Sites table with unique constraint on name

CREATE TABLE IF NOT EXISTS sites (
    id          BIGSERIAL    PRIMARY KEY,
    code        VARCHAR(50)  NOT NULL,
    name        VARCHAR(100) NOT NULL,
    region      VARCHAR(50)  DEFAULT '',
    contact     VARCHAR(50)  DEFAULT '',
    phone       VARCHAR(30)  DEFAULT '',
    active      BOOLEAN      DEFAULT TRUE,
    created_at  TIMESTAMP    DEFAULT NOW(),
    updated_at  TIMESTAMP    DEFAULT NOW(),
    CONSTRAINT  uk_sites_name UNIQUE (name)
);
