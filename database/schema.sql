-- Jonas AI Ops-Agent: PostgreSQL-Schema (nur Struktur, keine Daten)
-- Zur Veranschaulichung der Architektur; Mandantenfaehigkeit ueber tenant_id.

--
-- PostgreSQL database dump
--

-- Dumped from database version 16.14
-- Dumped by pg_dump version 16.14

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'UTF8';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

--
-- Name: pgcrypto; Type: EXTENSION; Schema: -; Owner: -
--

CREATE EXTENSION IF NOT EXISTS pgcrypto WITH SCHEMA public;

--
-- Name: EXTENSION pgcrypto; Type: COMMENT; Schema: -
--

COMMENT ON EXTENSION pgcrypto IS 'cryptographic functions';

--
-- Name: cleanup_expired_jonas_data(); Type: FUNCTION; Schema: public
--

CREATE FUNCTION public.cleanup_expired_jonas_data() RETURNS TABLE(deleted_messages integer, deleted_memory integer)
    LANGUAGE plpgsql
    AS $$
DECLARE
    msg_count INT;
    mem_count INT;
BEGIN
    DELETE FROM jonas_messages WHERE expires_at < NOW();
    GET DIAGNOSTICS msg_count = ROW_COUNT;

    DELETE FROM jonas_memory WHERE expires_at < NOW() AND status = 'done';
    GET DIAGNOSTICS mem_count = ROW_COUNT;

    RETURN QUERY SELECT msg_count, mem_count;
END;
$$;

SET default_tablespace = '';

SET default_table_access_method = heap;

--
-- Name: golden_set; Type: TABLE; Schema: public
--

