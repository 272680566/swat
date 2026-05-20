-- Issues table
CREATE TABLE IF NOT EXISTS issues (
    id              BIGSERIAL    PRIMARY KEY,
    issue_no        VARCHAR(30)  NOT NULL UNIQUE,
    occur_time      TIMESTAMP    NOT NULL,
    customer_name   VARCHAR(100) DEFAULT '',
    description     TEXT         DEFAULT '',
    kernel_version  VARCHAR(50)  DEFAULT '',
    status          VARCHAR(20)  DEFAULT '待处理',
    -- Basic info
    category        TEXT         DEFAULT '',
    key_site        BOOLEAN      DEFAULT FALSE,
    site_type       VARCHAR(20)  DEFAULT '',
    mgmt_deploy     VARCHAR(20)  DEFAULT '',
    kernel_deploy   VARCHAR(20)  DEFAULT '',
    rl              VARCHAR(50)  DEFAULT '',
    ops_ticket      VARCHAR(50)  DEFAULT '',
    ecare_ticket    VARCHAR(50)  DEFAULT '',
    -- Quick properties
    biz_interrupt   BOOLEAN      DEFAULT FALSE,
    urgent_recover  BOOLEAN      DEFAULT FALSE,
    remark          TEXT         DEFAULT '',
    -- Discovery
    has_alarm       BOOLEAN      DEFAULT FALSE,
    alarm_trigger   BOOLEAN      DEFAULT FALSE,
    find_remark     TEXT         DEFAULT '',
    -- Timeline
    perceive_time   TIMESTAMP,
    create_time     TIMESTAMP,
    swat_start_time TIMESTAMP,
    bound_time      TIMESTAMP,
    biz_recover_time TIMESTAMP,
    full_recover_time TIMESTAMP,
    time_remark     TEXT         DEFAULT '',
    -- Archive
    doc_link        TEXT         DEFAULT '',
    screen_link     TEXT         DEFAULT '',
    -- Emergency plan
    had_plan        BOOLEAN      DEFAULT FALSE,
    has_plan        BOOLEAN      DEFAULT FALSE,
    plan_name       VARCHAR(100) DEFAULT '',
    -- Audit
    created_at      TIMESTAMP    DEFAULT NOW(),
    updated_at      TIMESTAMP    DEFAULT NOW()
);
