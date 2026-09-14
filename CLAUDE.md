# Mind Remedy — CLAUDE.md

Part of the REMEDY family (WikiRemedy, Remedy Reminder, Mind Remedy). Built the same way Remedy Reminder is built — read that project's CLAUDE.md at ~/Desktop/RemedyReminder/CLAUDE.md for general conventions, workflow, and hard-won gotchas that apply here too.

## Ways of working (same as Remedy Reminder)

- All builds, installs, and git operations run via Claude Code inside the VS Code terminal using xcodebuild. Xcode itself is used only for project configuration and archiving, not for building/running.
- Physical test device: Jonas's iPhone 16 Pro Max, UDID 00008140-001970981162801C. Every code change should end with a rebuild-and-install to this device.
- Bundle ID: com.dorja.mindremedy. The App Store Connect app record already exists (SKU mindremedy001), no App Store work is needed yet.
- This repo is fresh: one Xcode "Hello World" template commit exists locally (git log shows "Initial Commit"), no remote configured yet, and the tracked xcuserdata file should be untracked now that .gitignore exists.

## First task, in order

1. `git rm -r --cached mindremedy.xcodeproj/xcuserdata` (now covered by .gitignore, shouldn't be tracked), then `git add -A && git commit -m "Add .gitignore, untrack xcuserdata"`.
2. `git remote add origin https://github.com/JUSTINAPP/mindremedy.git` and push main.
3. Reorganize the default Xcode template folder (currently flat: mindremedy/ContentView.swift, mindremedy/mindremedyApp.swift) into Remedy Reminder's structure: App/ (entry point, AppState, ContentView), Views/ (one subfolder per feature area), Models/, Services/, Extensions/ — do this through Xcode-aware tooling so the .pbxproj file references stay correct, not by moving files on disk directly.
4. Scaffold the core loop only (see Scope below), using design-reference/ as the visual and copy spec.

## Scope for this build — core loop only

Build exactly these five screens, matching design-reference/*.dc.html (also viewable live at https://claude.ai/code/artifact/da5fc5ab-98f7-4659-8ba3-ea55506aa02d):

1. Home — mood check-in pills, "Continue" card for the last practice, "Explore a practice" entry point, minimal Home/Practice/Explore/Progress nav row (nav destinations beyond Home can be stubs for now).
2. Technique detail (one example: Breath Awareness) — overview, evidence-by-outcome section, "how it's practised," Start Practice button.
3. Configure — duration picker, ambient sound picker, start/end bell toggle, big duration display, START button.
4. Active session — full-screen, chrome hidden by default, tap to reveal pause/end controls, breathing animation.
5. Post-session check-in — mood pills, distraction-level pills, optional note, Done button.

Explicitly OUT of scope for this build: the full technique library/Explore grid, the Mind Map, Progress analytics, onboarding flow, and any behaviour-change programmes (social media, alcohol, nicotine, etc.). Don't build ahead of this list even where it would be easy to — the whole point of this pass is a small, testable pilot, not the full product vision.

## Visual identity

Extends Remedy Reminder's own "Midnight" theme, spec'd in ~/Desktop/RemedyReminder/THEME_PICKER_BRIEF.md but never built there: background #12201e, card #1c2e2b, border #2c3f3c, mint accent #4fd1a5, dark color scheme, -apple-system font. Worth building this as a proper `AppTheme` token system from the start (the brief in Remedy Reminder describes the shape) rather than hardcoding hex values throughout, since Remedy Reminder itself never got that refactor and it shows (237 `Color(hex:)` call sites across 33 files there).

## Evidence content

Any evidence tiers/percentages shown on technique pages (see design-reference/Technique.dc.html for the pattern) must be visibly marked as illustrative / pending review — do not present them as validated research findings. Real evidence content comes later from an actual literature review, ideally feeding from WikiRemedy's evidence system rather than being written fresh here.

## Backend — Supabase

Decision: Mind Remedy shares Remedy Reminder's existing Supabase project (same URL/publishable key already hardcoded in ~/Desktop/RemedyReminder/Services/SupabaseService.swift — reuse those same two values in Mind Remedy's own SupabaseService.swift), not a separate project. This was a deliberate tradeoff (see below), not an oversight.

- New tables must be prefixed `mind_` (e.g. `mind_sessions`, `mind_techniques`, `mind_checkins`) so they're unambiguous alongside Remedy Reminder's existing 9 tables (user_reminders, reminder_logs, user_health_data, vaccinations, family_history, lab_results, screenings, cycle_logs, health_followups) in the same database.
- Each new table needs its own RLS policy scoped to `auth.uid()`, following the pattern already used on Remedy Reminder's tables.
- Account deletion: Mind Remedy's own "Delete Account" must, by default, delete ONLY Mind Remedy's own tables (the `mind_*` ones) — do NOT reuse or extend Remedy Reminder's `deleteAllUserData` to also wipe Remedy Reminder's tables from within Mind Remedy. The two apps' account-deletion flows stay independent by default. A separate, explicitly distinct "delete my entire REMEDY account across all apps" action can exist later as its own deliberate, harder-to-trigger flow — it is NOT what the normal in-app delete button does.
- Auth: reuse Remedy Reminder's Supabase Email/OTP auth pattern (see its AppState.swift) — a user can sign into Mind Remedy with the same credentials as Remedy Reminder if they have both, but a Mind Remedy pilot tester with no Remedy Reminder account can just sign up fresh through the same auth the normal way.

## Why these decisions were made

Full context (the ChatGPT strategy discussion, a separate earlier product/UI handover doc, competitive notes on Waking Up, and the reasoning behind the shared-Supabase and account-deletion calls above) is written up in the "WIKIREMEDY APP & WEB" Claude project, doc `claude/mind-remedy-strategy.md`. Worth reading if a future decision seems to cut against something here — it's probably already been reasoned through there.
