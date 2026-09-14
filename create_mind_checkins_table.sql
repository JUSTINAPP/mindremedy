-- Post-session mood check-ins for Mind Remedy. session_id is nullable so a
-- check-in can still be saved even if the session-start insert failed
-- (network blip) — the app already handles that case client-side. See
-- create_mind_sessions_table.sql for the sibling table and CLAUDE.md
-- "Backend — Supabase" for the shared-project rationale.
--
-- Run this whole file in Supabase Dashboard -> SQL Editor, on the
-- agzwefnisrlijbpqjjat project — after create_mind_sessions_table.sql,
-- since this table references it.

create table if not exists mind_checkins (
  id                  uuid primary key default gen_random_uuid(),
  user_id             text not null,
  session_id          uuid references mind_sessions(id) on delete set null,
  mood                text not null,
  distraction_level   text,
  note                text,
  created_at          timestamptz not null default now()
);

alter table mind_checkins enable row level security;

drop policy if exists "Users can only access their own mind checkins" on mind_checkins;
create policy "Users can only access their own mind checkins" on mind_checkins
  for all using (lower(auth.uid()::text) = lower(user_id))
  with check (lower(auth.uid()::text) = lower(user_id));

-- Verify afterward:
select tablename, policyname, cmd, qual from pg_policies where tablename = 'mind_checkins';
