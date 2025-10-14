--
-- PostgreSQL database dump
--

-- Dumped from database version 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1)
-- Dumped by pg_dump version 14.15 (Ubuntu 14.15-0ubuntu0.22.04.1)

SET statement_timeout = 0;
SET lock_timeout = 0;
SET idle_in_transaction_session_timeout = 0;
SET client_encoding = 'SQL_ASCII';
SET standard_conforming_strings = on;
SELECT pg_catalog.set_config('search_path', '', false);
SET check_function_bodies = false;
SET xmloption = content;
SET client_min_messages = warning;
SET row_security = off;

CREATE SCHEMA alerts;
CREATE SCHEMA audio;
CREATE SCHEMA auto;
CREATE SCHEMA commands;
CREATE SCHEMA counting;
CREATE SCHEMA disboard;
CREATE SCHEMA family;
CREATE SCHEMA feeds;
CREATE SCHEMA fortnite;
CREATE SCHEMA fun;
CREATE SCHEMA history;
CREATE SCHEMA invoke_history;
CREATE SCHEMA joindm;
CREATE SCHEMA lastfm;
CREATE SCHEMA level;
CREATE SCHEMA music;
CREATE SCHEMA porn;
CREATE SCHEMA reposters;
CREATE SCHEMA reskin;
CREATE SCHEMA snipe;
CREATE SCHEMA spam;
CREATE SCHEMA statistics;
CREATE SCHEMA stats;
CREATE SCHEMA streaks;
CREATE SCHEMA ticket;
CREATE SCHEMA timer;
CREATE SCHEMA track;
CREATE SCHEMA transcribe;
CREATE SCHEMA voice;
CREATE SCHEMA voicemaster;
CREATE SCHEMA verification;

CREATE EXTENSION IF NOT EXISTS citext WITH SCHEMA public;
COMMENT ON EXTENSION citext IS 'data type for case-insensitive character strings';

SET default_tablespace = '';
SET default_table_access_method = heap;

CREATE TABLE alerts.twitch (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    twitch_id bigint NOT NULL,
    twitch_login text NOT NULL,
    last_stream_id bigint,
    role_id bigint,
    template text
);

CREATE TABLE audio.config (
    guild_id bigint NOT NULL,
    volume integer NOT NULL
);

