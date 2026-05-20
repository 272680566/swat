-- Issue categories table (self-referencing tree)
CREATE TABLE IF NOT EXISTS issue_categories (
    id          BIGSERIAL    PRIMARY KEY,
    name        VARCHAR(50)  NOT NULL,
    parent_id   BIGINT       DEFAULT NULL,
    level       SMALLINT     NOT NULL DEFAULT 1,
    sort_order  INT          DEFAULT 0,
    color       VARCHAR(20)  DEFAULT 'blue',
    created_at  TIMESTAMP    DEFAULT NOW(),
    updated_at  TIMESTAMP    DEFAULT NOW(),
    CONSTRAINT  fk_cat_parent FOREIGN KEY (parent_id) REFERENCES issue_categories(id) ON DELETE CASCADE
);
