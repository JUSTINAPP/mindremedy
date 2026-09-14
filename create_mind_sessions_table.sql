-- Mind Remedy's own session-log table, in the same shared Supabase project
-- as WikiRemedy/Remedy Reminder (agzwefnisrlijbpqjjat) but prefixed mind_
-- so it's unambiguous alongside Remedy Reminder's own tables. See
-- CLAUDE.md "Backend — Supabase" for why this project is shared rather
-- than split, and Remedy Reminder's CLAUDE.md for the account-deletion
-- source-of-truth pattern this follows.
--
-- RLS uses the lower(auth.uid()::text) = lower(user_id) pattern
-- established in Remedy Reminder (see its fix_rls_case_insensitive.sql)
-- from day one, rather than repeating the mistake that left lab_results
-- wide open for months.
--
-- Run this whole file in Supabase Dashboard -> SQL Editor, on the
-- agzwefnisrlijbpqjjat project.

create table if not exists mind_sessions (
  id                uuid primary key default gen_random_uuid(),
  user_id           text not null,
  technique_id      text not null,
  duration_minutes  integer not null,
  ambient_sound     text not null,
  bell_enabled      boolean not null default true,
  started_at        timestamptz not null default now(),
  completed_at      timestamptz,
  created_at        timestamptz not null default now()
);

alter table mind_sessions enable row level security;

drop policy if exists "Users can only access their own mind sessions" on mind_sessions;
create policy "Users can only access their own mind sessions" on mind_sessions
  for all using (lower(auth.uid()::text) = lower(user_id))
  with check (lower(auth.uid()::text) = lower(user_id));

-- Verify afterward:
select tablename, policyname, cmd, qual from pg_policies where tablename = 'mind_sessions';
