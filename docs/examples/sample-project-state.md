# Project State — Taskflow

_Last updated: 2026-03-20 | Session: bright-stallman — Slack notification integration_

---

## Current Status

- **Phase:** Phase 2 — Core Product (5 of 7 tasks done)
- **Build:** Passing — `npx tsc --noEmit` clean, `npm run build` passes
- **Branch:** main (session `claude/bright-stallman` merged and pushed)
- **Blockers:** None active — TASK-2.6 unblocked TASK-2.5 and TASK-2.7
- **Next session should start with:** Implement the guest read-only view (TASK-2.5). Schema and auth are done; this is pure UI work. Guest sees only tasks where `assignee_id = guest.user_id` and `visibility != 'internal'`.

---

## What Was Just Done (2026-03-20 — Session: bright-stallman)

### TASK-2.6: Slack Notification Integration

**New files:**
- `lib/notifications/slack.ts` — `sendSlackDM()` utility, accepts encrypted bot token, decrypts and sends via Slack Web API
- `lib/inngest/functions/notify-task-assigned.ts` — Inngest function that fires on `task/assigned` event, fetches task/assignee/workspace data, sends DM

**Modified:**
- `lib/inngest/events.ts` — added `TaskAssignedEvent` type to `AppEvents` union
- `lib/inngest/functions/index.ts` — registered `notifyTaskAssigned` in the exports array
- `app/api/tasks/[taskId]/assign/route.ts` — added `inngest.send()` call after `logTaskEvent()`, fire-and-forget

**Commits:**
- `a3f891c` — feat: add TaskAssignedEvent type and Inngest function for Slack DM
- `b72d4e1` — feat: wire assignment route to fire task/assigned Inngest event
- `c94a02f` — fix: add retry config and onFailure handler to notify-task-assigned

**Decisions made:**
- Notification is best-effort — Slack failure must never fail the assignment API response. Implemented via fire-and-forget `inngest.send()` with retry config and silent onFailure logging.
- `sendSlackDM` does not cache the decrypted token. Decrypt-per-call is simpler and the overhead is acceptable at this scale. Revisit if we add high-frequency notification types later.
- Used `step.run('fetch-data')` to batch the three DB queries — Inngest marks this step as complete after first run, so retries skip the DB fetches and go straight to the Slack call.

**Known issues / deferred work:**
- The Slack message text is hardcoded English with no i18n. Acceptable for MVP; noted for post-launch.
- No read receipt or "did the user see this?" tracking. Out of scope for this task.

---

## What's Next

1. **TASK-2.5** — Guest read-only view. Schema is done (guests exist in `users` table with `role: 'guest'`, magic link auth is working). Build a route at `/guest/tasks` that shows assigned tasks filtered by `assignee_id = session.userId` AND `visibility != 'internal'`. No actions, no comments, no project navigation — read only.
2. **TASK-2.7** — Email digest. Inngest scheduled function, daily at 8am workspace timezone. Aggregate open tasks per user, send via Resend. Template already exists in `emails/DigestEmail.tsx`.
3. **TASK-3.1** — Mobile responsive pass. After TASK-2.5 and 2.7, Phase 2 is complete. Start Phase 3 with mobile.
4. **TASK-3.4** — Billing (Stripe) — needs to be scoped before starting. Is this Stripe Checkout (simple) or a full billing portal? Decision needed before writing the task prompt.

---

## Open Questions

- [ ] TASK-3.4 (billing): Stripe Checkout redirect, or embedded Stripe Elements with a full billing settings page? This affects scope significantly. Sean needs to decide before I write the task prompt.

---

## Environment Notes

- `INNGEST_SIGNING_KEY` and `INNGEST_EVENT_KEY` added to `.env.local` during this session — worktree copies need updating if new worktrees are started.
- Inngest dev server confirmed working locally. The `notify-task-assigned` function appears in the dev UI dashboard.

---

## Previous Sessions

### 2026-03-18 — Session: agitated-wiles

Completed TASK-2.4 (task detail modal). Users can now view, edit, assign, and comment on tasks from a slide-over modal. Assignment calls `logTaskEvent()` correctly. The modal is a client component; data fetches via SWR with optimistic updates for the status toggle.

- Built: task detail slide-over modal (`components/tasks/TaskDetailModal.tsx`)
- Built: comment thread within modal (`components/tasks/TaskComments.tsx`)
- Fixed: assignment was not calling `logTaskEvent()` — caught during verification, fixed before merge
- Decided: SWR for modal data rather than server component — the modal can be opened from multiple contexts (list, notification, direct link) and needs to refresh without full page reload
- Deferred: "mark all comments as read" — post-launch, not blocking

---

### 2026-03-15 — Session: condescending-newton

Completed TASK-2.2 (project list) and unblocked TASK-2.3. Project list renders correctly with empty state. Create project flow works end-to-end including slug generation.

- Built: `app/projects/page.tsx` (project list), `app/projects/new/page.tsx` (create flow)
- Built: `lib/projects/create.ts` (slug generation utility — strips special chars, ensures uniqueness with DB check)
- Fixed: slug uniqueness check was not case-insensitive — "Taskflow" and "taskflow" would collide. Added `LOWER()` to the uniqueness query.
- Decided: slugs are immutable after creation. Changing a slug would break all existing URLs. Added a note to the settings UI design (TBD) that slug cannot be edited.

---

### 2026-03-12 — Session: reverent-torvalds

Completed Phase 1. All foundation tasks done. Schema migrations applied, Google OAuth working, magic link system working, core task CRUD API routes complete, `logTaskEvent()` utility complete and verified.

- Built: 5 database migrations (users, workspaces, projects, tasks, task_events, sessions, guest_sessions tables)
- Built: Google OAuth flow with session cookie issuance
- Built: Magic link generation, delivery (via Resend), and validation with timing-safe comparison
- Built: `POST/GET/PATCH/DELETE /api/tasks` routes with `requireAuth()` guard
- Built: `lib/audit/logTaskEvent.ts` utility
- Decided: Guest sessions use a separate `guest_sessions` table rather than the main `sessions` table. Cleaner RLS — guest policies reference `guest_sessions.token` not `sessions.user_id`.