CREATE TABLE public.golden_set (
    id integer NOT NULL,
    text text NOT NULL,
    expected_intent character varying(64) NOT NULL,
    category character varying(32),
    active boolean DEFAULT true NOT NULL,
    notes text,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: golden_set_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.golden_set_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: golden_set_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.golden_set_id_seq OWNED BY public.golden_set.id;

--
-- Name: jonas_abendrecap_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_abendrecap_sent (
    tenant_id character varying(64) NOT NULL,
    sent_date date NOT NULL
);

--
-- Name: jonas_briefing_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_briefing_sent (
    tenant_id character varying(64) DEFAULT 'default'::character varying NOT NULL,
    sent_date date NOT NULL
);

--
-- Name: jonas_call_log; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_call_log (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    number text NOT NULL,
    identified_as text,
    source text,
    spam_score numeric,
    call_type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_call_log_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_call_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_call_log_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_call_log_id_seq OWNED BY public.jonas_call_log.id;

--
-- Name: jonas_conversation_summary; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_conversation_summary (
    tenant_id text NOT NULL,
    summary_text text DEFAULT ''::text NOT NULL,
    covered_until timestamp with time zone,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_deal_stillstand_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_deal_stillstand_sent (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    deal_id text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_deal_stillstand_sent_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_deal_stillstand_sent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_deal_stillstand_sent_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_deal_stillstand_sent_id_seq OWNED BY public.jonas_deal_stillstand_sent.id;

--
-- Name: jonas_disambiguation; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_disambiguation (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying,
    action character varying(16),
    candidates jsonb,
    new_start_raw text,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone DEFAULT (now() + '00:05:00'::interval),
    note_text text,
    deal_stage_raw text
);

--
-- Name: jonas_email_lead_asked; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_email_lead_asked (
    tenant_id character varying(64) NOT NULL,
    sender text NOT NULL,
    asked_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_email_recent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_email_recent (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying NOT NULL,
    kategorie character varying(32),
    zusammenfassung text,
    draft_erstellt boolean DEFAULT false,
    sender character varying(255),
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '24:00:00'::interval) NOT NULL
);

--
-- Name: jonas_email_triage_lock; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_email_triage_lock (
    id integer DEFAULT 1 NOT NULL,
    running boolean DEFAULT false,
    started_at timestamp with time zone,
    CONSTRAINT jonas_email_triage_lock_id_check CHECK ((id = 1))
);

--
-- Name: jonas_followup_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_followup_sent (
    tenant_id character varying(64) NOT NULL,
    sent_date date NOT NULL
);

--
-- Name: jonas_golden_set; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_golden_set (
    id integer NOT NULL,
    test_text text NOT NULL,
    expected_intent character varying(32) NOT NULL,
    active boolean DEFAULT true NOT NULL
);

--
-- Name: jonas_golden_set_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_golden_set_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_golden_set_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_golden_set_id_seq OWNED BY public.jonas_golden_set.id;

--
-- Name: jonas_kalender_kategorien; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_kalender_kategorien (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) NOT NULL,
    event_id character varying(255) NOT NULL,
    category character varying(64) NOT NULL,
    source character varying(16) NOT NULL,
    title text,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: jonas_leads; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_leads (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) NOT NULL,
    name text NOT NULL,
    company text,
    contact_info text,
    source text,
    status text,
    notes text,
    hubspot_contact_id text,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    priority character varying(4),
    next_followup_at timestamp with time zone,
    language text DEFAULT 'de'::text NOT NULL
);

--
-- Name: jonas_mediagroup_photos; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_mediagroup_photos (
    media_group_id text NOT NULL,
    file_id text NOT NULL,
    caption text,
    tenant_id character varying(64),
    telegram_chat_id text,
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    update_id bigint
);

--
-- Name: jonas_mediagroup_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_mediagroup_sent (
    media_group_id text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_meeting_bots; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_meeting_bots (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id text NOT NULL,
    event_id text NOT NULL,
    event_title text,
    meeting_url text,
    telegram_chat_id text,
    recall_bot_id text,
    status text DEFAULT 'pending'::text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_meeting_nachbereitung_lock; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_meeting_nachbereitung_lock (
    id integer DEFAULT 1 NOT NULL,
    running boolean DEFAULT false NOT NULL,
    started_at timestamp with time zone
);

--
-- Name: jonas_memory; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_memory (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying NOT NULL,
    type character varying(32) NOT NULL,
    content text NOT NULL,
    due_date date,
    status character varying(16) DEFAULT 'open'::character varying NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '30 days'::interval) NOT NULL,
    amount numeric,
    CONSTRAINT jonas_memory_status_check CHECK (((status)::text = ANY ((ARRAY['open'::character varying, 'done'::character varying, 'snoozed'::character varying])::text[]))),
    CONSTRAINT jonas_memory_type_check CHECK (((type)::text = ANY ((ARRAY['deal'::character varying, 'task'::character varying, 'reminder'::character varying, 'note'::character varying])::text[])))
);

--
-- Name: jonas_messages; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_messages (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying NOT NULL,
    role character varying(16) NOT NULL,
    content text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '24:00:00'::interval) NOT NULL,
    CONSTRAINT jonas_messages_role_check CHECK (((role)::text = ANY ((ARRAY['user'::character varying, 'assistant'::character varying])::text[])))
);

--
-- Name: jonas_nachbereitung_nudge_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_nachbereitung_nudge_sent (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    event_id text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_nachbereitung_nudge_sent_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_nachbereitung_nudge_sent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_nachbereitung_nudge_sent_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_nachbereitung_nudge_sent_id_seq OWNED BY public.jonas_nachbereitung_nudge_sent.id;

--
-- Name: jonas_pending_actions; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_pending_actions (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying,
    action character varying(16),
    event_id text,
    event_title text,
    new_start timestamp with time zone,
    new_end timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone DEFAULT (now() + '00:10:00'::interval)
);

--
-- Name: jonas_pending_dealfollowup; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_pending_dealfollowup (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    deal_id text NOT NULL,
    deal_name text NOT NULL,
    contact_email text,
    draft_text text NOT NULL,
    note_text text NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '3 days'::interval) NOT NULL
);

--
-- Name: jonas_pending_dealfollowup_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_pending_dealfollowup_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_pending_dealfollowup_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_pending_dealfollowup_id_seq OWNED BY public.jonas_pending_dealfollowup.id;

--
-- Name: jonas_pending_events; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_pending_events (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    calendar_text text NOT NULL,
    expires_at timestamp with time zone DEFAULT (now() + '00:10:00'::interval) NOT NULL
);

--
-- Name: jonas_pending_events_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_pending_events_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_pending_events_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_pending_events_id_seq OWNED BY public.jonas_pending_events.id;

--
-- Name: jonas_pending_hubspot; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_pending_hubspot (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying,
    deal_id text,
    deal_name text,
    new_stage text,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone DEFAULT (now() + '00:10:00'::interval)
);

--
-- Name: jonas_pending_nachbereitung; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_pending_nachbereitung (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) NOT NULL,
    event_id text NOT NULL,
    subject text,
    created_at timestamp with time zone DEFAULT now(),
    expires_at timestamp with time zone NOT NULL
);

--
-- Name: jonas_prebrief_lock; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_prebrief_lock (
    id integer DEFAULT 1 NOT NULL,
    running boolean DEFAULT false NOT NULL,
    started_at timestamp with time zone
);

--
-- Name: jonas_prebrief_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_prebrief_sent (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    event_id text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_prebrief_sent_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_prebrief_sent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_prebrief_sent_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_prebrief_sent_id_seq OWNED BY public.jonas_prebrief_sent.id;

--
-- Name: jonas_premeeting_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_premeeting_sent (
    tenant_id character varying(64) NOT NULL,
    event_id text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_processed_mediagroups; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_processed_mediagroups (
    media_group_id text NOT NULL,
    tenant_id character varying(64),
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_processed_meetings; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_processed_meetings (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    event_id text NOT NULL,
    processed_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_processed_meetings_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_processed_meetings_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_processed_meetings_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_processed_meetings_id_seq OWNED BY public.jonas_processed_meetings.id;

--
-- Name: jonas_processed_updates; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_processed_updates (
    update_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: jonas_profile; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_profile (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) DEFAULT 'default'::character varying NOT NULL,
    key character varying(128) NOT NULL,
    value text NOT NULL,
    updated_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_recap_log; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_recap_log (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) NOT NULL,
    log_date date DEFAULT CURRENT_DATE NOT NULL,
    items_asked integer DEFAULT 0 NOT NULL,
    items_done integer DEFAULT 0 NOT NULL,
    created_at timestamp with time zone DEFAULT now()
);

--
-- Name: jonas_reminder_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_reminder_sent (
    id integer NOT NULL,
    tenant_id text NOT NULL,
    event_id text NOT NULL,
    sent_at timestamp with time zone DEFAULT now() NOT NULL
);

--
-- Name: jonas_reminder_sent_id_seq; Type: SEQUENCE; Schema: public
--

CREATE SEQUENCE public.jonas_reminder_sent_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

--
-- Name: jonas_reminder_sent_id_seq; Type: SEQUENCE OWNED BY; Schema: public
--

ALTER SEQUENCE public.jonas_reminder_sent_id_seq OWNED BY public.jonas_reminder_sent.id;

--
-- Name: jonas_request_log; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_request_log (
    update_id bigint NOT NULL,
    tenant_id character varying(64),
    received_at timestamp with time zone DEFAULT now() NOT NULL,
    answered_at timestamp with time zone,
    intent character varying(32),
    input_type character varying(16),
    model character varying(64),
    latency_ms integer,
    error text
);

--
-- Name: jonas_terminerinnerung_lock; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_terminerinnerung_lock (
    id integer DEFAULT 1 NOT NULL,
    running boolean DEFAULT false NOT NULL,
    started_at timestamp with time zone
);

--
-- Name: jonas_weekly_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_weekly_sent (
    tenant_id character varying(64) NOT NULL,
    sent_week character varying(8) NOT NULL
);

--
-- Name: jonas_wichtig_sent; Type: TABLE; Schema: public
--

CREATE TABLE public.jonas_wichtig_sent (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) NOT NULL,
    event_id character varying(255) NOT NULL,
    sent_at timestamp with time zone DEFAULT now()
);

--
-- Name: system_config; Type: TABLE; Schema: public
--

CREATE TABLE public.system_config (
    key character varying(64) NOT NULL,
    value text
);

--
-- Name: tenant_credentials; Type: TABLE; Schema: public
--

CREATE TABLE public.tenant_credentials (
    id uuid DEFAULT gen_random_uuid() NOT NULL,
    tenant_id character varying(64) NOT NULL,
    provider character varying(32) NOT NULL,
    access_token bytea,
    refresh_token bytea,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT now(),
    updated_at timestamp with time zone DEFAULT now()
);

--
-- Name: tenants; Type: TABLE; Schema: public
--

CREATE TABLE public.tenants (
    tenant_id character varying(64) NOT NULL,
    telegram_chat_id bigint,
    email character varying(255),
    status character varying(16) DEFAULT 'pending'::character varying,
    plan character varying(32),
    signup_token character varying(64),
    created_at timestamp with time zone DEFAULT now(),
    paid boolean DEFAULT false NOT NULL,
    channel character varying(16) DEFAULT 'stable'::character varying NOT NULL
);

--
-- Name: golden_set id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.golden_set ALTER COLUMN id SET DEFAULT nextval('public.golden_set_id_seq'::regclass);

--
-- Name: jonas_call_log id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_call_log ALTER COLUMN id SET DEFAULT nextval('public.jonas_call_log_id_seq'::regclass);

--
-- Name: jonas_deal_stillstand_sent id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_deal_stillstand_sent ALTER COLUMN id SET DEFAULT nextval('public.jonas_deal_stillstand_sent_id_seq'::regclass);

--
-- Name: jonas_golden_set id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_golden_set ALTER COLUMN id SET DEFAULT nextval('public.jonas_golden_set_id_seq'::regclass);

--
-- Name: jonas_nachbereitung_nudge_sent id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_nachbereitung_nudge_sent ALTER COLUMN id SET DEFAULT nextval('public.jonas_nachbereitung_nudge_sent_id_seq'::regclass);

--
-- Name: jonas_pending_dealfollowup id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_dealfollowup ALTER COLUMN id SET DEFAULT nextval('public.jonas_pending_dealfollowup_id_seq'::regclass);

--
-- Name: jonas_pending_events id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_events ALTER COLUMN id SET DEFAULT nextval('public.jonas_pending_events_id_seq'::regclass);

--
-- Name: jonas_prebrief_sent id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_prebrief_sent ALTER COLUMN id SET DEFAULT nextval('public.jonas_prebrief_sent_id_seq'::regclass);

--
-- Name: jonas_processed_meetings id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_processed_meetings ALTER COLUMN id SET DEFAULT nextval('public.jonas_processed_meetings_id_seq'::regclass);

--
-- Name: jonas_reminder_sent id; Type: DEFAULT; Schema: public
--

ALTER TABLE ONLY public.jonas_reminder_sent ALTER COLUMN id SET DEFAULT nextval('public.jonas_reminder_sent_id_seq'::regclass);

--
-- Name: golden_set golden_set_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.golden_set
    ADD CONSTRAINT golden_set_pkey PRIMARY KEY (id);

--
-- Name: jonas_abendrecap_sent jonas_abendrecap_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_abendrecap_sent
    ADD CONSTRAINT jonas_abendrecap_sent_pkey PRIMARY KEY (tenant_id, sent_date);

--
-- Name: jonas_briefing_sent jonas_briefing_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_briefing_sent
    ADD CONSTRAINT jonas_briefing_sent_pkey PRIMARY KEY (tenant_id, sent_date);

--
-- Name: jonas_call_log jonas_call_log_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_call_log
    ADD CONSTRAINT jonas_call_log_pkey PRIMARY KEY (id);

--
-- Name: jonas_conversation_summary jonas_conversation_summary_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_conversation_summary
    ADD CONSTRAINT jonas_conversation_summary_pkey PRIMARY KEY (tenant_id);

--
-- Name: jonas_deal_stillstand_sent jonas_deal_stillstand_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_deal_stillstand_sent
    ADD CONSTRAINT jonas_deal_stillstand_sent_pkey PRIMARY KEY (id);

--
-- Name: jonas_deal_stillstand_sent jonas_deal_stillstand_sent_tenant_id_deal_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_deal_stillstand_sent
    ADD CONSTRAINT jonas_deal_stillstand_sent_tenant_id_deal_id_key UNIQUE (tenant_id, deal_id);

--
-- Name: jonas_disambiguation jonas_disambiguation_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_disambiguation
    ADD CONSTRAINT jonas_disambiguation_pkey PRIMARY KEY (id);

--
-- Name: jonas_email_lead_asked jonas_email_lead_asked_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_email_lead_asked
    ADD CONSTRAINT jonas_email_lead_asked_pkey PRIMARY KEY (tenant_id, sender);

--
-- Name: jonas_email_recent jonas_email_recent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_email_recent
    ADD CONSTRAINT jonas_email_recent_pkey PRIMARY KEY (id);

--
-- Name: jonas_email_triage_lock jonas_email_triage_lock_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_email_triage_lock
    ADD CONSTRAINT jonas_email_triage_lock_pkey PRIMARY KEY (id);

--
-- Name: jonas_followup_sent jonas_followup_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_followup_sent
    ADD CONSTRAINT jonas_followup_sent_pkey PRIMARY KEY (tenant_id, sent_date);

--
-- Name: jonas_golden_set jonas_golden_set_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_golden_set
    ADD CONSTRAINT jonas_golden_set_pkey PRIMARY KEY (id);

--
-- Name: jonas_kalender_kategorien jonas_kalender_kategorien_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_kalender_kategorien
    ADD CONSTRAINT jonas_kalender_kategorien_pkey PRIMARY KEY (id);

--
-- Name: jonas_kalender_kategorien jonas_kalender_kategorien_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_kalender_kategorien
    ADD CONSTRAINT jonas_kalender_kategorien_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: jonas_leads jonas_leads_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_leads
    ADD CONSTRAINT jonas_leads_pkey PRIMARY KEY (id);

--
-- Name: jonas_mediagroup_photos jonas_mediagroup_photos_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_mediagroup_photos
    ADD CONSTRAINT jonas_mediagroup_photos_pkey PRIMARY KEY (media_group_id, file_id);

--
-- Name: jonas_mediagroup_sent jonas_mediagroup_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_mediagroup_sent
    ADD CONSTRAINT jonas_mediagroup_sent_pkey PRIMARY KEY (media_group_id);

--
-- Name: jonas_meeting_bots jonas_meeting_bots_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_meeting_bots
    ADD CONSTRAINT jonas_meeting_bots_pkey PRIMARY KEY (id);

--
-- Name: jonas_meeting_bots jonas_meeting_bots_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_meeting_bots
    ADD CONSTRAINT jonas_meeting_bots_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: jonas_meeting_nachbereitung_lock jonas_meeting_nachbereitung_lock_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_meeting_nachbereitung_lock
    ADD CONSTRAINT jonas_meeting_nachbereitung_lock_pkey PRIMARY KEY (id);

--
-- Name: jonas_memory jonas_memory_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_memory
    ADD CONSTRAINT jonas_memory_pkey PRIMARY KEY (id);

--
-- Name: jonas_messages jonas_messages_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_messages
    ADD CONSTRAINT jonas_messages_pkey PRIMARY KEY (id);

--
-- Name: jonas_nachbereitung_nudge_sent jonas_nachbereitung_nudge_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_nachbereitung_nudge_sent
    ADD CONSTRAINT jonas_nachbereitung_nudge_sent_pkey PRIMARY KEY (id);

--
-- Name: jonas_nachbereitung_nudge_sent jonas_nachbereitung_nudge_sent_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_nachbereitung_nudge_sent
    ADD CONSTRAINT jonas_nachbereitung_nudge_sent_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: jonas_pending_actions jonas_pending_actions_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_actions
    ADD CONSTRAINT jonas_pending_actions_pkey PRIMARY KEY (id);

--
-- Name: jonas_pending_dealfollowup jonas_pending_dealfollowup_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_dealfollowup
    ADD CONSTRAINT jonas_pending_dealfollowup_pkey PRIMARY KEY (id);

--
-- Name: jonas_pending_events jonas_pending_events_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_events
    ADD CONSTRAINT jonas_pending_events_pkey PRIMARY KEY (id);

--
-- Name: jonas_pending_hubspot jonas_pending_hubspot_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_hubspot
    ADD CONSTRAINT jonas_pending_hubspot_pkey PRIMARY KEY (id);

--
-- Name: jonas_pending_nachbereitung jonas_pending_nachbereitung_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_pending_nachbereitung
    ADD CONSTRAINT jonas_pending_nachbereitung_pkey PRIMARY KEY (id);

--
-- Name: jonas_prebrief_lock jonas_prebrief_lock_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_prebrief_lock
    ADD CONSTRAINT jonas_prebrief_lock_pkey PRIMARY KEY (id);

--
-- Name: jonas_prebrief_sent jonas_prebrief_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_prebrief_sent
    ADD CONSTRAINT jonas_prebrief_sent_pkey PRIMARY KEY (id);

--
-- Name: jonas_prebrief_sent jonas_prebrief_sent_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_prebrief_sent
    ADD CONSTRAINT jonas_prebrief_sent_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: jonas_premeeting_sent jonas_premeeting_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_premeeting_sent
    ADD CONSTRAINT jonas_premeeting_sent_pkey PRIMARY KEY (tenant_id, event_id);

--
-- Name: jonas_processed_mediagroups jonas_processed_mediagroups_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_processed_mediagroups
    ADD CONSTRAINT jonas_processed_mediagroups_pkey PRIMARY KEY (media_group_id);

--
-- Name: jonas_processed_meetings jonas_processed_meetings_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_processed_meetings
    ADD CONSTRAINT jonas_processed_meetings_pkey PRIMARY KEY (id);

--
-- Name: jonas_processed_meetings jonas_processed_meetings_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_processed_meetings
    ADD CONSTRAINT jonas_processed_meetings_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: jonas_processed_updates jonas_processed_updates_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_processed_updates
    ADD CONSTRAINT jonas_processed_updates_pkey PRIMARY KEY (update_id);

--
-- Name: jonas_profile jonas_profile_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_profile
    ADD CONSTRAINT jonas_profile_pkey PRIMARY KEY (id);

--
-- Name: jonas_profile jonas_profile_tenant_id_key_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_profile
    ADD CONSTRAINT jonas_profile_tenant_id_key_key UNIQUE (tenant_id, key);

--
-- Name: jonas_recap_log jonas_recap_log_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_recap_log
    ADD CONSTRAINT jonas_recap_log_pkey PRIMARY KEY (id);

--
-- Name: jonas_recap_log jonas_recap_log_tenant_id_log_date_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_recap_log
    ADD CONSTRAINT jonas_recap_log_tenant_id_log_date_key UNIQUE (tenant_id, log_date);

--
-- Name: jonas_reminder_sent jonas_reminder_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_reminder_sent
    ADD CONSTRAINT jonas_reminder_sent_pkey PRIMARY KEY (id);

--
-- Name: jonas_reminder_sent jonas_reminder_sent_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_reminder_sent
    ADD CONSTRAINT jonas_reminder_sent_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: jonas_request_log jonas_request_log_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_request_log
    ADD CONSTRAINT jonas_request_log_pkey PRIMARY KEY (update_id);

--
-- Name: jonas_terminerinnerung_lock jonas_terminerinnerung_lock_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_terminerinnerung_lock
    ADD CONSTRAINT jonas_terminerinnerung_lock_pkey PRIMARY KEY (id);

--
-- Name: jonas_weekly_sent jonas_weekly_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_weekly_sent
    ADD CONSTRAINT jonas_weekly_sent_pkey PRIMARY KEY (tenant_id, sent_week);

--
-- Name: jonas_wichtig_sent jonas_wichtig_sent_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_wichtig_sent
    ADD CONSTRAINT jonas_wichtig_sent_pkey PRIMARY KEY (id);

--
-- Name: jonas_wichtig_sent jonas_wichtig_sent_tenant_id_event_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.jonas_wichtig_sent
    ADD CONSTRAINT jonas_wichtig_sent_tenant_id_event_id_key UNIQUE (tenant_id, event_id);

--
-- Name: system_config system_config_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.system_config
    ADD CONSTRAINT system_config_pkey PRIMARY KEY (key);

--
-- Name: tenant_credentials tenant_credentials_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.tenant_credentials
    ADD CONSTRAINT tenant_credentials_pkey PRIMARY KEY (id);

--
-- Name: tenant_credentials tenant_credentials_tenant_id_provider_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.tenant_credentials
    ADD CONSTRAINT tenant_credentials_tenant_id_provider_key UNIQUE (tenant_id, provider);

--
-- Name: tenants tenants_pkey; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_pkey PRIMARY KEY (tenant_id);

--
-- Name: tenants tenants_signup_token_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_signup_token_key UNIQUE (signup_token);

--
-- Name: tenants tenants_telegram_chat_id_key; Type: CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.tenants
    ADD CONSTRAINT tenants_telegram_chat_id_key UNIQUE (telegram_chat_id);

--
-- Name: idx_jonas_call_log_tenant_created; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_call_log_tenant_created ON public.jonas_call_log USING btree (tenant_id, created_at DESC);

--
-- Name: idx_jonas_disambiguation_tenant_expires; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_disambiguation_tenant_expires ON public.jonas_disambiguation USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_email_recent_tenant; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_email_recent_tenant ON public.jonas_email_recent USING btree (tenant_id, created_at DESC);

--
-- Name: idx_jonas_email_recent_tenant_expires; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_email_recent_tenant_expires ON public.jonas_email_recent USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_leads_tenant_updated; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_leads_tenant_updated ON public.jonas_leads USING btree (tenant_id, updated_at DESC);

--
-- Name: idx_jonas_meeting_bots_bot_id; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_meeting_bots_bot_id ON public.jonas_meeting_bots USING btree (recall_bot_id);

--
-- Name: idx_jonas_memory_expires; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_memory_expires ON public.jonas_memory USING btree (expires_at);

--
-- Name: idx_jonas_memory_tenant_status; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_memory_tenant_status ON public.jonas_memory USING btree (tenant_id, status, type);

--
-- Name: idx_jonas_messages_expires; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_messages_expires ON public.jonas_messages USING btree (expires_at);

--
-- Name: idx_jonas_messages_tenant_created; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_messages_tenant_created ON public.jonas_messages USING btree (tenant_id, created_at DESC);

--
-- Name: idx_jonas_messages_tenant_time; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_messages_tenant_time ON public.jonas_messages USING btree (tenant_id, created_at DESC);

--
-- Name: idx_jonas_nachbereitung_nudge_sent_lookup; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_nachbereitung_nudge_sent_lookup ON public.jonas_nachbereitung_nudge_sent USING btree (tenant_id, event_id);

--
-- Name: idx_jonas_pending_actions_tenant_expires; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_pending_actions_tenant_expires ON public.jonas_pending_actions USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_pending_dealfollowup_lookup; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_pending_dealfollowup_lookup ON public.jonas_pending_dealfollowup USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_pending_events_lookup; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_pending_events_lookup ON public.jonas_pending_events USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_pending_hubspot_tenant_expires; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_pending_hubspot_tenant_expires ON public.jonas_pending_hubspot USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_pending_nachbereitung_tenant; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_pending_nachbereitung_tenant ON public.jonas_pending_nachbereitung USING btree (tenant_id, expires_at);

--
-- Name: idx_jonas_processed_meetings_lookup; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_processed_meetings_lookup ON public.jonas_processed_meetings USING btree (tenant_id, event_id);

--
-- Name: idx_jonas_profile_tenant; Type: INDEX; Schema: public
--

CREATE INDEX idx_jonas_profile_tenant ON public.jonas_profile USING btree (tenant_id);

--
-- Name: idx_tenant_credentials_tenant_provider; Type: INDEX; Schema: public
--

CREATE INDEX idx_tenant_credentials_tenant_provider ON public.tenant_credentials USING btree (tenant_id, provider);

--
-- Name: tenant_credentials tenant_credentials_tenant_id_fkey; Type: FK CONSTRAINT; Schema: public
--

ALTER TABLE ONLY public.tenant_credentials
    ADD CONSTRAINT tenant_credentials_tenant_id_fkey FOREIGN KEY (tenant_id) REFERENCES public.tenants(tenant_id);

--
-- PostgreSQL database dump complete
--

