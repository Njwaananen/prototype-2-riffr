-- db/01_schema.sql
-- Riffr Prototype 2 schema based on Spec 2 data schema & ERD.

-- Enable UUID helper
create extension if not exists pgcrypto;

-- Clean-up so the script can be re-run safely
drop table if exists notifications cascade;
drop table if exists user_stats cascade;
drop table if exists saved_profiles cascade;
drop table if exists messages cascade;
drop table if exists matches cascade;
drop table if exists external_links cascade;
drop table if exists audio_media cascade;
drop table if exists user_skill cascade;
drop table if exists user_genre cascade;
drop table if exists user_role cascade;
drop table if exists skills cascade;
drop table if exists genres cascade;
drop table if exists roles cascade;
drop table if exists profiles cascade;
drop table if exists users cascade;

drop type if exists notification_type_enum;
drop type if exists match_status_enum;
drop type if exists visibility_enum;
drop type if exists audio_platform_enum;

-- Enums from Spec 2
create type visibility_enum as enum ('public', 'private');
create type audio_platform_enum as enum ('soundcloud', 'spotify', 'other');
create type match_status_enum as enum ('active', 'blocked', 'ended', 'saved');
create type notification_type_enum as enum ('new_match', 'new_message', 'new_genre_user');

-- USERS & PROFILE ---------------------------------------------------------

create table users (
  user_id uuid primary key default gen_random_uuid(),
  email text not null unique,
  username text not null unique,
  password_hash text not null,
  created_at timestamptz not null default now(),
  is_active boolean not null default true
);

create table profiles (
  profile_id uuid primary key default gen_random_uuid(),
  user_id uuid not null unique references users(user_id) on delete cascade,
  display_name text not null,
  bio text,
  location_text text,
  visibility visibility_enum not null default 'public'
);

-- CONTROLLED VOCAB: roles, genres, skills ---------------------------------

create table roles (
  role_id serial primary key,
  name text not null unique
);

create table genres (
  genre_id serial primary key,
  name text not null unique
);

create table skills (
  skill_id serial primary key,
  name text not null unique
);

-- JOIN TABLES: user_role, user_genre, user_skill --------------------------

create table user_role (
  user_role_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(user_id) on delete cascade,
  role_id integer not null references roles(role_id),
  created_at timestamptz not null default now(),
  constraint user_role_unique unique (user_id, role_id)
);

create table user_genre (
  user_genre_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(user_id) on delete cascade,
  genre_id integer not null references genres(genre_id),
  constraint user_genre_unique unique (user_id, genre_id)
);

create table user_skill (
  user_skill_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(user_id) on delete cascade,
  skill_id integer not null references skills(skill_id),
  constraint user_skill_unique unique (user_id, skill_id)
);

-- AUDIO & EXTERNAL LINKS --------------------------------------------------

create table audio_media (
  media_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(user_id) on delete cascade,
  file_url text not null,
  mime_type text not null,
  duration_seconds integer,
  uploaded_at timestamptz not null default now(),
  is_active boolean not null default true
);

create table external_links (
  link_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(user_id) on delete cascade,
  platform audio_platform_enum not null,
  url text not null,
  created_at timestamptz not null default now()
);

-- MATCHES & MESSAGES ------------------------------------------------------

create table matches (
  match_id uuid primary key default gen_random_uuid(),
  user_a_id uuid not null references users(user_id) on delete cascade,
  user_b_id uuid not null references users(user_id) on delete cascade,
  status match_status_enum not null default 'active',
  created_at timestamptz not null default now(),
  constraint matches_distinct_users check (user_a_id <> user_b_id),
  constraint matches_unique_pair unique (least(user_a_id, user_b_id), greatest(user_a_id, user_b_id))
);

create table messages (
  message_id uuid primary key default gen_random_uuid(),
  match_id uuid not null references matches(match_id) on delete cascade,
  sender_user_id uuid not null references users(user_id) on delete cascade,
  recipient_user_id uuid not null references users(user_id) on delete cascade,
  body_text text,
  attachment_url text,
  sent_at timestamptz not null default now(),
  deleted_for_sender boolean not null default false,
  deleted_for_recipient boolean not null default false
);

-- SAVED PROFILES ----------------------------------------------------------

create table saved_profiles (
  saved_profile_id uuid primary key default gen_random_uuid(),
  saver_user_id uuid not null references users(user_id) on delete cascade,
  saved_user_id uuid not null references users(user_id) on delete cascade,
  created_at timestamptz not null default now(),
  constraint saved_profiles_distinct_users check (saver_user_id <> saved_user_id),
  constraint saved_profiles_unique unique (saver_user_id, saved_user_id)
);

-- NOTIFICATIONS -----------------------------------------------------------

create table notifications (
  notification_id uuid primary key default gen_random_uuid(),
  user_id uuid not null references users(user_id) on delete cascade,
  notification_type notification_type_enum not null,
  payload jsonb,
  created_at timestamptz not null default now(),
  read_at timestamptz
);

-- USER STATS --------------------------------------------------------------

create table user_stats (
  user_id uuid primary key references users(user_id) on delete cascade,
  total_matches_bucket text,  -- e.g. '0', '1-9', '10+'
  last_active_at timestamptz
);
