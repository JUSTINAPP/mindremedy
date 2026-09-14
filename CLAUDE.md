# Mind Remedy — CLAUDE.md

Part of the REMEDY family (WikiRemedy, Remedy Reminder, Mind Remedy). Built the same way Remedy Reminder is built — read that project's CLAUDE.md at ~/Desktop/RemedyReminder/CLAUDE.md for general conventions, workflow, and hard-won gotchas that apply here too.

## Ways of working (same as Remedy Reminder)

- All builds, installs, and git operations run via Claude Code inside the VS Code terminal using xcodebuild. Xcode itself is used only for project configuration and archiving, not for building/running.
- Physical test device: Jonas's iPhone 16 Pro Max, UDID 00008140-001970981162801C. Every code change should end with a rebuild-and-install to this device.
- Bundle ID: com.dorja.mindremedy. The App Store Connect app record already exists (SKU mindremedy001), no App Store work is needed yet.

## Scope for this build — core loop only

Build exactly these five screens, matching design-reference/*.dc.html (also viewable live at https://claude.ai/code/artifact/da5fc5ab-98f7-4659-8ba3-ea55506aa02d):

1. Home — mood check-in pills, "Continue" card for the last practice, "Explore a practice" entry point, minimal Home/Practice/Explore/Progress nav row (nav destinations beyond Home can be stubs for now).
2. Technique detail (one example: Breath Awareness) — overview, evidence-by-outcome section, "how it's practised," Start Practice button.
3. Configure — duration picker, ambient sound picker, start/end bell toggle, big duration display, START button.
4. Active session — full-screen, chrome hidden by default, tap to reveal pause/end controls, breathing animation.
5. Post-session check-in — mood pills, distraction-level pills, optional note, Done button.

Explicitly OUT of scope for this build: the full technique library/Explore grid, the Mind Map, Progress analytics, onboarding flow, and any behaviour-change programmes (social media, alcohol, nicotine, etc.). Don't build ahead of this list even where it would be easy to — the whole point of this pass is a small, testable pilot, not the full product vision.

## Auth & signup — updated 2026-09-14, this supersedes the original Backend plan below

Testing the build surfaced a real problem: tapping "Sign Up" was redirecting into the Remedy Reminder app/account instead of creating a Mind Remedy identity — a direct consequence of the original shared-auth plan below. Rather than debug that coupling, the decision now is to remove sign-up from this pilot entirely:

- No sign-up or sign-in screen anywhere in the core loop. Nothing in Home → Technique → Configure → Active → Check-in should require an account or touch Supabase.
- Store mood check-ins, session history, and settings locally on-device (SwiftData, or UserDefaults+Codable if the data shape is simple enough) — no backend call needed to use the app at all.
- Add exactly one stubbed "Premium" entry point (e.g. a locked row in Profile/Settings) whose only job right now is to be the sole place that would eventually trigger sign-up. Don't build actual premium features yet — this is just reserving the pattern per Jonas's direction: remove the forced signup, put signup behind premium instead.
- If/when that premium sign-up flow is actually built later, it must be an explicit, clearly-labeled step (e.g. "Sign in with your REMEDY account") rather than an implicit shared session with Remedy Reminder — that implicit sharing is what caused today's redirect bug.
- This also fits the pilot's actual goal (see the "Why these decisions were made" section below): the point of this build is to test whether the core loop itself is engaging, on Jonas's own device, without any account-creation friction confounding that read.

## Backend — original plan (superseded above, kept for later reference)

Original decision: Mind Remedy shares Remedy Reminder's existing Supabase project (same URL/publishable key already hardcoded in ~/Desktop/RemedyReminder/Services/SupabaseService.swift), not a separate project.

- New tables would be prefixed `mind_` (e.g. `mind_sessions`, `mind_techniques`, `mind_checkins`) so they're unambiguous alongside Remedy Reminder's existing 9 tables (user_reminders, reminder_logs, user_health_data, vaccinations, family_history, lab_results, screenings, cycle_logs, health_followups) in the same database.
- Each new table would need its own RLS policy scoped to `auth.uid()`, following the pattern already used on Remedy Reminder's tables.
- Account deletion: Mind Remedy's own "Delete Account" must, by default, delete ONLY Mind Remedy's own tables (the `mind_*` ones) — do NOT reuse or extend Remedy Reminder's `deleteAllUserData` to also wipe Remedy Reminder's tables from within Mind Remedy. The two apps' account-deletion flows stay independent by default. A separate, explicitly distinct "delete my entire REMEDY account across all apps" action can exist later as its own deliberate, harder-to-trigger flow — it is NOT what the normal in-app delete button does.

This plan (and the shared Supabase project itself) isn't abandoned long-term, just deferred past this pilot — revisit once the premium entry point above is actually being built out.

## Visual identity

Extends Remedy Reminder's own "Midnight" theme, spec'd in ~/Desktop/RemedyReminder/THEME_PICKER_BRIEF.md but never built there: background #12201e, card #1c2e2b, border #2c3f3c, mint accent #4fd1a5, dark color scheme, -apple-system font. Worth building this as a proper `AppTheme` token system from the start (the brief in Remedy Reminder describes the shape) rather than hardcoding hex values throughout, since Remedy Reminder itself never got that refactor and it shows (237 `Color(hex:)` call sites across 33 files there).

## Evidence content

Any evidence tiers/percentages shown on technique pages (see design-reference/Technique.dc.html for the pattern) must be visibly marked as illustrative / pending review — do not present them as validated research findings. Real evidence content comes later from an actual literature review, ideally feeding from WikiRemedy's evidence system rather than being written fresh here.

## Why these decisions were made

Full context (the ChatGPT strategy discussion, a separate earlier product/UI handover doc, competitive notes on Waking Up, and the reasoning behind the shared-Supabase, account-deletion, and no-signup-for-pilot calls above) is written up in the "WIKIREMEDY APP & WEB" Claude project, doc `claude/mind-remedy-strategy.md`. Worth reading if a future decision seems to cut against something here — it's probably already been reasoned through there.