CREATE TABLE audio.playlist_tracks (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    playlist_url text NOT NULL,
    track_title text NOT NULL,
    track_uri text NOT NULL,
    track_author text NOT NULL,
    album_name text,
    artwork_url text,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE audio.playlists (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    playlist_name text NOT NULL,
    playlist_url text NOT NULL,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    track_count integer NOT NULL
);

CREATE TABLE audio.recently_played (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    track_title text NOT NULL,
    track_uri text NOT NULL,
    track_author text NOT NULL,
    artwork_url text,
    played_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    playlist_name text,
    playlist_url text
);

CREATE TABLE audio.statistics (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    tracks_played integer DEFAULT 0 NOT NULL
);

CREATE TABLE auto.media (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    type text NOT NULL,
    category text NOT NULL,
    CONSTRAINT media_type_check CHECK ((type = ANY (ARRAY['banner'::text, 'pfp'::text])))
);

CREATE SEQUENCE auto.media_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE auto.media_id_seq OWNED BY auto.media.id;

CREATE TABLE commands.disabled (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    command text NOT NULL
);

CREATE TABLE commands.ignore (
    guild_id bigint NOT NULL,
    target_id bigint NOT NULL
);

CREATE TABLE commands.restricted (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    command text NOT NULL
);

CREATE TABLE commands.usage (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    user_id bigint NOT NULL,
    command text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE counting.config (
    guild_id bigint NOT NULL,
    channel_id bigint,
    current_count integer DEFAULT 0,
    high_score integer DEFAULT 0,
    safe_mode boolean DEFAULT false,
    allow_fails boolean DEFAULT false,
    last_user_id bigint,
    success_emoji text DEFAULT '✅'::text,
    fail_emoji text DEFAULT '❌'::text
);

CREATE TABLE disboard.bump (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    bumped_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE disboard.config (
    guild_id bigint NOT NULL,
    status boolean DEFAULT true NOT NULL,
    channel_id bigint,
    last_channel_id bigint,
    last_user_id bigint,
    message text,
    thank_message text,
    next_bump timestamp with time zone
);

CREATE TABLE family.marriages (
    user_id bigint NOT NULL,
    partner_id bigint NOT NULL,
    marriage_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    active boolean DEFAULT true
);

CREATE TABLE family.members (
    user_id bigint NOT NULL,
    related_id bigint NOT NULL,
    relationship text
);

CREATE TABLE family.profiles (
    user_id bigint NOT NULL,
    bio text
);

CREATE TABLE feeds.instagram (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    instagram_id bigint NOT NULL,
    instagram_name text NOT NULL,
    template text
);

CREATE TABLE feeds.pinterest (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    pinterest_id text NOT NULL,
    pinterest_name text NOT NULL,
    board text,
    board_id text,
    embeds boolean DEFAULT true NOT NULL,
    only_new boolean DEFAULT false NOT NULL
);

CREATE TABLE feeds.reddit (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    subreddit_name text NOT NULL
);

CREATE TABLE feeds.soundcloud (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    soundcloud_id bigint NOT NULL,
    soundcloud_name text NOT NULL,
    template text
);

CREATE TABLE feeds.tiktok (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    tiktok_id bigint NOT NULL,
    tiktok_name text NOT NULL,
    template text
);

CREATE TABLE feeds.twitter (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    twitter_id bigint NOT NULL,
    twitter_name text NOT NULL,
    template text,
    color text
);

CREATE TABLE feeds.youtube (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    youtube_id text NOT NULL,
    youtube_name text NOT NULL,
    template text,
    shorts boolean DEFAULT false NOT NULL
);

CREATE TABLE fortnite."authorization" (
    user_id bigint NOT NULL,
    display_name text NOT NULL,
    account_id text NOT NULL,
    access_token text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    refresh_token text NOT NULL
);

CREATE TABLE fortnite.reminder (
    user_id bigint NOT NULL,
    item_id text NOT NULL,
    item_name text NOT NULL,
    item_type text NOT NULL
);

CREATE TABLE fortnite.rotation (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message text
);

CREATE TABLE fun.wyr_channels (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    rating character varying(4) DEFAULT 'pg13'::character varying NOT NULL
);

CREATE TABLE history.moderation (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    moderator_id bigint NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    reason text NOT NULL,
    action text DEFAULT 'Unknown'::text NOT NULL,
    duration interval,
    guild_id bigint DEFAULT 0 NOT NULL,
    case_id integer DEFAULT 0 NOT NULL,
    role_id bigint
);

CREATE SEQUENCE history.moderation_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE history.moderation_id_seq OWNED BY history.moderation.id;

CREATE TABLE invoke_history.commands (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    command_name text NOT NULL,
    category text NOT NULL,
    "timestamp" timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    guild_id bigint NOT NULL
);

CREATE SEQUENCE invoke_history.commands_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE invoke_history.commands_id_seq OWNED BY invoke_history.commands.id;

CREATE TABLE joindm.config (
    guild_id bigint NOT NULL,
    message text,
    enabled boolean DEFAULT false
);

CREATE TABLE lastfm.albums (
    user_id bigint NOT NULL,
    username text NOT NULL,
    artist public.citext NOT NULL,
    album public.citext NOT NULL,
    plays bigint NOT NULL
);

CREATE TABLE lastfm.artists (
    user_id bigint NOT NULL,
    username text NOT NULL,
    artist public.citext NOT NULL,
    plays bigint NOT NULL
);

CREATE TABLE lastfm.config (
    user_id bigint NOT NULL,
    username public.citext NOT NULL,
    color bigint,
    command text,
    reactions text[] DEFAULT '{}'::text[] NOT NULL,
    embed_mode text DEFAULT 'default'::text NOT NULL,
    last_indexed timestamp with time zone DEFAULT now() NOT NULL,
    access_token text,
    web_authentication boolean DEFAULT false
);

CREATE TABLE lastfm.crown_updates (
    guild_id bigint NOT NULL,
    last_update timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE lastfm.crowns (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    artist public.citext NOT NULL,
    claimed_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE lastfm.hidden (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE lastfm.tracks (
    user_id bigint NOT NULL,
    username text NOT NULL,
    artist public.citext NOT NULL,
    track public.citext NOT NULL,
    plays bigint NOT NULL
);

CREATE TABLE level.config (
    guild_id bigint NOT NULL,
    status boolean DEFAULT true NOT NULL,
    cooldown integer DEFAULT 60 NOT NULL,
    max_level integer DEFAULT 0 NOT NULL,
    stack_roles boolean DEFAULT true NOT NULL,
    formula_multiplier double precision DEFAULT 1 NOT NULL,
    xp_multiplier double precision DEFAULT 1 NOT NULL,
    xp_min integer DEFAULT 15 NOT NULL,
    xp_max integer DEFAULT 40 NOT NULL,
    effort_status boolean DEFAULT false NOT NULL,
    effort_text bigint DEFAULT 25 NOT NULL,
    effort_image bigint DEFAULT 3 NOT NULL,
    effort_booster bigint DEFAULT 10 NOT NULL
);

CREATE TABLE level.member (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    xp integer DEFAULT 0 NOT NULL,
    level integer DEFAULT 0 NOT NULL,
    total_xp integer DEFAULT 0 NOT NULL,
    last_message timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE level.notification (
    guild_id bigint NOT NULL,
    channel_id bigint,
    dm boolean DEFAULT false NOT NULL,
    template text
);

CREATE TABLE level.role (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    level integer NOT NULL
);

CREATE TABLE music.history (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    title text NOT NULL,
    artist text NOT NULL,
    duration integer NOT NULL,
    thumbnail text NOT NULL,
    uri text NOT NULL,
    played_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE SEQUENCE music.history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE music.history_id_seq OWNED BY music.history.id;

CREATE TABLE music.playlist_tracks (
    id integer NOT NULL,
    playlist_id integer,
    title text NOT NULL,
    artist text NOT NULL,
    duration integer NOT NULL,
    thumbnail text NOT NULL,
    uri text NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    added_by bigint NOT NULL
);

CREATE SEQUENCE music.playlist_tracks_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE music.playlist_tracks_id_seq OWNED BY music.playlist_tracks.id;

CREATE TABLE music.playlists (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    name text NOT NULL,
    thumbnail text DEFAULT 'https://img.freepik.com/premium-photo/treble-clef-circle-musical-notes-black-background-design-3d-illustration_116124-10456.jpg?semt=ais'::text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE SEQUENCE music.playlists_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE music.playlists_id_seq OWNED BY music.playlists.id;

CREATE TABLE porn.config (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    webhook_id bigint NOT NULL,
    webhook_token text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    spoiler boolean DEFAULT false NOT NULL
);

CREATE TABLE public.access_tokens (
    user_id bigint NOT NULL,
    token text NOT NULL,
    created_at timestamp with time zone NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    discord_token text
);

CREATE TABLE public.afk (
    user_id bigint NOT NULL,
    status text DEFAULT 'AFK'::text NOT NULL,
    left_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.aliases (
    guild_id bigint NOT NULL,
    name text NOT NULL,
    invoke text NOT NULL,
    command text NOT NULL
);

CREATE TABLE public.antinuke (
    guild_id bigint NOT NULL,
    whitelist bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    trusted_admins bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    bot boolean DEFAULT false NOT NULL,
    ban jsonb,
    kick jsonb,
    role jsonb,
    channel jsonb,
    webhook jsonb,
    emoji jsonb
);

CREATE TABLE public.antiraid (
    guild_id bigint NOT NULL,
    locked boolean DEFAULT false NOT NULL,
    joins jsonb,
    mentions jsonb,
    avatar jsonb,
    browser jsonb
);

CREATE TABLE public.appeal_config (
    guild_id bigint NOT NULL,
    appeal_server_id bigint,
    appeal_channel_id bigint,
    logs_channel_id bigint,
    questions jsonb DEFAULT '[{"long": false, "question": "Why were you punished?", "required": true}, {"long": true, "question": "Why should we accept your appeal?", "required": true}, {"long": true, "question": "What will you do differently?", "required": true}]'::jsonb,
    direct_appeal boolean DEFAULT false,
    bypass_roles bigint[] DEFAULT ARRAY[]::bigint[]
);

CREATE TABLE public.appeal_templates (
    guild_id bigint NOT NULL,
    name character varying(100) NOT NULL,
    response text
);

CREATE TABLE public.appeals (
    id bigint NOT NULL,
    guild_id bigint,
    user_id bigint,
    moderator_id bigint,
    action_type character varying(32),
    reason text,
    status character varying(16) DEFAULT 'pending'::character varying,
    flags text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.appeals_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.appeals_id_seq OWNED BY public.appeals.id;

CREATE TABLE public.auto_role (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    action text NOT NULL,
    delay integer
);

CREATE TABLE public.autokick (
    user_id bigint,
    guild_id bigint,
    reason text,
    author_id bigint
);

CREATE TABLE public.avatar_current (
    user_id bigint NOT NULL,
    avatar_hash text NOT NULL,
    avatar_url text NOT NULL,
    last_updated timestamp without time zone DEFAULT now()
);

CREATE TABLE public.avatar_history (
    user_id bigint NOT NULL,
    avatar_url text NOT NULL,
    "timestamp" timestamp without time zone DEFAULT now(),
    deleted_at timestamp without time zone
);

CREATE TABLE public.avatar_history_settings (
    user_id bigint NOT NULL,
    enabled boolean DEFAULT false
);

CREATE TABLE public.backup (
    key text NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    data text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.beta_dashboard (
    user_id bigint NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    added_by bigint,
    notes text
);

CREATE TABLE public.birthdays (
    user_id bigint NOT NULL,
    birthday timestamp without time zone NOT NULL
);

CREATE TABLE public.blacklist (
    user_id bigint NOT NULL,
    information text
);

CREATE TABLE public.blunt (
    guild_id bigint NOT NULL,
    user_id bigint,
    hits bigint DEFAULT 0,
    passes bigint DEFAULT 0,
    members jsonb[] DEFAULT '{}'::jsonb[]
);

CREATE TABLE public.boost_history (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    boost_count integer DEFAULT 0,
    first_boost_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    last_boost_date timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.boost_message (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    template text NOT NULL,
    delete_after integer
);

CREATE TABLE public.booster_role (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    role_id bigint NOT NULL,
    shared boolean,
    multi_boost_enabled boolean DEFAULT false
);

CREATE TABLE public.boosters_lost (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    lasted_for interval NOT NULL,
    ended_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.business_jobs (
    job_id integer NOT NULL,
    business_id bigint,
    "position" text,
    salary integer,
    slots integer DEFAULT 1,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    description text
);

CREATE SEQUENCE public.business_jobs_job_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.business_jobs_job_id_seq OWNED BY public.business_jobs.job_id;

CREATE TABLE public.business_stats (
    business_id bigint NOT NULL,
    total_revenue bigint DEFAULT 0,
    total_expenses bigint DEFAULT 0
);

CREATE TABLE public.businesses (
    business_id integer NOT NULL,
    owner_id bigint,
    name text,
    balance bigint DEFAULT 0,
    employee_limit integer DEFAULT 5,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    description text
);

CREATE SEQUENCE public.businesses_business_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.businesses_business_id_seq OWNED BY public.businesses.business_id;

CREATE TABLE public.card_daily (
    user_id bigint NOT NULL,
    last_claim timestamp without time zone
);

CREATE TABLE public.card_drop_channels (
    channel_id bigint NOT NULL,
    guild_id bigint,
    added_by bigint,
    added_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.card_duels (
    duel_id integer NOT NULL,
    player1_id bigint,
    player2_id bigint,
    winner_id bigint,
    reward integer,
    played_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.card_duels_duel_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.card_duels_duel_id_seq OWNED BY public.card_duels.duel_id;

CREATE TABLE public.card_market (
    listing_id integer NOT NULL,
    seller_id bigint,
    card_id text,
    price integer,
    listed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.card_market_listing_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.card_market_listing_id_seq OWNED BY public.card_market.listing_id;

CREATE TABLE public.card_packs (
    pack_id integer NOT NULL,
    name text NOT NULL,
    price integer NOT NULL,
    description text,
    rarity_weights jsonb
);

CREATE SEQUENCE public.card_packs_pack_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.card_packs_pack_id_seq OWNED BY public.card_packs.pack_id;

CREATE TABLE public.card_recipes (
    result_card_id integer,
    required_cards jsonb,
    cost integer
);

CREATE TABLE public.card_sets (
    set_id integer NOT NULL,
    name text NOT NULL,
    price integer NOT NULL,
    description text,
    rarity_weights jsonb
);

CREATE SEQUENCE public.card_sets_set_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.card_sets_set_id_seq OWNED BY public.card_sets.set_id;

CREATE TABLE public.cases (
    guild_id bigint,
    count integer
);

CREATE TABLE public.clownboard (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    self_clown boolean DEFAULT true NOT NULL,
    threshold integer DEFAULT 3 NOT NULL,
    emoji text DEFAULT '🤡'::text NOT NULL
);

CREATE TABLE public.clownboard_entry (
    guild_id bigint NOT NULL,
    clown_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    emoji text NOT NULL
);

CREATE TABLE public.confess (
    guild_id bigint,
    channel_id bigint,
    confession integer,
    upvote text DEFAULT '👍'::text,
    downvote text DEFAULT '👎'::text
);

CREATE TABLE public.confess_blacklist (
    guild_id bigint NOT NULL,
    word text NOT NULL
);

CREATE TABLE public.confess_members (
    guild_id bigint,
    user_id bigint,
    confession integer
);

CREATE TABLE public.confess_mute (
    guild_id bigint,
    user_id bigint
);

CREATE TABLE public.confess_replies (
    message_id bigint NOT NULL,
    user_id bigint NOT NULL,
    guild_id bigint NOT NULL
);

CREATE TABLE public.config (
    guild_id bigint NOT NULL,
    prefix text DEFAULT ','::text,
    baserole bigint,
    voicemaster jsonb DEFAULT '{}'::jsonb,
    mod_log bigint,
    invoke jsonb DEFAULT '{}'::jsonb,
    lock_ignore jsonb[] DEFAULT '{}'::jsonb[],
    reskin jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE public.contracts (
    business_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    salary integer,
    "position" text,
    can_hire boolean DEFAULT false,
    hired_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.counter (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    option text NOT NULL,
    last_update timestamp with time zone DEFAULT now() NOT NULL,
    rate_limited_until timestamp with time zone
);

CREATE TABLE public.crypto (
    user_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    transaction_id text NOT NULL,
    transaction_type text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.dalle_credits (
    user_id bigint NOT NULL,
    credits numeric(10,2) NOT NULL,
    last_reset timestamp without time zone NOT NULL
);

CREATE TABLE public.deck_cards (
    deck_id integer NOT NULL,
    card_id text NOT NULL,
    quantity integer DEFAULT 1
);

CREATE TABLE public.docket_channels (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL,
    thread_id bigint
);

CREATE TABLE public.docket_updates (
    id integer NOT NULL,
    docket_id integer,
    message_id bigint,
    content text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.docket_updates_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.docket_updates_id_seq OWNED BY public.docket_updates.id;

CREATE TABLE public.dockets (
    id integer NOT NULL,
    thread_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    title text,
    original_content text,
    gpt_summary text,
    image_urls text[],
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    status text DEFAULT 'open'::text,
    last_updated timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.dockets_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.dockets_id_seq OWNED BY public.dockets.id;

CREATE TABLE public.donators (
    user_id bigint
);

CREATE TABLE public.earnings (
    user_id bigint NOT NULL,
    h0 double precision DEFAULT 0,
    h1 double precision DEFAULT 0,
    h2 double precision DEFAULT 0,
    h3 double precision DEFAULT 0,
    h4 double precision DEFAULT 0,
    h5 double precision DEFAULT 0,
    h6 double precision DEFAULT 0,
    h7 double precision DEFAULT 0,
    h8 double precision DEFAULT 0,
    h9 double precision DEFAULT 0,
    h10 double precision DEFAULT 0,
    h11 double precision DEFAULT 0,
    h12 double precision DEFAULT 0,
    h13 double precision DEFAULT 0,
    h14 double precision DEFAULT 0,
    h15 double precision DEFAULT 0,
    h16 double precision DEFAULT 0,
    h17 double precision DEFAULT 0,
    h18 double precision DEFAULT 0,
    h19 double precision DEFAULT 0,
    h20 double precision DEFAULT 0,
    h21 double precision DEFAULT 0,
    h22 double precision DEFAULT 0,
    h23 double precision DEFAULT 0
);

CREATE TABLE public.economy (
    user_id bigint NOT NULL,
    wallet bigint DEFAULT 0,
    bank bigint DEFAULT 0,
    bank_capacity bigint DEFAULT 10000,
    gems integer DEFAULT 0,
    last_daily timestamp without time zone,
    daily_streak integer DEFAULT 0,
    last_interest timestamp without time zone
);

CREATE TABLE public.economy_access (
    user_id bigint NOT NULL,
    granted_by bigint,
    granted_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.economy_roleshop (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    price bigint,
    description text
);

CREATE TABLE public.employee_stats (
    business_id bigint NOT NULL,
    employee_id bigint NOT NULL,
    work_count integer DEFAULT 0,
    total_earned bigint DEFAULT 0
);

CREATE TABLE public.fake_permissions (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    permission text NOT NULL
);

CREATE TABLE public.feedback (
    user_id bigint NOT NULL,
    message text NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.forcenick (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    nickname character varying(32)
);

CREATE TABLE public.gallery (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL
);

CREATE TABLE public.gambling_history (
    game_id integer NOT NULL,
    user_id bigint,
    game_type text,
    bet_amount bigint,
    outcome text,
    profit_loss bigint,
    played_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.gambling_history_game_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.gambling_history_game_id_seq OWNED BY public.gambling_history.game_id;

CREATE TABLE public.gift_logs (
    gift_id integer NOT NULL,
    sender_id bigint,
    receiver_id bigint,
    amount bigint,
    message text,
    sent_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.gift_logs_gift_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.gift_logs_gift_id_seq OWNED BY public.gift_logs.gift_id;

CREATE TABLE public.giveaway (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    prize text NOT NULL,
    emoji text NOT NULL,
    winners integer NOT NULL,
    ended boolean DEFAULT false NOT NULL,
    ends_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL,
    required_roles bigint[] DEFAULT '{}'::bigint[],
    bonus_roles jsonb DEFAULT '{}'::jsonb
);

CREATE TABLE public.giveaway_settings (
    guild_id bigint NOT NULL,
    bonus_roles jsonb DEFAULT '{}'::jsonb,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.gnames (
    guild_id bigint NOT NULL,
    name text NOT NULL,
    changed_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP NOT NULL
);

CREATE TABLE public.goodbye_message (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    template text NOT NULL,
    delete_after integer
);

CREATE TABLE public.guild_verification (
    guild_id bigint NOT NULL,
    level integer DEFAULT 1,
    kick_after integer,
    ratelimit integer,
    antialt boolean DEFAULT false,
    bypass_until timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    updated_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    verified_role_id bigint,
    manual_verification boolean DEFAULT false,
    log_channel_id bigint,
    platform character varying(10) DEFAULT 'web'::character varying,
    verification_settings jsonb DEFAULT '{}'::jsonb,
    verification_channel_id bigint,
    prevent_vpn boolean DEFAULT false
);

CREATE TABLE public.guildblacklist (
    guild_id bigint NOT NULL,
    information text
);

CREATE TABLE public.hardban (
    user_id bigint,
    guild_id bigint
);

CREATE TABLE public.highlights (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    word text NOT NULL
);

CREATE TABLE public.immune (
    guild_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    role_id bigint,
    type character varying(10) NOT NULL
);

CREATE TABLE public.incidents (
    id text NOT NULL,
    title text NOT NULL,
    start_time bigint NOT NULL,
    end_time bigint,
    status text NOT NULL,
    severity text NOT NULL,
    affected_services text[] NOT NULL,
    updates jsonb DEFAULT '[]'::jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    affected_shards text[]
);

CREATE TABLE public.instances (
    id integer NOT NULL,
    user_id bigint NOT NULL,
    payment_id character varying(100) NOT NULL,
    amount numeric(10,2) NOT NULL,
    purchased_at timestamp without time zone NOT NULL,
    expires_at timestamp without time zone NOT NULL,
    status character varying(20) DEFAULT 'pending'::character varying,
    email character varying(255),
    CONSTRAINT check_status CHECK (((status)::text = ANY (ARRAY[('pending'::character varying)::text, ('active'::character varying)::text, ('deployed'::character varying)::text, ('suspended'::character varying)::text])))
);

CREATE SEQUENCE public.instances_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.instances_id_seq OWNED BY public.instances.id;

CREATE TABLE public.inventory (
    user_id bigint NOT NULL,
    item text NOT NULL,
    amount integer NOT NULL
);

CREATE TABLE public.invite_config (
    guild_id bigint NOT NULL,
    is_enabled boolean DEFAULT false,
    log_channel_id bigint,
    fake_join_threshold numeric(10,2) DEFAULT 7,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    account_age_requirement integer,
    server_age_requirement integer
);

CREATE TABLE public.invite_rewards (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    required_invites integer NOT NULL,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.invite_tracking (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    inviter_id bigint,
    invite_code text,
    uses integer DEFAULT 0,
    bonus_uses integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    joined_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    left_at timestamp without time zone
);

CREATE TABLE public.jail (
    guild_id bigint,
    user_id bigint,
    roles text
);

CREATE TABLE public.jaill (
    guild_id bigint,
    channel_id bigint,
    jail_id bigint,
    role text,
    log_id bigint
);

CREATE TABLE public.job_applications (
    application_id integer NOT NULL,
    job_id integer,
    applicant_id bigint,
    status text DEFAULT 'pending'::text,
    reviewed_by bigint,
    reviewed_at timestamp without time zone,
    applied_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.job_applications_application_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.job_applications_application_id_seq OWNED BY public.job_applications.application_id;

CREATE TABLE public.jobs (
    user_id bigint NOT NULL,
    current_job text,
    job_level integer DEFAULT 1,
    job_experience integer DEFAULT 0,
    last_work timestamp without time zone,
    employer_id bigint
);

CREATE TABLE public.latency_history (
    "timestamp" bigint NOT NULL,
    average_latency double precision NOT NULL
);

CREATE TABLE public.logging (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    events integer NOT NULL
);

CREATE TABLE public.logging_history (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint,
    event_type character varying(50) NOT NULL,
    content jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.logging_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.logging_history_id_seq OWNED BY public.logging_history.id;

CREATE TABLE public.lottery_history (
    id integer NOT NULL,
    user_id bigint,
    pot_amount bigint,
    total_tickets bigint,
    winner_tickets bigint,
    won_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.lottery_history_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.lottery_history_id_seq OWNED BY public.lottery_history.id;

CREATE TABLE public.lovense_config (
    guild_id bigint NOT NULL,
    is_enabled boolean DEFAULT false,
    log_channel_id bigint,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.lovense_connections (
    token text NOT NULL,
    guild_id bigint,
    user_id bigint,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP,
    completed_at timestamp without time zone,
    device_id text,
    expires_at timestamp without time zone DEFAULT (CURRENT_TIMESTAMP + '00:10:00'::interval)
);

CREATE TABLE public.lovense_consent (
    user_id bigint NOT NULL,
    agreed boolean,
    agreed_at timestamp without time zone,
    locked boolean DEFAULT false
);

CREATE TABLE public.lovense_devices (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    device_id text,
    device_type text,
    access_token text,
    last_active timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.lovense_shares (
    guild_id bigint NOT NULL,
    owner_id bigint NOT NULL,
    target_id bigint NOT NULL,
    device_id text NOT NULL,
    shared_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.mod (
    guild_id bigint NOT NULL,
    channel_id bigint,
    jail_id bigint,
    role_id bigint,
    dm_enabled boolean DEFAULT true,
    dm_ban text,
    dm_kick text,
    dm_mute text,
    dm_unban text,
    dm_jail text,
    dm_unjail text,
    dm_unmute text,
    dm_warn text,
    dm_timeout text,
    dm_untimeout text,
    roles text,
    user_id bigint,
    dm_antinuke_ban boolean,
    dm_antinuke_kick boolean,
    dm_antinuke_strip boolean,
    dm_antiraid_ban boolean,
    dm_antiraid_kick boolean,
    dm_antiraid_timeout boolean,
    dm_antiraid_strip boolean,
    dm_role_add boolean,
    dm_role_remove boolean
);

CREATE TABLE public.name_history (
    user_id bigint NOT NULL,
    username text NOT NULL,
    is_nickname boolean DEFAULT false NOT NULL,
    is_hidden boolean DEFAULT false NOT NULL,
    changed_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.payment (
    guild_id bigint NOT NULL,
    customer_id bigint NOT NULL,
    method text NOT NULL,
    amount bigint NOT NULL,
    transfers integer DEFAULT 0 NOT NULL,
    paid_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.pet_adventures (
    adventure_id integer NOT NULL,
    pet_id integer,
    start_time timestamp without time zone NOT NULL,
    end_time timestamp without time zone NOT NULL,
    adventure_type character varying(32) NOT NULL,
    completed boolean DEFAULT false
);

CREATE SEQUENCE public.pet_adventures_adventure_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.pet_adventures_adventure_id_seq OWNED BY public.pet_adventures.adventure_id;

CREATE TABLE public.pet_items (
    item_id integer NOT NULL,
    owner_id bigint NOT NULL,
    item_name character varying(64) NOT NULL,
    amount integer DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.pet_items_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.pet_items_item_id_seq OWNED BY public.pet_items.item_id;

CREATE TABLE public.pet_trades (
    trade_id integer NOT NULL,
    pet1_id integer,
    pet2_id integer,
    user1_id bigint NOT NULL,
    user2_id bigint NOT NULL,
    trade_fee integer NOT NULL,
    trade_time timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.pet_trades_trade_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.pet_trades_trade_id_seq OWNED BY public.pet_trades.trade_id;

CREATE TABLE public.pets (
    pet_id integer NOT NULL,
    owner_id bigint NOT NULL,
    name character varying(32) NOT NULL,
    type character varying(32) NOT NULL,
    rarity character varying(16) NOT NULL,
    level integer DEFAULT 1,
    xp integer DEFAULT 0,
    health integer DEFAULT 100,
    happiness integer DEFAULT 100,
    hunger integer DEFAULT 100,
    active boolean DEFAULT false,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.pets_pet_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.pets_pet_id_seq OWNED BY public.pets.pet_id;

CREATE TABLE public.pingonjoin (
    channel_id bigint,
    guild_id bigint
);

CREATE TABLE public.poll_votes (
    vote_id uuid DEFAULT gen_random_uuid() NOT NULL,
    poll_id uuid,
    user_id bigint NOT NULL,
    choice_ids integer[] NOT NULL,
    voted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.polls (
    poll_id uuid DEFAULT gen_random_uuid() NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    creator_id bigint NOT NULL,
    title text NOT NULL,
    description text,
    choices jsonb NOT NULL,
    settings jsonb NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    ends_at timestamp with time zone,
    is_active boolean DEFAULT true
);

CREATE TABLE public.prefix (
    guild_id bigint,
    prefix text
);

CREATE TABLE public.publisher (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL
);

CREATE TABLE public.pubsub (
    id text NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    created_at timestamp with time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.quoter (
    guild_id bigint NOT NULL,
    channel_id bigint,
    emoji text,
    embeds boolean DEFAULT true NOT NULL
);

CREATE TABLE public.reaction_role (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    role_id bigint NOT NULL,
    emoji text NOT NULL
);

CREATE TABLE public.reaction_trigger (
    guild_id bigint NOT NULL,
    trigger public.citext NOT NULL,
    emoji text NOT NULL
);

CREATE TABLE public.recordings (
    id uuid NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    initiator_id bigint NOT NULL,
    started_at timestamp with time zone NOT NULL,
    ended_at timestamp with time zone,
    status text NOT NULL,
    file_path text
);

CREATE TABLE public.reminders (
    user_id bigint NOT NULL,
    reminder text NOT NULL,
    remind_at timestamp with time zone NOT NULL,
    invoked_at timestamp with time zone NOT NULL,
    message_url text
);

CREATE TABLE public.reports (
    id integer NOT NULL,
    reporter_id bigint NOT NULL,
    reporter_name text NOT NULL,
    reporter_email text NOT NULL,
    username_reported text NOT NULL,
    reason text NOT NULL,
    description text NOT NULL,
    created_at timestamp without time zone NOT NULL,
    reviewed boolean DEFAULT false NOT NULL,
    reviewed_at timestamp without time zone,
    reviewed_by bigint,
    action_taken text,
    notes text
);

CREATE SEQUENCE public.reports_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.reports_id_seq OWNED BY public.reports.id;

CREATE TABLE public.reskin_user (
    user_id bigint,
    toggled boolean,
    username text,
    avatar text
);

CREATE TABLE public.response_trigger (
    guild_id bigint NOT NULL,
    trigger public.citext NOT NULL,
    template text NOT NULL,
    strict boolean DEFAULT false NOT NULL,
    reply boolean DEFAULT false NOT NULL,
    delete boolean DEFAULT false NOT NULL,
    delete_after integer DEFAULT 0 NOT NULL,
    role_id bigint,
    sticker_id bigint
);

CREATE TABLE public.role_shops (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    price integer,
    description text,
    active boolean DEFAULT true
);

CREATE TABLE public.roleplay (
    user_id bigint NOT NULL,
    target_id bigint NOT NULL,
    category text NOT NULL,
    amount integer DEFAULT 1 NOT NULL
);

CREATE TABLE public.selfprefix (
    user_id bigint,
    prefix text
);

CREATE TABLE public.settings (
    guild_id bigint NOT NULL,
    prefixes text[] DEFAULT '{}'::text[] NOT NULL,
    reskin boolean DEFAULT false NOT NULL,
    reposter_prefix boolean DEFAULT true NOT NULL,
    reposter_delete boolean DEFAULT false NOT NULL,
    reposter_embed boolean DEFAULT true NOT NULL,
    transcription boolean DEFAULT false NOT NULL,
    welcome_removal boolean DEFAULT false NOT NULL,
    booster_role_base_id bigint,
    booster_role_include_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    lock_role_id bigint,
    lock_ignore_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    log_ignore_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    reassign_ignore_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    reassign_roles boolean DEFAULT false NOT NULL,
    invoke_kick text,
    invoke_ban text,
    invoke_unban text,
    invoke_timeout text,
    invoke_untimeout text,
    invoke_play text,
    play_panel boolean DEFAULT true NOT NULL,
    play_deletion boolean DEFAULT false NOT NULL,
    safesearch_level text DEFAULT 'strict'::text NOT NULL,
    author text
);

CREATE TABLE public.shop_items (
    item_id integer NOT NULL,
    name text,
    price integer,
    description text,
    effect_type text,
    effect_value double precision,
    duration integer,
    effect_description text,
    effect_example jsonb,
    stock integer DEFAULT '-1'::integer,
    max_quantity integer DEFAULT '-1'::integer,
    tradeable boolean DEFAULT true
);

CREATE SEQUENCE public.shop_items_item_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.shop_items_item_id_seq OWNED BY public.shop_items.item_id;

CREATE TABLE public.shutup (
    guild_id bigint,
    user_id bigint
);

CREATE TABLE public.social_links (
    user_id bigint NOT NULL,
    type character varying(32) NOT NULL,
    url text NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.socials (
    user_id bigint NOT NULL,
    bio text,
    background_url text,
    show_friends boolean DEFAULT true,
    show_activity boolean DEFAULT true,
    profile_color text DEFAULT 'linear'::text,
    glass_effect boolean DEFAULT false,
    discord_guild text,
    profile_image text,
    last_avatar text,
    last_background text,
    badges text[],
    audio_url text,
    audio_title text,
    click_text text DEFAULT 'Click to enter...'::text,
    click_enabled boolean DEFAULT false,
    linear_color text DEFAULT '#ffffff'::text,
    text_underline_color_type text DEFAULT 'linear'::text,
    text_underline_linear_color text,
    text_underline_gradient_name text,
    bold_text_color_type text DEFAULT 'linear'::text,
    bold_text_linear_color text,
    bold_text_gradient_name text,
    status_color_type text DEFAULT 'linear'::text,
    status_linear_color text,
    status_gradient_name text,
    bio_color_type text DEFAULT 'linear'::text,
    bio_linear_color text,
    bio_gradient_name text,
    social_icons_color_type text DEFAULT 'linear'::text,
    social_icons_linear_color text,
    social_icons_gradient_name text,
    domains jsonb DEFAULT '[]'::jsonb,
    verified_domains jsonb DEFAULT '[]'::jsonb
);

CREATE TABLE public.socials_details (
    detail_id integer NOT NULL,
    user_id bigint NOT NULL,
    friends bigint NOT NULL,
    url text
);

CREATE SEQUENCE public.socials_details_detail_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.socials_details_detail_id_seq OWNED BY public.socials_details.detail_id;

CREATE TABLE public.socials_gradients (
    user_id bigint NOT NULL,
    color text,
    "position" integer NOT NULL
);

CREATE TABLE public.socials_saved_colors (
    user_id bigint NOT NULL,
    name text NOT NULL,
    color text,
    type text
);

CREATE TABLE public.socials_saved_gradients (
    user_id bigint NOT NULL,
    name text NOT NULL,
    color text,
    "position" integer NOT NULL
);

CREATE TABLE public.starboard (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    self_star boolean DEFAULT true NOT NULL,
    threshold integer DEFAULT 3 NOT NULL,
    emoji text DEFAULT '⭐'::text NOT NULL,
    color integer
);

CREATE TABLE public.starboard_entry (
    guild_id bigint NOT NULL,
    star_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    emoji text NOT NULL
);

CREATE TABLE public.status_history (
    date date NOT NULL,
    incidents jsonb DEFAULT '[]'::jsonb,
    cpu_metrics jsonb DEFAULT '[]'::jsonb,
    memory_metrics jsonb DEFAULT '[]'::jsonb,
    latency_metrics jsonb DEFAULT '[]'::jsonb
);

CREATE TABLE public.status_metrics (
    "timestamp" bigint NOT NULL,
    cpu_usage double precision,
    memory_usage double precision
);

CREATE TABLE public.steal_disabled (
    guild_id bigint NOT NULL
);

CREATE TABLE public.sticky_message (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    template text NOT NULL
);

CREATE TABLE public.suggestion (
    channel_id bigint,
    guild_id bigint,
    author_id bigint,
    blacklisted_id bigint,
    suggestion_id integer,
    thread_enabled boolean DEFAULT false,
    anonymous_allowed boolean DEFAULT true,
    required_role_id bigint
);

CREATE TABLE public.suggestion_entries (
    guild_id bigint NOT NULL,
    message_id bigint NOT NULL,
    author_id bigint,
    suggestion_id integer,
    is_anonymous boolean DEFAULT false
);

CREATE TABLE public.suggestion_votes (
    guild_id bigint,
    message_id bigint NOT NULL,
    user_id bigint NOT NULL,
    vote_type integer
);

CREATE TABLE public.tag_aliases (
    guild_id bigint NOT NULL,
    alias text NOT NULL,
    original text
);

CREATE TABLE public.tags (
    guild_id bigint NOT NULL,
    name text NOT NULL,
    owner_id bigint,
    template text,
    uses bigint DEFAULT 0,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.thread (
    guild_id bigint NOT NULL,
    thread_id bigint NOT NULL
);

CREATE TABLE public.timezones (
    user_id bigint NOT NULL,
    timezone text NOT NULL
);

CREATE TABLE public.tracker (
    guild_id bigint NOT NULL,
    vanity_channel_id bigint,
    username_channel_id bigint
);

CREATE TABLE public.transactions (
    id integer NOT NULL,
    user_id bigint,
    amount bigint,
    action character varying(4),
    "timestamp" timestamp without time zone DEFAULT now()
);

CREATE SEQUENCE public.transactions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.transactions_id_seq OWNED BY public.transactions.id;

CREATE TABLE public.used_items (
    user_id bigint NOT NULL,
    item text NOT NULL,
    ts timestamp without time zone NOT NULL,
    expiration timestamp without time zone NOT NULL
);

CREATE TABLE public.user_cards (
    user_id bigint NOT NULL,
    card_id text NOT NULL,
    quantity integer DEFAULT 1,
    obtained_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_decks (
    deck_id integer NOT NULL,
    user_id bigint,
    name text,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.user_decks_deck_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.user_decks_deck_id_seq OWNED BY public.user_decks.deck_id;

CREATE TABLE public.user_items (
    user_id bigint NOT NULL,
    item_id integer NOT NULL,
    quantity integer DEFAULT 0,
    expires_at timestamp without time zone,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_links (
    user_id bigint NOT NULL,
    type character varying(32) NOT NULL,
    url text NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.user_spotify (
    user_id bigint NOT NULL,
    access_token text,
    refresh_token text,
    token_expires_at timestamp without time zone,
    spotify_id text
);

CREATE TABLE public.user_transactions (
    transaction_id integer NOT NULL,
    user_id bigint,
    type text,
    amount bigint,
    details jsonb,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE public.user_transactions_transaction_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.user_transactions_transaction_id_seq OWNED BY public.user_transactions.transaction_id;

CREATE TABLE public.user_votes (
    user_id bigint NOT NULL,
    last_vote_time timestamp without time zone DEFAULT now() NOT NULL
);

CREATE TABLE public.uwulock (
    guild_id bigint,
    user_id bigint
);

CREATE TABLE public.vanity (
    guild_id bigint NOT NULL,
    channel_id bigint,
    role_id bigint,
    template text
);

CREATE TABLE public.vanity_sniper (
    guild_id bigint NOT NULL,
    status boolean DEFAULT true NOT NULL,
    channel_id bigint,
    vanities text[] DEFAULT '{}'::text[] NOT NULL
);

CREATE TABLE public.vape (
    user_id bigint NOT NULL,
    flavor text,
    hits bigint DEFAULT 0 NOT NULL
);

CREATE TABLE public.verification_attempts (
    user_id bigint,
    guild_id bigint,
    attempt_time timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    success boolean DEFAULT false,
    method smallint
);

CREATE TABLE public.verification_bypass_roles (
    guild_id bigint NOT NULL,
    role_id bigint NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.verification_email_codes (
    session_token text NOT NULL,
    code text NOT NULL,
    expires_at timestamp with time zone
);

CREATE TABLE public.verification_pending_reviews (
    id integer NOT NULL,
    session_token text NOT NULL,
    user_id bigint NOT NULL,
    guild_id bigint NOT NULL,
    answers jsonb NOT NULL,
    submitted_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    reviewed_at timestamp with time zone,
    reviewed_by bigint,
    approved boolean,
    review_notes text
);

CREATE SEQUENCE public.verification_pending_reviews_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.verification_pending_reviews_id_seq OWNED BY public.verification_pending_reviews.id;

CREATE TABLE public.verification_question_sessions (
    session_token text NOT NULL,
    question_ids integer[] NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    requires_review boolean DEFAULT false
);

CREATE TABLE public.verification_questions (
    id integer NOT NULL,
    guild_id bigint,
    question text NOT NULL,
    options jsonb,
    correct_answer text NOT NULL,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    is_text boolean DEFAULT false
);

CREATE SEQUENCE public.verification_questions_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE public.verification_questions_id_seq OWNED BY public.verification_questions.id;

CREATE TABLE public.verification_sessions (
    session_token text NOT NULL,
    user_id bigint,
    guild_id bigint,
    method smallint,
    expires_at timestamp with time zone,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE public.warn_actions (
    guild_id bigint NOT NULL,
    threshold integer NOT NULL,
    action text NOT NULL,
    duration integer
);

CREATE TABLE public.webhook (
    identifier text NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    author_id bigint NOT NULL,
    webhook_id bigint NOT NULL
);

CREATE TABLE public.welcome_message (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    template text NOT NULL,
    delete_after integer
);

CREATE TABLE public.whitelist (
    guild_id bigint NOT NULL,
    status boolean DEFAULT false NOT NULL,
    action text DEFAULT 'kick'::text NOT NULL
);

CREATE TABLE reposters.disabled (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    reposter text NOT NULL
);

CREATE TABLE reskin.config (
    user_id bigint NOT NULL,
    username text,
    avatar_url text
);

CREATE TABLE reskin.webhook (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    webhook_id bigint NOT NULL
);

CREATE TABLE snipe.filter (
    guild_id bigint NOT NULL,
    invites boolean DEFAULT false NOT NULL,
    links boolean DEFAULT false NOT NULL,
    words text[] DEFAULT '{}'::text[] NOT NULL
);

CREATE TABLE snipe.ignore (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE spam.config (
    guild_id bigint NOT NULL,
    enabled boolean DEFAULT false,
    threshold integer DEFAULT 3,
    timeout_duration integer DEFAULT 300
);

CREATE TABLE spam.exempt (
    guild_id bigint NOT NULL,
    entity_id bigint NOT NULL,
    type text
);

CREATE TABLE spam.messages (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    message_hash text NOT NULL,
    count integer DEFAULT 1
);

CREATE TABLE statistics.daily (
    guild_id bigint NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    member_id bigint NOT NULL,
    messages_sent integer DEFAULT 0,
    voice_minutes integer DEFAULT 0
);

CREATE TABLE statistics.daily_channels (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    date date DEFAULT CURRENT_DATE NOT NULL,
    messages_sent integer DEFAULT 0
);

CREATE TABLE stats.config (
    guild_id bigint NOT NULL,
    min_word_length integer DEFAULT 3,
    count_bots boolean DEFAULT false,
    channel_whitelist bigint[],
    channel_blacklist bigint[]
);

CREATE TABLE stats.custom_commands (
    guild_id bigint NOT NULL,
    command text NOT NULL,
    word text,
    created_by bigint,
    created_at timestamp without time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stats.ignored_words (
    guild_id bigint NOT NULL,
    word text NOT NULL,
    added_by bigint NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE stats.word_usage (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    word text NOT NULL,
    count integer DEFAULT 1,
    last_used timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE streaks.config (
    guild_id bigint NOT NULL,
    channel_id bigint,
    notification_channel_id bigint,
    streak_emoji text DEFAULT '🔥'::text,
    image_only boolean DEFAULT false
);

CREATE TABLE streaks.restore_log (
    id integer NOT NULL,
    guild_id bigint,
    user_id bigint,
    restored_by text,
    restored_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    previous_streak integer
);

CREATE SEQUENCE streaks.restore_log_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE streaks.restore_log_id_seq OWNED BY streaks.restore_log.id;

CREATE TABLE streaks.users (
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    current_streak integer DEFAULT 0,
    highest_streak integer DEFAULT 0,
    last_streak_time timestamp with time zone,
    restores_available integer DEFAULT 0,
    total_images_sent integer DEFAULT 0
);

CREATE TABLE ticket.button (
    identifier text NOT NULL,
    guild_id bigint NOT NULL,
    template text,
    category_id bigint,
    topic text
);

CREATE TABLE ticket.config (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    message_id bigint NOT NULL,
    staff_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    blacklisted_ids bigint[] DEFAULT '{}'::bigint[] NOT NULL,
    channel_name text,
    logging_channel bigint DEFAULT 0
);

CREATE TABLE ticket.logs (
    guild_id bigint,
    channel_id bigint
);

CREATE TABLE ticket.open (
    identifier text NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    user_id bigint NOT NULL
);

CREATE TABLE timer.message (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    template text NOT NULL,
    "interval" integer NOT NULL,
    next_trigger timestamp with time zone NOT NULL
);

CREATE TABLE timer.purge (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    "interval" integer NOT NULL,
    next_trigger timestamp with time zone NOT NULL,
    method text DEFAULT 'bulk'::text NOT NULL
);

CREATE TABLE track.username (
    username text NOT NULL,
    user_ids bigint[]
);

CREATE TABLE track.vanity (
    vanity text NOT NULL,
    user_ids bigint[]
);

CREATE TABLE transcribe.channels (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    added_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE TABLE transcribe.rate_limit (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    last_used timestamp with time zone DEFAULT CURRENT_TIMESTAMP,
    uses integer DEFAULT 1
);

CREATE TABLE verification.logs (
    id integer NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    session_id text NOT NULL,
    event_type text NOT NULL,
    details jsonb,
    created_at timestamp with time zone DEFAULT CURRENT_TIMESTAMP
);

CREATE SEQUENCE verification.logs_id_seq
    AS integer
    START WITH 1
    INCREMENT BY 1
    NO MINVALUE
    NO MAXVALUE
    CACHE 1;

ALTER SEQUENCE verification.logs_id_seq OWNED BY verification.logs.id;

CREATE TABLE verification.sessions (
    session_id text NOT NULL,
    guild_id bigint NOT NULL,
    user_id bigint NOT NULL,
    expires_at timestamp with time zone NOT NULL,
    completed boolean DEFAULT false,
    failed_attempts integer DEFAULT 0
);

CREATE TABLE verification.settings (
    guild_id bigint NOT NULL,
    enabled boolean DEFAULT false,
    level text DEFAULT 'base'::text,
    methods text[] DEFAULT '{}'::text[],
    timeout integer DEFAULT 1800,
    ip_limit boolean DEFAULT false,
    vpn_check boolean DEFAULT false,
    private_tab_check boolean DEFAULT false,
    log_channel_id bigint,
    verify_channel_id bigint,
    verify_role_id bigint,
    CONSTRAINT settings_level_check CHECK ((level = ANY (ARRAY['base'::text, 'medium'::text])))
);

CREATE TABLE voice.channels (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    owner_id bigint NOT NULL
);

CREATE TABLE voice.config (
    guild_id bigint NOT NULL,
    category_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    bitrate integer,
    name text,
    status text
);

CREATE TABLE voice.recordings (
    id uuid NOT NULL,
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    initiator_id bigint NOT NULL,
    started_at timestamp without time zone NOT NULL,
    ended_at timestamp without time zone,
    status text NOT NULL,
    file_path text
);

CREATE TABLE voicemaster.channels (
    guild_id bigint NOT NULL,
    channel_id bigint NOT NULL,
    owner_id bigint
);

CREATE TABLE voicemaster.configuration (
    guild_id bigint NOT NULL,
    category_id bigint,
    interface_id bigint,
    channel_id bigint,
    role_id bigint,
    region text,
    bitrate bigint,
    interface_emojis jsonb,
    interface_layout character varying(10) DEFAULT 'default'::character varying,
    interface_embed text
);

ALTER TABLE ONLY auto.media ALTER COLUMN id SET DEFAULT nextval('auto.media_id_seq'::regclass);

ALTER TABLE ONLY history.moderation ALTER COLUMN id SET DEFAULT nextval('history.moderation_id_seq'::regclass);

ALTER TABLE ONLY invoke_history.commands ALTER COLUMN id SET DEFAULT nextval('invoke_history.commands_id_seq'::regclass);

ALTER TABLE ONLY music.history ALTER COLUMN id SET DEFAULT nextval('music.history_id_seq'::regclass);

ALTER TABLE ONLY music.playlist_tracks ALTER COLUMN id SET DEFAULT nextval('music.playlist_tracks_id_seq'::regclass);

ALTER TABLE ONLY music.playlists ALTER COLUMN id SET DEFAULT nextval('music.playlists_id_seq'::regclass);

ALTER TABLE ONLY public.appeals ALTER COLUMN id SET DEFAULT nextval('public.appeals_id_seq'::regclass);

ALTER TABLE ONLY public.business_jobs ALTER COLUMN job_id SET DEFAULT nextval('public.business_jobs_job_id_seq'::regclass);

ALTER TABLE ONLY public.businesses ALTER COLUMN business_id SET DEFAULT nextval('public.businesses_business_id_seq'::regclass);

ALTER TABLE ONLY public.card_duels ALTER COLUMN duel_id SET DEFAULT nextval('public.card_duels_duel_id_seq'::regclass);

ALTER TABLE ONLY public.card_market ALTER COLUMN listing_id SET DEFAULT nextval('public.card_market_listing_id_seq'::regclass);

ALTER TABLE ONLY public.card_packs ALTER COLUMN pack_id SET DEFAULT nextval('public.card_packs_pack_id_seq'::regclass);

ALTER TABLE ONLY public.card_sets ALTER COLUMN set_id SET DEFAULT nextval('public.card_sets_set_id_seq'::regclass);

ALTER TABLE ONLY public.docket_updates ALTER COLUMN id SET DEFAULT nextval('public.docket_updates_id_seq'::regclass);

ALTER TABLE ONLY public.dockets ALTER COLUMN id SET DEFAULT nextval('public.dockets_id_seq'::regclass);

ALTER TABLE ONLY public.gambling_history ALTER COLUMN game_id SET DEFAULT nextval('public.gambling_history_game_id_seq'::regclass);

ALTER TABLE ONLY public.gift_logs ALTER COLUMN gift_id SET DEFAULT nextval('public.gift_logs_gift_id_seq'::regclass);

ALTER TABLE ONLY public.instances ALTER COLUMN id SET DEFAULT nextval('public.instances_id_seq'::regclass);

ALTER TABLE ONLY public.job_applications ALTER COLUMN application_id SET DEFAULT nextval('public.job_applications_application_id_seq'::regclass);

ALTER TABLE ONLY public.logging_history ALTER COLUMN id SET DEFAULT nextval('public.logging_history_id_seq'::regclass);

ALTER TABLE ONLY public.lottery_history ALTER COLUMN id SET DEFAULT nextval('public.lottery_history_id_seq'::regclass);

ALTER TABLE ONLY public.pet_adventures ALTER COLUMN adventure_id SET DEFAULT nextval('public.pet_adventures_adventure_id_seq'::regclass);

ALTER TABLE ONLY public.pet_items ALTER COLUMN item_id SET DEFAULT nextval('public.pet_items_item_id_seq'::regclass);

ALTER TABLE ONLY public.pet_trades ALTER COLUMN trade_id SET DEFAULT nextval('public.pet_trades_trade_id_seq'::regclass);

ALTER TABLE ONLY public.pets ALTER COLUMN pet_id SET DEFAULT nextval('public.pets_pet_id_seq'::regclass);

ALTER TABLE ONLY public.reports ALTER COLUMN id SET DEFAULT nextval('public.reports_id_seq'::regclass);

ALTER TABLE ONLY public.shop_items ALTER COLUMN item_id SET DEFAULT nextval('public.shop_items_item_id_seq'::regclass);

ALTER TABLE ONLY public.socials_details ALTER COLUMN detail_id SET DEFAULT nextval('public.socials_details_detail_id_seq'::regclass);

ALTER TABLE ONLY public.transactions ALTER COLUMN id SET DEFAULT nextval('public.transactions_id_seq'::regclass);

ALTER TABLE ONLY public.user_decks ALTER COLUMN deck_id SET DEFAULT nextval('public.user_decks_deck_id_seq'::regclass);

ALTER TABLE ONLY public.user_transactions ALTER COLUMN transaction_id SET DEFAULT nextval('public.user_transactions_transaction_id_seq'::regclass);

ALTER TABLE ONLY public.verification_pending_reviews ALTER COLUMN id SET DEFAULT nextval('public.verification_pending_reviews_id_seq'::regclass);

ALTER TABLE ONLY public.verification_questions ALTER COLUMN id SET DEFAULT nextval('public.verification_questions_id_seq'::regclass);

ALTER TABLE ONLY streaks.restore_log ALTER COLUMN id SET DEFAULT nextval('streaks.restore_log_id_seq'::regclass);

ALTER TABLE ONLY verification.logs ALTER COLUMN id SET DEFAULT nextval('verification.logs_id_seq'::regclass);

ALTER TABLE ONLY alerts.twitch
    ADD CONSTRAINT twitch_pkey PRIMARY KEY (guild_id, twitch_id);

ALTER TABLE ONLY audio.config
    ADD CONSTRAINT config_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY audio.playlist_tracks
    ADD CONSTRAINT playlist_tracks_pkey PRIMARY KEY (guild_id, user_id, playlist_url, track_uri);

ALTER TABLE ONLY audio.playlists
    ADD CONSTRAINT playlists_pkey PRIMARY KEY (guild_id, user_id, playlist_url);

ALTER TABLE ONLY audio.recently_played
    ADD CONSTRAINT recently_played_pkey PRIMARY KEY (guild_id, user_id, played_at);

ALTER TABLE ONLY audio.statistics
    ADD CONSTRAINT statistics_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY auto.media
    ADD CONSTRAINT media_pkey PRIMARY KEY (id);

ALTER TABLE ONLY auto.media
    ADD CONSTRAINT unique_media_config UNIQUE (guild_id, channel_id, type);

ALTER TABLE ONLY commands.disabled
    ADD CONSTRAINT disabled_pkey PRIMARY KEY (guild_id, channel_id, command);

ALTER TABLE ONLY commands.ignore
    ADD CONSTRAINT ignore_pkey PRIMARY KEY (guild_id, target_id);

ALTER TABLE ONLY commands.restricted
    ADD CONSTRAINT restricted_pkey PRIMARY KEY (guild_id, role_id, command);

ALTER TABLE ONLY counting.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY disboard.config
    ADD CONSTRAINT config_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY family.marriages
    ADD CONSTRAINT marriages_pkey PRIMARY KEY (user_id, partner_id);

ALTER TABLE ONLY family.members
    ADD CONSTRAINT members_pkey PRIMARY KEY (user_id, related_id);

ALTER TABLE ONLY family.profiles
    ADD CONSTRAINT profiles_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY feeds.instagram
    ADD CONSTRAINT instagram_pkey PRIMARY KEY (guild_id, instagram_id);

ALTER TABLE ONLY feeds.pinterest
    ADD CONSTRAINT pinterest_pkey PRIMARY KEY (guild_id, pinterest_id);

ALTER TABLE ONLY feeds.reddit
    ADD CONSTRAINT reddit_pkey PRIMARY KEY (guild_id, subreddit_name);

ALTER TABLE ONLY feeds.soundcloud
    ADD CONSTRAINT soundcloud_pkey PRIMARY KEY (guild_id, soundcloud_id);

ALTER TABLE ONLY feeds.tiktok
    ADD CONSTRAINT tiktok_pkey PRIMARY KEY (guild_id, tiktok_id);

ALTER TABLE ONLY feeds.twitter
    ADD CONSTRAINT twitter_pkey PRIMARY KEY (guild_id, twitter_id);

ALTER TABLE ONLY feeds.youtube
    ADD CONSTRAINT youtube_pkey PRIMARY KEY (guild_id, youtube_id);

ALTER TABLE ONLY fortnite."authorization"
    ADD CONSTRAINT authorization_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY fortnite.reminder
    ADD CONSTRAINT reminder_pkey PRIMARY KEY (user_id, item_id);

ALTER TABLE ONLY fortnite.rotation
    ADD CONSTRAINT rotation_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY fun.wyr_channels
    ADD CONSTRAINT wyr_channels_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY history.moderation
    ADD CONSTRAINT moderation_pkey PRIMARY KEY (id);

ALTER TABLE ONLY invoke_history.commands
    ADD CONSTRAINT commands_pkey PRIMARY KEY (id);

ALTER TABLE ONLY joindm.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY lastfm.albums
    ADD CONSTRAINT albums_pkey PRIMARY KEY (user_id, artist, album);

ALTER TABLE ONLY lastfm.artists
    ADD CONSTRAINT artists_pkey PRIMARY KEY (user_id, artist);

ALTER TABLE ONLY lastfm.config
    ADD CONSTRAINT config_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY lastfm.crown_updates
    ADD CONSTRAINT crown_updates_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY lastfm.crowns
    ADD CONSTRAINT crowns_pkey PRIMARY KEY (guild_id, artist);

ALTER TABLE ONLY lastfm.hidden
    ADD CONSTRAINT hidden_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY lastfm.tracks
    ADD CONSTRAINT tracks_pkey PRIMARY KEY (user_id, artist, track);

ALTER TABLE ONLY level.config
    ADD CONSTRAINT config_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY level.member
    ADD CONSTRAINT member_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY level.notification
    ADD CONSTRAINT notification_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY level.role
    ADD CONSTRAINT role_pkey PRIMARY KEY (guild_id, level);

ALTER TABLE ONLY level.role
    ADD CONSTRAINT role_role_id_key UNIQUE (role_id);

ALTER TABLE ONLY music.history
    ADD CONSTRAINT history_pkey PRIMARY KEY (id);

ALTER TABLE ONLY music.playlist_tracks
    ADD CONSTRAINT playlist_tracks_pkey PRIMARY KEY (id);

ALTER TABLE ONLY music.playlists
    ADD CONSTRAINT playlists_pkey PRIMARY KEY (id);

ALTER TABLE ONLY porn.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.access_tokens
    ADD CONSTRAINT access_tokens_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.afk
    ADD CONSTRAINT afk_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.aliases
    ADD CONSTRAINT aliases_pkey PRIMARY KEY (guild_id, name);

ALTER TABLE ONLY public.antinuke
    ADD CONSTRAINT antinuke_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY public.antiraid
    ADD CONSTRAINT antiraid_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.appeal_config
    ADD CONSTRAINT appeal_config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.appeal_templates
    ADD CONSTRAINT appeal_templates_pkey PRIMARY KEY (guild_id, name);

ALTER TABLE ONLY public.appeals
    ADD CONSTRAINT appeals_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.auto_role
    ADD CONSTRAINT auto_role_pkey PRIMARY KEY (guild_id, role_id, action);

ALTER TABLE ONLY public.avatar_current
    ADD CONSTRAINT avatar_current_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.avatar_history
    ADD CONSTRAINT avatar_history_pkey PRIMARY KEY (user_id, avatar_url);

ALTER TABLE ONLY public.avatar_history_settings
    ADD CONSTRAINT avatar_history_settings_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.backup
    ADD CONSTRAINT backup_pkey PRIMARY KEY (key, guild_id);

ALTER TABLE ONLY public.beta_dashboard
    ADD CONSTRAINT beta_dashboard_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.birthdays
    ADD CONSTRAINT birthdays_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.blacklist
    ADD CONSTRAINT blacklist_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.blunt
    ADD CONSTRAINT blunt_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.boost_history
    ADD CONSTRAINT boost_history_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY public.boost_message
    ADD CONSTRAINT boost_message_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.booster_role
    ADD CONSTRAINT booster_role_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY public.boosters_lost
    ADD CONSTRAINT boosters_lost_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY public.business_jobs
    ADD CONSTRAINT business_jobs_pkey PRIMARY KEY (job_id);

ALTER TABLE ONLY public.business_stats
    ADD CONSTRAINT business_stats_pkey PRIMARY KEY (business_id);

ALTER TABLE ONLY public.businesses
    ADD CONSTRAINT businesses_pkey PRIMARY KEY (business_id);

ALTER TABLE ONLY public.card_daily
    ADD CONSTRAINT card_daily_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.card_drop_channels
    ADD CONSTRAINT card_drop_channels_pkey PRIMARY KEY (channel_id);

ALTER TABLE ONLY public.card_duels
    ADD CONSTRAINT card_duels_pkey PRIMARY KEY (duel_id);

ALTER TABLE ONLY public.card_market
    ADD CONSTRAINT card_market_pkey PRIMARY KEY (listing_id);

ALTER TABLE ONLY public.card_packs
    ADD CONSTRAINT card_packs_pkey PRIMARY KEY (pack_id);

ALTER TABLE ONLY public.card_sets
    ADD CONSTRAINT card_sets_pkey PRIMARY KEY (set_id);

ALTER TABLE ONLY public.clownboard_entry
    ADD CONSTRAINT clownboard_entry_pkey PRIMARY KEY (guild_id, channel_id, message_id, emoji);

ALTER TABLE ONLY public.clownboard
    ADD CONSTRAINT clownboard_pkey PRIMARY KEY (guild_id, emoji);

ALTER TABLE ONLY public.confess_blacklist
    ADD CONSTRAINT confess_blacklist_pkey PRIMARY KEY (guild_id, word);

ALTER TABLE ONLY public.confess_replies
    ADD CONSTRAINT confess_replies_pkey PRIMARY KEY (message_id);

ALTER TABLE ONLY public.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.contracts
    ADD CONSTRAINT contracts_pkey PRIMARY KEY (business_id, employee_id);

ALTER TABLE ONLY public.counter
    ADD CONSTRAINT counter_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.crypto
    ADD CONSTRAINT crypto_pkey PRIMARY KEY (user_id, transaction_id);

ALTER TABLE ONLY public.dalle_credits
    ADD CONSTRAINT dalle_credits_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.deck_cards
    ADD CONSTRAINT deck_cards_pkey PRIMARY KEY (deck_id, card_id);

ALTER TABLE ONLY public.docket_channels
    ADD CONSTRAINT docket_channels_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.docket_updates
    ADD CONSTRAINT docket_updates_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.dockets
    ADD CONSTRAINT dockets_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.earnings
    ADD CONSTRAINT earnings_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.economy_access
    ADD CONSTRAINT economy_access_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.economy
    ADD CONSTRAINT economy_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.economy_roleshop
    ADD CONSTRAINT economy_roleshop_pkey PRIMARY KEY (guild_id, role_id);

ALTER TABLE ONLY public.employee_stats
    ADD CONSTRAINT employee_stats_pkey PRIMARY KEY (business_id, employee_id);

ALTER TABLE ONLY public.fake_permissions
    ADD CONSTRAINT fake_permissions_pkey PRIMARY KEY (guild_id, role_id, permission);

ALTER TABLE ONLY public.feedback
    ADD CONSTRAINT feedback_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.forcenick
    ADD CONSTRAINT forcenick_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY public.gallery
    ADD CONSTRAINT gallery_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.gambling_history
    ADD CONSTRAINT gambling_history_pkey PRIMARY KEY (game_id);

ALTER TABLE ONLY public.gift_logs
    ADD CONSTRAINT gift_logs_pkey PRIMARY KEY (gift_id);

ALTER TABLE ONLY public.giveaway_settings
    ADD CONSTRAINT giveaway_settings_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.gnames
    ADD CONSTRAINT gnames_pkey PRIMARY KEY (guild_id, name, changed_at);

ALTER TABLE ONLY public.goodbye_message
    ADD CONSTRAINT goodbye_message_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.guild_verification
    ADD CONSTRAINT guild_verification_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.guildblacklist
    ADD CONSTRAINT guildblacklist_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY public.highlights
    ADD CONSTRAINT highlights_pkey PRIMARY KEY (guild_id, user_id, word);

ALTER TABLE ONLY public.immune
    ADD CONSTRAINT immune_pkey PRIMARY KEY (guild_id, entity_id, type);

ALTER TABLE ONLY public.incidents
    ADD CONSTRAINT incidents_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.instances
    ADD CONSTRAINT instances_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.inventory
    ADD CONSTRAINT inventory_pkey PRIMARY KEY (user_id, item);

ALTER TABLE ONLY public.invite_config
    ADD CONSTRAINT invite_config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.invite_rewards
    ADD CONSTRAINT invite_rewards_pkey PRIMARY KEY (guild_id, role_id);

ALTER TABLE ONLY public.invite_tracking
    ADD CONSTRAINT invite_tracking_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY public.job_applications
    ADD CONSTRAINT job_applications_pkey PRIMARY KEY (application_id);

ALTER TABLE ONLY public.jobs
    ADD CONSTRAINT jobs_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.latency_history
    ADD CONSTRAINT latency_history_pkey PRIMARY KEY ("timestamp");

ALTER TABLE ONLY public.logging_history
    ADD CONSTRAINT logging_history_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.logging
    ADD CONSTRAINT logging_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.lottery_history
    ADD CONSTRAINT lottery_history_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.lovense_config
    ADD CONSTRAINT lovense_config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.lovense_connections
    ADD CONSTRAINT lovense_connections_pkey PRIMARY KEY (token);

ALTER TABLE ONLY public.lovense_consent
    ADD CONSTRAINT lovense_consent_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.lovense_devices
    ADD CONSTRAINT lovense_devices_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY public.lovense_shares
    ADD CONSTRAINT lovense_shares_pkey PRIMARY KEY (guild_id, owner_id, target_id, device_id);

ALTER TABLE ONLY public.payment
    ADD CONSTRAINT payment_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY public.pet_adventures
    ADD CONSTRAINT pet_adventures_pkey PRIMARY KEY (adventure_id);

ALTER TABLE ONLY public.pet_items
    ADD CONSTRAINT pet_items_pkey PRIMARY KEY (item_id);

ALTER TABLE ONLY public.pet_trades
    ADD CONSTRAINT pet_trades_pkey PRIMARY KEY (trade_id);

ALTER TABLE ONLY public.pets
    ADD CONSTRAINT pets_pkey PRIMARY KEY (pet_id);

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_pkey PRIMARY KEY (vote_id);

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_poll_id_user_id_key UNIQUE (poll_id, user_id);

ALTER TABLE ONLY public.polls
    ADD CONSTRAINT polls_pkey PRIMARY KEY (poll_id);

ALTER TABLE ONLY public.publisher
    ADD CONSTRAINT publisher_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.pubsub
    ADD CONSTRAINT pubsub_id_key UNIQUE (id);

ALTER TABLE ONLY public.quoter
    ADD CONSTRAINT quoter_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY public.reaction_role
    ADD CONSTRAINT reaction_role_pkey PRIMARY KEY (guild_id, message_id, emoji);

ALTER TABLE ONLY public.reaction_trigger
    ADD CONSTRAINT reaction_trigger_pkey PRIMARY KEY (guild_id, trigger, emoji);

ALTER TABLE ONLY public.recordings
    ADD CONSTRAINT recordings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.reports
    ADD CONSTRAINT reports_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.response_trigger
    ADD CONSTRAINT response_trigger_pkey PRIMARY KEY (guild_id, trigger);

ALTER TABLE ONLY public.role_shops
    ADD CONSTRAINT role_shops_pkey PRIMARY KEY (guild_id, role_id);

ALTER TABLE ONLY public.roleplay
    ADD CONSTRAINT roleplay_pkey PRIMARY KEY (user_id, target_id, category);

ALTER TABLE ONLY public.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.shop_items
    ADD CONSTRAINT shop_items_name_key UNIQUE (name);

ALTER TABLE ONLY public.shop_items
    ADD CONSTRAINT shop_items_pkey PRIMARY KEY (item_id);

ALTER TABLE ONLY public.social_links
    ADD CONSTRAINT social_links_unique UNIQUE (user_id, type);

ALTER TABLE ONLY public.socials_details
    ADD CONSTRAINT socials_details_pkey PRIMARY KEY (detail_id);

ALTER TABLE ONLY public.socials_details
    ADD CONSTRAINT socials_details_user_id_friends_key UNIQUE (user_id, friends);

ALTER TABLE ONLY public.socials_gradients
    ADD CONSTRAINT socials_gradients_pkey PRIMARY KEY (user_id, "position");

ALTER TABLE ONLY public.socials
    ADD CONSTRAINT socials_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.socials_saved_colors
    ADD CONSTRAINT socials_saved_colors_pkey PRIMARY KEY (user_id, name);

ALTER TABLE ONLY public.socials_saved_gradients
    ADD CONSTRAINT socials_saved_gradients_pkey PRIMARY KEY (user_id, name, "position");

ALTER TABLE ONLY public.starboard_entry
    ADD CONSTRAINT starboard_entry_pkey PRIMARY KEY (guild_id, channel_id, message_id, emoji);

ALTER TABLE ONLY public.starboard
    ADD CONSTRAINT starboard_pkey PRIMARY KEY (guild_id, emoji);

ALTER TABLE ONLY public.status_history
    ADD CONSTRAINT status_history_pkey PRIMARY KEY (date);

ALTER TABLE ONLY public.status_metrics
    ADD CONSTRAINT status_metrics_pkey PRIMARY KEY ("timestamp");

ALTER TABLE ONLY public.steal_disabled
    ADD CONSTRAINT steal_disabled_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.sticky_message
    ADD CONSTRAINT sticky_message_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.suggestion_entries
    ADD CONSTRAINT suggestion_entries_pkey PRIMARY KEY (guild_id, message_id);

ALTER TABLE ONLY public.suggestion_votes
    ADD CONSTRAINT suggestion_votes_pkey PRIMARY KEY (message_id, user_id);

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT tag_aliases_pkey PRIMARY KEY (guild_id, alias);

ALTER TABLE ONLY public.tags
    ADD CONSTRAINT tags_pkey PRIMARY KEY (guild_id, name);

ALTER TABLE ONLY public.thread
    ADD CONSTRAINT thread_pkey PRIMARY KEY (guild_id, thread_id);

ALTER TABLE ONLY public.timezones
    ADD CONSTRAINT timezones_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY public.tracker
    ADD CONSTRAINT tracker_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY public.transactions
    ADD CONSTRAINT transactions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.mod
    ADD CONSTRAINT unique_guild_user UNIQUE (guild_id, user_id);

ALTER TABLE ONLY public.used_items
    ADD CONSTRAINT used_items_pkey PRIMARY KEY (user_id, item);

ALTER TABLE ONLY public.user_cards
    ADD CONSTRAINT user_cards_pkey PRIMARY KEY (user_id, card_id);

ALTER TABLE ONLY public.user_decks
    ADD CONSTRAINT user_decks_pkey PRIMARY KEY (deck_id);

ALTER TABLE ONLY public.user_items
    ADD CONSTRAINT user_items_pkey PRIMARY KEY (user_id, item_id);

ALTER TABLE ONLY public.user_links
    ADD CONSTRAINT user_links_pkey PRIMARY KEY (user_id, type);

ALTER TABLE ONLY public.user_spotify
    ADD CONSTRAINT user_spotify_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.user_transactions
    ADD CONSTRAINT user_transactions_pkey PRIMARY KEY (transaction_id);

ALTER TABLE ONLY public.user_votes
    ADD CONSTRAINT user_votes_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.vanity
    ADD CONSTRAINT vanity_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY public.vanity_sniper
    ADD CONSTRAINT vanity_sniper_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY public.vape
    ADD CONSTRAINT vape_pkey PRIMARY KEY (user_id);

ALTER TABLE ONLY public.verification_bypass_roles
    ADD CONSTRAINT verification_bypass_roles_pkey PRIMARY KEY (guild_id, role_id);

ALTER TABLE ONLY public.verification_email_codes
    ADD CONSTRAINT verification_email_codes_pkey PRIMARY KEY (session_token);

ALTER TABLE ONLY public.verification_pending_reviews
    ADD CONSTRAINT verification_pending_reviews_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.verification_question_sessions
    ADD CONSTRAINT verification_question_sessions_pkey PRIMARY KEY (session_token);

ALTER TABLE ONLY public.verification_questions
    ADD CONSTRAINT verification_questions_pkey PRIMARY KEY (id);

ALTER TABLE ONLY public.verification_sessions
    ADD CONSTRAINT verification_sessions_pkey PRIMARY KEY (session_token);

ALTER TABLE ONLY public.warn_actions
    ADD CONSTRAINT warn_actions_pkey PRIMARY KEY (guild_id, threshold);

ALTER TABLE ONLY public.webhook
    ADD CONSTRAINT webhook_pkey PRIMARY KEY (channel_id, webhook_id);

ALTER TABLE ONLY public.welcome_message
    ADD CONSTRAINT welcome_message_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY public.whitelist
    ADD CONSTRAINT whitelist_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY reposters.disabled
    ADD CONSTRAINT disabled_pkey PRIMARY KEY (guild_id, channel_id, reposter);

ALTER TABLE ONLY reskin.config
    ADD CONSTRAINT config_user_id_key UNIQUE (user_id);

ALTER TABLE ONLY reskin.webhook
    ADD CONSTRAINT webhook_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY snipe.filter
    ADD CONSTRAINT filter_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY snipe.ignore
    ADD CONSTRAINT ignore_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY spam.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY spam.exempt
    ADD CONSTRAINT exempt_pkey PRIMARY KEY (guild_id, entity_id);

ALTER TABLE ONLY spam.messages
    ADD CONSTRAINT messages_pkey PRIMARY KEY (guild_id, user_id, message_hash);

ALTER TABLE ONLY statistics.daily_channels
    ADD CONSTRAINT daily_channels_pkey PRIMARY KEY (guild_id, channel_id, date);

ALTER TABLE ONLY statistics.daily
    ADD CONSTRAINT daily_pkey PRIMARY KEY (guild_id, date, member_id);

ALTER TABLE ONLY stats.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY stats.custom_commands
    ADD CONSTRAINT custom_commands_pkey PRIMARY KEY (guild_id, command);

ALTER TABLE ONLY stats.ignored_words
    ADD CONSTRAINT ignored_words_pkey PRIMARY KEY (guild_id, word);

ALTER TABLE ONLY stats.word_usage
    ADD CONSTRAINT word_usage_pkey PRIMARY KEY (guild_id, user_id, word);

ALTER TABLE ONLY streaks.config
    ADD CONSTRAINT config_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY streaks.restore_log
    ADD CONSTRAINT restore_log_pkey PRIMARY KEY (id);

ALTER TABLE ONLY streaks.users
    ADD CONSTRAINT users_pkey PRIMARY KEY (guild_id, user_id);

ALTER TABLE ONLY ticket.button
    ADD CONSTRAINT button_pkey PRIMARY KEY (identifier, guild_id);

ALTER TABLE ONLY ticket.config
    ADD CONSTRAINT config_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY ticket.open
    ADD CONSTRAINT open_pkey PRIMARY KEY (identifier, guild_id, user_id);

ALTER TABLE ONLY ticket.logs
    ADD CONSTRAINT unique_guild_id UNIQUE (guild_id);

ALTER TABLE ONLY timer.message
    ADD CONSTRAINT message_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY timer.purge
    ADD CONSTRAINT purge_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY track.username
    ADD CONSTRAINT username_pkey PRIMARY KEY (username);

ALTER TABLE ONLY track.vanity
    ADD CONSTRAINT vanity_pkey PRIMARY KEY (vanity);

ALTER TABLE ONLY transcribe.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY transcribe.rate_limit
    ADD CONSTRAINT rate_limit_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY verification.logs
    ADD CONSTRAINT logs_pkey PRIMARY KEY (id);

ALTER TABLE ONLY verification.sessions
    ADD CONSTRAINT sessions_pkey PRIMARY KEY (session_id);

ALTER TABLE ONLY verification.settings
    ADD CONSTRAINT settings_pkey PRIMARY KEY (guild_id);

ALTER TABLE ONLY voice.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY voice.config
    ADD CONSTRAINT config_guild_id_key UNIQUE (guild_id);

ALTER TABLE ONLY voice.recordings
    ADD CONSTRAINT recordings_pkey PRIMARY KEY (id);

ALTER TABLE ONLY voicemaster.channels
    ADD CONSTRAINT channels_pkey PRIMARY KEY (guild_id, channel_id);

ALTER TABLE ONLY voicemaster.configuration
    ADD CONSTRAINT configuration_pkey PRIMARY KEY (guild_id);

CREATE INDEX idx_invite_tracking_joined_at ON public.invite_tracking USING btree (guild_id, joined_at);

CREATE UNIQUE INDEX mod_pkey ON public.mod USING btree (guild_id, user_id);

CREATE INDEX user_votes_time_idx ON public.user_votes USING btree (last_vote_time);

CREATE INDEX custom_commands_lookup_idx ON stats.custom_commands USING btree (guild_id, command);

ALTER TABLE ONLY audio.playlist_tracks
    ADD CONSTRAINT playlist_tracks_guild_id_user_id_playlist_url_fkey FOREIGN KEY (guild_id, user_id, playlist_url) REFERENCES audio.playlists(guild_id, user_id, playlist_url) ON DELETE CASCADE;

ALTER TABLE ONLY lastfm.albums
    ADD CONSTRAINT albums_user_id_fkey FOREIGN KEY (user_id) REFERENCES lastfm.config(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY lastfm.artists
    ADD CONSTRAINT artists_user_id_fkey FOREIGN KEY (user_id) REFERENCES lastfm.config(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY lastfm.crowns
    ADD CONSTRAINT crowns_user_id_artist_fkey FOREIGN KEY (user_id, artist) REFERENCES lastfm.artists(user_id, artist) ON DELETE CASCADE;

ALTER TABLE ONLY lastfm.tracks
    ADD CONSTRAINT tracks_user_id_fkey FOREIGN KEY (user_id) REFERENCES lastfm.config(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY level.config
    ADD CONSTRAINT config_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES public.settings(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY level.member
    ADD CONSTRAINT member_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES level.config(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY level.notification
    ADD CONSTRAINT notification_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES level.config(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY level.role
    ADD CONSTRAINT role_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES level.config(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY music.playlist_tracks
    ADD CONSTRAINT playlist_tracks_playlist_id_fkey FOREIGN KEY (playlist_id) REFERENCES music.playlists(id) ON DELETE CASCADE;

ALTER TABLE ONLY public.business_stats
    ADD CONSTRAINT business_stats_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id);

ALTER TABLE ONLY public.clownboard_entry
    ADD CONSTRAINT clownboard_entry_guild_id_emoji_fkey FOREIGN KEY (guild_id, emoji) REFERENCES public.clownboard(guild_id, emoji) ON DELETE CASCADE;

ALTER TABLE ONLY public.deck_cards
    ADD CONSTRAINT deck_cards_deck_id_fkey FOREIGN KEY (deck_id) REFERENCES public.user_decks(deck_id);

ALTER TABLE ONLY public.docket_updates
    ADD CONSTRAINT docket_updates_docket_id_fkey FOREIGN KEY (docket_id) REFERENCES public.dockets(id);

ALTER TABLE ONLY public.employee_stats
    ADD CONSTRAINT employee_stats_business_id_fkey FOREIGN KEY (business_id) REFERENCES public.businesses(business_id);

ALTER TABLE ONLY public.pet_adventures
    ADD CONSTRAINT pet_adventures_pet_id_fkey FOREIGN KEY (pet_id) REFERENCES public.pets(pet_id);

ALTER TABLE ONLY public.pet_trades
    ADD CONSTRAINT pet_trades_pet1_id_fkey FOREIGN KEY (pet1_id) REFERENCES public.pets(pet_id);

ALTER TABLE ONLY public.pet_trades
    ADD CONSTRAINT pet_trades_pet2_id_fkey FOREIGN KEY (pet2_id) REFERENCES public.pets(pet_id);

ALTER TABLE ONLY public.poll_votes
    ADD CONSTRAINT poll_votes_poll_id_fkey FOREIGN KEY (poll_id) REFERENCES public.polls(poll_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.socials_details
    ADD CONSTRAINT socials_details_user_id_fkey FOREIGN KEY (user_id) REFERENCES public.socials(user_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.starboard_entry
    ADD CONSTRAINT starboard_entry_guild_id_emoji_fkey FOREIGN KEY (guild_id, emoji) REFERENCES public.starboard(guild_id, emoji) ON DELETE CASCADE;

ALTER TABLE ONLY public.tag_aliases
    ADD CONSTRAINT tag_aliases_guild_id_original_fkey FOREIGN KEY (guild_id, original) REFERENCES public.tags(guild_id, name) ON DELETE CASCADE;

ALTER TABLE ONLY public.verification_attempts
    ADD CONSTRAINT verification_attempts_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES public.guild_verification(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.verification_bypass_roles
    ADD CONSTRAINT verification_bypass_roles_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES public.guild_verification(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.verification_email_codes
    ADD CONSTRAINT verification_email_codes_session_token_fkey FOREIGN KEY (session_token) REFERENCES public.verification_sessions(session_token) ON DELETE CASCADE;

ALTER TABLE ONLY public.verification_questions
    ADD CONSTRAINT verification_questions_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES public.guild_verification(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY public.verification_sessions
    ADD CONSTRAINT verification_sessions_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES public.guild_verification(guild_id) ON DELETE CASCADE;

ALTER TABLE ONLY ticket.button
    ADD CONSTRAINT button_guild_id_fkey FOREIGN KEY (guild_id) REFERENCES ticket.config(guild_id) ON DELETE CASCADE;