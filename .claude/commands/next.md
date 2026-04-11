# NEXT — What to Work On

> **Preamble:** You are a prioritization engine. Show only what is actionable NOW — not the full backlog. Dependencies matter: a task with unmet dependencies is blocked, not ready. If the flight plan has stale statuses (tasks marked READY that are actually done), flag them rather than presenting stale data as truth.

> **Constraints — read-only command.**
> You MUST NOT call Edit, Write, or any Bash command that creates/modifies/deletes files.
> Display priorities only — do not update the flight plan or fix stale statuses.

**Two modes.** Default shows what to work on. `build` shows what needs prompts written.

**Input:** `$ARGUMENTS` — either empty (default) or `build`

---

## Mode 1 — Next Up (default)

Show the next 5 actionable tasks that have prompts ready in `docs/tasks/pending/`.

1. Read `docs/flight-plan.md`
2. Cross-reference with `docs/tasks/pending/` — list actual files present
3. Match each pending prompt to its task row in the flight plan
4. **Filter OUT:** tasks with status DONE, POST-LAUNCH, FUTURE
5. **Priority order:**
   - IN PROGRESS (resume first)
   - NEEDS VERIFICATION (close the loop)
   - READY / TODO with prompt in pending/
6. Apply dependency awareness: if TASK-2.1 depends on TASK-1.3 and 1.3 isn't done, demote 2.1
7. Show top 5:

```
═══════════════════════════════════════════════
  Next Up — 5 Tasks Ready to Run
═══════════════════════════════════════════════

  1. TASK-1.3  Unified Shell Architecture       🔴 TODO   L
     → /run-task TASK-1.3
     Prompt: docs/tasks/pending/TASK-1-3_...md

  2. TASK-2.1  Dashboard Redesign               🟡 READY  M
     → /run-task TASK-2.1
     Prompt: docs/tasks/pending/TASK-2-1_...md

  Blocked: TASK-2.4 (needs TASK-2.1 first)
═══════════════════════════════════════════════
  Pending prompts: X | Done: Y | Remaining: Z
═══════════════════════════════════════════════
```

---

## Mode 2 — Build (`/next build`)

Show 5 tasks that need prompts written via `/prompt-builder`.

1. Read `docs/flight-plan.md`
2. Find tasks NOT done and without a prompt file in pending/
3. Priority: tasks with met dependencies first, smaller size (S, M) before larger (L, XL)
4. For each task, include the 1-line description so the user can decide which to build
5. Show top 5:

```
═══════════════════════════════════════════════
  Prompt Builder Queue — 5 Tasks Need Prompts
═══════════════════════════════════════════════

  1. TASK-2.3  Notification System              🔴 TODO  M
     Add email + in-app notifications for key events
     → /prompt-builder TASK-2.3
     Deps: TASK-2.1 ✅

  2. TASK-3.1  Admin Dashboard                  🔴 TODO  L
     Read-only metrics view for account owners
     → /prompt-builder TASK-3.1
     Deps: none

═══════════════════════════════════════════════
  Tasks without prompts: X | With prompts: Y | Done: Z
═══════════════════════════════════════════════
```

---

## Rules
- Do NOT show all tasks — only the focused top 5
- Do NOT read prompt file contents — just check existence by filename
- Do NOT show post-launch or future tasks unless nothing else is left
- **Mode 1:** No task descriptions — just ID + title + status + size + action
- **Mode 2:** Include 1-line description so the user can prioritize which prompt to build
- If `$ARGUMENTS` is anything other than `build` or empty: `Usage: /next or /next build`
