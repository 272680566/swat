--
-- PostgreSQL database dump
--

\restrict Fe49jtmyChaXsJPfDNiSwKgPe4So7hBBQuSwC3cQWNe6fah9nrUIcaMOhWr545N

-- Dumped from database version 18.4
-- Dumped by pg_dump version 18.4

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET transaction_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: issue_categories; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issue_categories (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    parent_id bigint,
    level smallint DEFAULT 1 NOT NULL,
    sort_order integer DEFAULT 0,
    color character varying(20) DEFAULT 'blue'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: issue_categories_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.issue_categories_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issue_categories_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.issue_categories_id_seq OWNED BY public.issue_categories.id;


--
-- Name: issues; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.issues (
    id bigint NOT NULL,
    issue_no character varying(30) NOT NULL,
    occur_time timestamp without time zone NOT NULL,
    customer_name character varying(100) DEFAULT ''::character varying,
    description text DEFAULT ''::text,
    kernel_version character varying(50) DEFAULT ''::character varying,
    status character varying(20) DEFAULT '待处理'::character varying,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    category text DEFAULT ''::text,
    key_site boolean DEFAULT false,
    site_type character varying(20) DEFAULT ''::character varying,
    mgmt_deploy character varying(20) DEFAULT ''::character varying,
    kernel_deploy character varying(20) DEFAULT ''::character varying,
    rl character varying(50) DEFAULT ''::character varying,
    ops_ticket character varying(50) DEFAULT ''::character varying,
    ecare_ticket character varying(50) DEFAULT ''::character varying,
    biz_interrupt boolean DEFAULT false,
    urgent_recover boolean DEFAULT false,
    remark text DEFAULT ''::text,
    has_alarm boolean DEFAULT false,
    alarm_trigger boolean DEFAULT false,
    find_remark text DEFAULT ''::text,
    perceive_time timestamp without time zone,
    create_time timestamp without time zone,
    swat_start_time timestamp without time zone,
    bound_time timestamp without time zone,
    biz_recover_time timestamp without time zone,
    full_recover_time timestamp without time zone,
    time_remark text DEFAULT ''::text,
    doc_link text DEFAULT ''::text,
    screen_link text DEFAULT ''::text,
    had_plan boolean DEFAULT false,
    has_plan boolean DEFAULT false,
    plan_name character varying(100) DEFAULT ''::character varying,
    handle_date date
);


--
-- Name: issues_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.issues_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: issues_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.issues_id_seq OWNED BY public.issues.id;


--
-- Name: rls; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.rls (
    id bigint NOT NULL,
    name character varying(50) NOT NULL,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: rls_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.rls_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: rls_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.rls_id_seq OWNED BY public.rls.id;


--
-- Name: sites; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.sites (
    id bigint NOT NULL,
    code character varying(50) NOT NULL,
    name character varying(100) NOT NULL,
    region character varying(50) DEFAULT ''::character varying,
    contact character varying(50) DEFAULT ''::character varying,
    phone character varying(30) DEFAULT ''::character varying,
    active boolean DEFAULT true,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now(),
    version_ids text DEFAULT ''::text
);


--
-- Name: sites_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.sites_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: sites_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.sites_id_seq OWNED BY public.sites.id;


--
-- Name: users; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.users (
    id bigint NOT NULL,
    username character varying(50) NOT NULL,
    password character varying(255) NOT NULL,
    email character varying(100) DEFAULT ''::character varying,
    created_at timestamp without time zone DEFAULT now()
);


--
-- Name: users_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.users_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: users_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.users_id_seq OWNED BY public.users.id;


--
-- Name: versions; Type: TABLE; Schema: public; Owner: -
--

CREATE TABLE public.versions (
    id bigint NOT NULL,
    version_code character varying(50) NOT NULL,
    sites text DEFAULT ''::text,
    release_date date,
    status character varying(20) DEFAULT 'dev'::character varying,
    notes text DEFAULT ''::text,
    created_at timestamp without time zone DEFAULT now(),
    updated_at timestamp without time zone DEFAULT now()
);


--
-- Name: versions_id_seq; Type: SEQUENCE; Schema: public; Owner: -
--

CREATE SEQUENCE public.versions_id_seq
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;


--
-- Name: versions_id_seq; Type: SEQUENCE OWNED BY; Schema: public; Owner: -
--

ALTER SEQUENCE public.versions_id_seq OWNED BY public.versions.id;


--
-- Name: issue_categories id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issue_categories ALTER COLUMN id SET DEFAULT nextval('public.issue_categories_id_seq'::regclass);


--
-- Name: issues id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues ALTER COLUMN id SET DEFAULT nextval('public.issues_id_seq'::regclass);


--
-- Name: rls id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rls ALTER COLUMN id SET DEFAULT nextval('public.rls_id_seq'::regclass);


--
-- Name: sites id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites ALTER COLUMN id SET DEFAULT nextval('public.sites_id_seq'::regclass);


--
-- Name: users id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users ALTER COLUMN id SET DEFAULT nextval('public.users_id_seq'::regclass);


--
-- Name: versions id; Type: DEFAULT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions ALTER COLUMN id SET DEFAULT nextval('public.versions_id_seq'::regclass);


--
-- Data for Name: issue_categories; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (78, '数据库内核', 39, 2, 0, 'blue', '2026-05-18 20:53:10.348919', '2026-05-18 20:53:10.348919');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (79, '数据问题', 39, 2, 0, 'blue', '2026-05-18 20:53:15.80455', '2026-05-18 20:53:15.80455');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (80, '建联线程池', 76, 3, 0, 'blue', '2026-05-18 20:53:31.012314', '2026-05-18 20:53:31.012314');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (81, '业务连接池配置有误', 76, 3, 0, 'blue', '2026-05-18 20:53:43.020983', '2026-05-18 20:53:43.020983');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (36, '慢', NULL, 1, 0, 'blue', '2026-05-18 20:37:24.766803', '2026-05-18 20:37:24.766803');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (37, '满', NULL, 1, 0, 'blue', '2026-05-18 20:37:28.805845', '2026-05-18 20:37:28.805845');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (38, '宕', NULL, 1, 0, 'blue', '2026-05-18 20:37:32.469653', '2026-05-18 20:37:32.469653');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (39, '错', NULL, 1, 0, 'blue', '2026-05-18 20:37:36.165115', '2026-05-18 20:37:36.165115');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (40, '误删', NULL, 1, 0, 'blue', '2026-05-18 20:37:39.525196', '2026-05-18 20:37:39.525196');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (41, '单SQL慢', 36, 2, 0, 'blue', '2026-05-18 20:41:03.108928', '2026-05-18 20:41:03.108928');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (42, '整体SQL慢', 36, 2, 0, 'blue', '2026-05-18 20:41:10.875886', '2026-05-18 20:41:10.875886');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (43, '执行计划-代价估算不准', 41, 3, 0, 'blue', '2026-05-18 20:41:47.994979', '2026-05-18 20:41:47.994979');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (44, '执行计划-统计信息不准', 41, 3, 0, 'blue', '2026-05-18 20:42:00.970872', '2026-05-18 20:42:00.970872');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (45, '异常等待事件-BarrierLock', 41, 3, 0, 'blue', '2026-05-18 20:42:20.75468', '2026-05-18 20:42:20.75468');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (46, 'SQL并发高-并发增加', 42, 3, 0, 'blue', '2026-05-18 20:42:46.380624', '2026-05-18 20:42:46.380624');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (47, '底层故障-IO时延异常', 42, 3, 0, 'blue', '2026-05-18 20:43:06.394096', '2026-05-18 20:43:06.394096');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (48, '分布式不均衡', 42, 3, 0, 'blue', '2026-05-18 20:43:21.178031', '2026-05-18 20:43:21.178031');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (49, '计划生成慢-死元组积压', 42, 3, 0, 'blue', '2026-05-18 20:43:43.66702', '2026-05-18 20:43:43.66702');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (50, '全表扫描-缺少索引', 42, 3, 0, 'blue', '2026-05-18 20:43:56.769391', '2026-05-18 20:43:56.769391');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (51, '全表扫描-索引失效', 42, 3, 0, 'blue', '2026-05-18 20:44:08.26585', '2026-05-18 20:44:08.26585');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (52, '全表扫描-统计信息不及时', 42, 3, 0, 'blue', '2026-05-18 20:44:23.833169', '2026-05-18 20:44:23.833169');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (53, '死元组积压-长事务', 42, 3, 0, 'blue', '2026-05-18 20:44:48.090055', '2026-05-18 20:44:48.090055');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (54, '锁冲突（DDL）', 42, 3, 0, 'blue', '2026-05-18 20:45:01.466412', '2026-05-18 20:45:01.466412');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (55, '磁盘满', 37, 2, 0, 'blue', '2026-05-18 20:45:35.040899', '2026-05-18 20:45:35.040899');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (56, '磁盘只读', 37, 2, 0, 'blue', '2026-05-18 20:48:05.879837', '2026-05-18 20:48:05.879837');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (57, '数据库内存', 37, 2, 0, 'blue', '2026-05-18 20:48:12.934619', '2026-05-18 20:48:12.934619');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (58, 'XLOG堆积', 55, 3, 0, 'blue', '2026-05-18 20:48:26.438943', '2026-05-18 20:48:26.438943');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (59, 'XLOG堆积', 56, 3, 0, 'blue', '2026-05-18 20:48:44.887811', '2026-05-18 20:48:44.887811');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (60, '数据量大', 56, 3, 0, 'blue', '2026-05-18 20:48:54.614825', '2026-05-18 20:48:54.614825');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (61, '容灾切换失败', 56, 3, 0, 'blue', '2026-05-18 20:49:02.191392', '2026-05-18 20:49:02.191392');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (62, '临时文件', 56, 3, 0, 'blue', '2026-05-18 20:49:09.230633', '2026-05-18 20:49:09.230633');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (63, '动态内存', 57, 3, 0, 'blue', '2026-05-18 20:49:21.225798', '2026-05-18 20:49:21.225798');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (64, 'CN故障', 38, 2, 0, 'blue', '2026-05-18 20:49:41.830991', '2026-05-18 20:49:41.830991');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (65, '多数派故障', 38, 2, 0, 'blue', '2026-05-18 20:49:49.494785', '2026-05-18 20:49:49.494785');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (66, '浮动IP丢失', 38, 2, 0, 'blue', '2026-05-18 20:49:55.982479', '2026-05-18 20:49:55.982479');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (67, '节点HANG', 38, 2, 0, 'blue', '2026-05-18 20:50:05.573762', '2026-05-18 20:50:05.573762');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (68, 'CN未自动剔除', 64, 3, 0, 'blue', '2026-05-18 20:50:17.166863', '2026-05-18 20:50:17.166863');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (69, '底层故障导致全副本故障', 65, 3, 0, 'blue', '2026-05-18 20:50:40.918473', '2026-05-18 20:50:40.918473');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (70, '回放XLOG', 65, 3, 0, 'blue', '2026-05-18 20:50:53.918187', '2026-05-18 20:50:53.918187');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (71, '僵死检测', 65, 3, 0, 'blue', '2026-05-18 20:51:05.966326', '2026-05-18 20:51:05.966326');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (72, '配置错误（swap/cgroup）', 65, 3, 0, 'blue', '2026-05-18 20:51:27.40547', '2026-05-18 20:51:27.40547');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (73, '配置错误', 66, 3, 0, 'blue', '2026-05-18 20:51:43.053088', '2026-05-18 20:51:43.053088');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (74, 'HA未开启', 66, 3, 0, 'blue', '2026-05-18 20:51:51.574109', '2026-05-18 20:51:51.574109');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (75, 'GSQL审计日志耗尽', 67, 3, 0, 'blue', '2026-05-18 20:52:32.366565', '2026-05-18 20:52:32.366565');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (76, '连接问题', 39, 2, 0, 'blue', '2026-05-18 20:52:57.103739', '2026-05-18 20:52:57.103739');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (77, '容灾', 39, 2, 0, 'blue', '2026-05-18 20:53:04.301299', '2026-05-18 20:53:04.301299');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (82, '自主寻主错误', 76, 3, 0, 'blue', '2026-05-18 20:54:44.620347', '2026-05-18 20:54:44.620347');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (83, '容灾切换失败', 77, 3, 0, 'blue', '2026-05-18 20:55:04.011407', '2026-05-18 20:55:04.011407');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (84, '序列', 78, 3, 0, 'blue', '2026-05-18 20:55:18.460035', '2026-05-18 20:55:18.460035');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (85, '业务自身问题', 78, 3, 0, 'blue', '2026-05-18 20:55:27.587258', '2026-05-18 20:55:27.587258');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (86, 'UNDO超限', 78, 3, 0, 'blue', '2026-05-18 20:55:34.331413', '2026-05-18 20:55:40.532615');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (87, 'STREAM满', 78, 3, 0, 'blue', '2026-05-18 20:56:03.770989', '2026-05-18 20:56:03.770989');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (88, 'XID问题', 79, 3, 0, 'blue', '2026-05-18 20:56:21.923112', '2026-05-18 20:56:21.923112');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (89, '库表级恢复', 40, 2, 0, 'blue', '2026-05-18 20:56:50.181446', '2026-05-18 20:56:50.181446');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (90, '全量备份恢复', 40, 2, 0, 'blue', '2026-05-18 20:56:59.291197', '2026-05-18 20:56:59.291197');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (91, '误删实例', 40, 2, 0, 'blue', '2026-05-18 20:57:07.795052', '2026-05-18 20:57:07.795052');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (92, 'DROP', 89, 3, 0, 'blue', '2026-05-18 20:57:21.492876', '2026-05-18 20:57:21.492876');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (93, 'DELETE', 89, 3, 0, 'blue', '2026-05-18 20:57:28.850667', '2026-05-18 20:57:28.850667');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (94, 'UPDATE', 89, 3, 0, 'blue', '2026-05-18 20:57:34.1069', '2026-05-18 20:57:34.1069');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (95, 'UPDATE', 90, 3, 0, 'blue', '2026-05-18 20:57:49.018782', '2026-05-18 20:57:49.018782');
INSERT INTO public.issue_categories (id, name, parent_id, level, sort_order, color, created_at, updated_at) VALUES (96, '误删', 91, 3, 0, 'blue', '2026-05-18 20:57:59.801918', '2026-05-18 20:57:59.801918');


--
-- Data for Name: issues; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (35, 'SWAT-20260518-002', '2026-05-18 18:40:00', '南海农商银行', 'xlog堆积，导致磁盘满，集群状态异常，森岛帆高撒的发生懂法守法撒', '503.2', '待处理', '2026-05-19 20:41:56.929254', '2026-05-19 20:41:56.929254', '满 > 磁盘满 > XLOG堆积', NULL, NULL, 'HCS', '集中式', '刘帆', NULL, NULL, true, true, NULL, true, true, NULL, '2026-05-19 18:41:00', '2026-05-19 18:46:00', '2026-05-19 20:53:00', '2026-05-19 20:55:00', '2026-05-19 21:42:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-19');
INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (34, 'SWAT-20260518-001', '2026-05-18 20:35:00', '江苏银行', '森岛帆高感受到风格的说法干撒搭嘎', '503.2', '待处理', '2026-05-19 20:36:33.450277', '2026-05-20 09:16:16.119754', '满 > 数据库内存 > 动态内存', false, '金融', 'HCS', '分布式', '季超', '', '', true, true, NULL, true, false, NULL, '2026-05-19 18:35:00', '2026-05-19 18:37:00', '2026-05-19 18:41:00', '2026-05-19 18:54:00', '2026-05-19 19:36:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-19');
INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (36, 'SWAT-20260520-001', '2026-05-20 10:37:00', '江苏银行', '', '503.1', '待处理', '2026-05-20 10:37:24.926607', '2026-05-20 10:37:24.926607', '', NULL, NULL, 'HCS', '集中式', '季超', NULL, NULL, false, false, NULL, false, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-20');
INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (37, 'SWAT-20260520-002', '2026-05-20 10:44:00', '江苏银行', '', '503.1', '待处理', '2026-05-20 10:44:55.05907', '2026-05-20 10:44:55.05907', '', NULL, NULL, 'HCS', '集中式', '刘帆', NULL, NULL, true, false, NULL, false, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-20');
INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (38, 'SWAT-20260520-003', '2026-05-20 10:45:00', '江苏银行', '收到发斯蒂芬', '505.2.1.SPC0800', '待处理', '2026-05-20 10:45:43.970252', '2026-05-20 10:45:43.970252', '宕 > 多数派故障 > 回放XLOG', NULL, NULL, 'HCS', '集中式', '刘帆', NULL, NULL, true, true, NULL, true, false, NULL, '2026-05-20 10:47:00', '2026-05-20 10:58:00', '2026-05-20 11:36:00', '2026-05-20 11:45:00', '2026-05-20 12:34:00', NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-14');
INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (40, 'SWAT-20260520-004', '2026-05-20 00:00:00', '中国工商银行', '测试不填发生时间', '505.2.1.SPC0800', NULL, '2026-05-20 10:53:21.102672', '2026-05-20 10:53:21.102672', NULL, NULL, NULL, 'TPOPS', '集中式', 'RL001', NULL, NULL, false, false, NULL, true, false, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-20');
INSERT INTO public.issues (id, issue_no, occur_time, customer_name, description, kernel_version, status, created_at, updated_at, category, key_site, site_type, mgmt_deploy, kernel_deploy, rl, ops_ticket, ecare_ticket, biz_interrupt, urgent_recover, remark, has_alarm, alarm_trigger, find_remark, perceive_time, create_time, swat_start_time, bound_time, biz_recover_time, full_recover_time, time_remark, doc_link, screen_link, had_plan, has_plan, plan_name, handle_date) VALUES (41, 'SWAT-20260520-005', '2026-05-20 00:00:00', '江苏银行', '', '505.2.1.SPC0800', '待处理', '2026-05-20 10:54:39.741412', '2026-05-20 10:54:39.741412', '', NULL, NULL, 'TPOPS', '集中式', '刘帆', NULL, NULL, false, false, NULL, true, true, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, NULL, '2026-05-20');


--
-- Data for Name: rls; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.rls (id, name, created_at, updated_at) VALUES (1, '刘帆', '2026-05-19 21:08:11.925307', '2026-05-19 21:08:11.925307');
INSERT INTO public.rls (id, name, created_at, updated_at) VALUES (2, '季超', '2026-05-19 21:08:26.167925', '2026-05-19 21:08:26.167925');
INSERT INTO public.rls (id, name, created_at, updated_at) VALUES (3, '王飞', '2026-05-20 09:55:03.594532', '2026-05-20 09:55:03.594532');
INSERT INTO public.rls (id, name, created_at, updated_at) VALUES (4, '艾龙龙', '2026-05-20 09:55:13.561973', '2026-05-20 09:55:13.561973');
INSERT INTO public.rls (id, name, created_at, updated_at) VALUES (5, '李长军', '2026-05-20 09:55:18.241373', '2026-05-20 09:55:18.241373');


--
-- Data for Name: sites; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (6, '1', '中国工商银行', '北京', '', '', true, '2026-05-18 11:31:46.338215', '2026-05-18 14:48:02.926218', '[3,4]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (10, '6', '滨海农商银行', '天津', '', '', true, '2026-05-18 15:17:44.441372', '2026-05-18 15:24:00.258569', '[1,3]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (8, '4', '中国交通银行', '上海', '', '', true, '2026-05-18 11:32:23.84113', '2026-05-18 15:29:43.376546', '[4,3,1]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (5, '2', '中国农业银行', '北京', '', '', true, '2026-05-18 11:31:32.588008', '2026-05-18 15:30:20.855921', '[1,10]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (9, '5', '中国邮储银行', '河北', '', '', true, '2026-05-18 14:50:34.912139', '2026-05-18 15:30:28.08827', '[4,1,3,10]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (7, '3', '中国建设银行', '北京', '', '', true, '2026-05-18 11:32:14.202753', '2026-05-18 15:30:33.28813', '[4,3,1,9]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (11, '7', '南海农商银行', '广东', '', '', true, '2026-05-18 15:30:55.319495', '2026-05-18 15:30:55.319495', '[10,9,4,3,1]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (12, '8', '江苏银行', '江苏', '', '', true, '2026-05-18 21:06:13.381272', '2026-05-18 21:06:13.381272', '[9,4,3]');
INSERT INTO public.sites (id, code, name, region, contact, phone, active, created_at, updated_at, version_ids) VALUES (13, '9', '陕西国网', '陕西', '', '', true, '2026-05-19 09:48:16.236309', '2026-05-19 09:48:16.236309', '[9,10]');


--
-- Data for Name: users; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.users (id, username, password, email, created_at) VALUES (1, 'admin', '$2a$10$TfupDkYOm6mFBJq/x1To2ebZTUcjT0BJipz6T0LiMpGX.TAGcSSHa', 'admin@swat.com', '2026-05-18 10:09:41.532107');
INSERT INTO public.users (id, username, password, email, created_at) VALUES (2, 'testuser', '$2a$10$gd6290ijNEUAzXr5rpg/qemEM8xSAK6G5X9f5PYaHAlRf2D3YBMhS', 'test@swat.com', '2026-05-18 10:29:13.909088');


--
-- Data for Name: versions; Type: TABLE DATA; Schema: public; Owner: -
--

INSERT INTO public.versions (id, version_code, sites, release_date, status, notes, created_at, updated_at) VALUES (1, '503.0', '[5, 8, 9, 7, 10, 11]', '2026-04-15', 'released', '修复登录页样式问题，优化数据库连接池配置', '2026-05-18 11:45:11.196343', '2026-05-18 15:30:55.320705');
INSERT INTO public.versions (id, version_code, sites, release_date, status, notes, created_at, updated_at) VALUES (3, '505.2.1', '[8, 6, 9, 7, 10, 11, 12]', '2026-08-01', 'dev', '规划中：引入AI智能分析引擎', '2026-05-18 11:45:11.408836', '2026-05-18 21:06:13.382954');
INSERT INTO public.versions (id, version_code, sites, release_date, status, notes, created_at, updated_at) VALUES (4, '505.2.1.SPC0800', '[8, 6, 9, 7, 11, 12]', '2026-05-14', 'released', '金融稳定版', '2026-05-18 11:54:19.978314', '2026-05-18 21:06:13.383816');
INSERT INTO public.versions (id, version_code, sites, release_date, status, notes, created_at, updated_at) VALUES (9, '503.1', '[7, 11, 12, 13]', '2026-05-14', 'released', '', '2026-05-18 15:30:03.617399', '2026-05-19 09:48:16.238381');
INSERT INTO public.versions (id, version_code, sites, release_date, status, notes, created_at, updated_at) VALUES (10, '503.2', '[5, 9, 11, 13]', '2026-05-06', 'released', '', '2026-05-18 15:30:16.18225', '2026-05-19 09:48:16.239339');


--
-- Name: issue_categories_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.issue_categories_id_seq', 99, true);


--
-- Name: issues_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.issues_id_seq', 41, true);


--
-- Name: rls_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.rls_id_seq', 6, true);


--
-- Name: sites_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.sites_id_seq', 13, true);


--
-- Name: users_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.users_id_seq', 2, true);


--
-- Name: versions_id_seq; Type: SEQUENCE SET; Schema: public; Owner: -
--

SELECT pg_catalog.setval('public.versions_id_seq', 10, true);


--
-- Name: issue_categories issue_categories_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issue_categories
    ADD CONSTRAINT issue_categories_pkey PRIMARY KEY (id);


--
-- Name: issues issues_issue_no_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_issue_no_key UNIQUE (issue_no);


--
-- Name: issues issues_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issues
    ADD CONSTRAINT issues_pkey PRIMARY KEY (id);


--
-- Name: rls rls_name_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rls
    ADD CONSTRAINT rls_name_key UNIQUE (name);


--
-- Name: rls rls_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.rls
    ADD CONSTRAINT rls_pkey PRIMARY KEY (id);


--
-- Name: sites sites_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT sites_pkey PRIMARY KEY (id);


--
-- Name: sites uk_sites_name; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.sites
    ADD CONSTRAINT uk_sites_name UNIQUE (name);


--
-- Name: users users_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (id);


--
-- Name: users users_username_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.users
    ADD CONSTRAINT users_username_key UNIQUE (username);


--
-- Name: versions versions_pkey; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_pkey PRIMARY KEY (id);


--
-- Name: versions versions_version_code_key; Type: CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.versions
    ADD CONSTRAINT versions_version_code_key UNIQUE (version_code);


--
-- Name: issue_categories fk_cat_parent; Type: FK CONSTRAINT; Schema: public; Owner: -
--

ALTER TABLE ONLY public.issue_categories
    ADD CONSTRAINT fk_cat_parent FOREIGN KEY (parent_id) REFERENCES public.issue_categories(id) ON DELETE CASCADE;


--
-- PostgreSQL database dump complete
--

\unrestrict Fe49jtmyChaXsJPfDNiSwKgPe4So7hBBQuSwC3cQWNe6fah9nrUIcaMOhWr545N

