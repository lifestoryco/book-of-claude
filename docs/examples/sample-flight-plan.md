# Taskflow — Flight Plan

**Updated:** 2026-03-20

---

## Status Legend

| Symbol | Status |
|--------|--------|
| 🔴 | TODO — not started |
| 🟡 | READY — prompt written, can execute |
| 🔵 | IN PROGRESS — currently being worked |
| 🟠 | NEEDS VERIFICATION — code exists, needs testing |
| 🔶 | BLOCKED — waiting on dependency or decision |
| ✅ | DONE |
| 📋 | POST-LAUNCH |

---

## Phase 1 — Foundation

Core infrastructure: database schema, auth, and a working create/read cycle. Nothing user-visible yet; just a solid base to build on.

| ID | Title | Size | Status | Prompt |
|----|-------|------|--------|--------|
| TASK-1.1 | Database schema — initial migrations | M | ✅ DONE | — |
| TASK-1.2 | Auth flow — Google OAuth + session cookies | L | ✅ DONE | — |
| TASK-1.3 | Guest magic link system | M | ✅ DONE | — |
| TASK-1.4 | Core API routes — tasks CRUD | M | ✅ DONE | — |
| TASK-1.5 | Audit log — `logTaskEvent()` utility | S | ✅ DONE | — |

**Phase 1 exit criteria:** A logged-in Admin can create a task via the API and see it returned. `logTaskEvent()` records the creation. Tests pass. Build passes.

---

## Phase 2 — Core Product

The main user-facing product: task management UI, project views, assignment, and notifications.

| ID | Title | Size | Status | Prompt |
|----|-------|------|--------|--------|
| TASK-2.1 | Dashboard layout and navigation shell | M | ✅ DONE | — |
| TASK-2.2 | Project list view + create project flow | M | 🟠 NEEDS VERIFICATION | — |
| TASK-2.3 | Task list view with status columns | L | 🔵 IN PROGRESS | `pending/TASK-2-3_task-list-view.md` |
| TASK-2.4 | Task detail modal — edit, assign, comment | XL | 🟡 READY | `pending/TASK-2-4_task-detail-modal.md` |
| TASK-2.5 | Guest read-only view — assigned tasks | M | 🔴 TODO | — |
| TASK-2.6 | Slack notification integration | L | 🔶 BLOCKED | Waiting on TASK-2.4 complete |
| TASK-2.7 | Email digest — daily summary | M | 🔴 TODO | — |

**Phase 2 exit criteria:** A Member can create a project, add tasks, assign them to a Guest. The Guest can log in via magic link and see their assigned tasks. Slack notifications fire on assignment.

---

## Phase 3 — Polish and Launch Prep

Performance, edge cases, accessibility, and launch gate.

| ID | Title | Size | Status | Prompt |
|----|-------|------|--------|--------|
| TASK-3.1 | Mobile responsive pass — all views | M | 🔴 TODO | — |
| TASK-3.2 | Empty states and error states | S | 🔴 TODO | — |
| TASK-3.3 | Onboarding flow — first-time Admin | M | 🔴 TODO | — |
| TASK-3.4 | Billing integration — Stripe checkout | L | 🔴 TODO | — |
| TASK-3.5 | Launch check — security, build, integrations | S | 🔴 TODO | — |
| TASK-3.6 | Admin analytics dashboard | L | 📋 POST-LAUNCH | — |
| TASK-3.7 | Task templates | M | 📋 POST-LAUNCH | — |

**Phase 3 exit criteria:** `/launch-check` passes. Stripe checkout working in test mode. Mobile layout usable on iPhone 14 and Pixel 7. No console errors in production build.

---

## Dependencies

- TASK-2.3 can begin while TASK-2.2 is in verification (independent UI areas)
- TASK-2.4 must be complete before TASK-2.6 (Slack notification fires from task assignment)
- TASK-2.5 depends on TASK-1.3 (guest auth, done) and TASK-2.4 (task detail, in progress)
- TASK-2.7 (email digest) depends on TASK-2.4 (task data model finalized)
- Phase 3 cannot begin until TASK-2.6 is complete (core product loop must be closed)
- TASK-3.4 (billing) depends on TASK-3.3 (onboarding, so billing is reachable)

---

## Summary

- **Total tasks:** 17
- **Done:** 6
- **In progress or ready:** 3
- **Remaining:** 5
- **Blocked:** 1
- **Post-launch deferred:** 2
- **Estimated remaining effort:** ~18-22 hours of Claude sessions
