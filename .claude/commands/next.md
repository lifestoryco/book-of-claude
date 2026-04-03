# NEXT — What to Work On

**Two modes.** Default shows what to work on. `build` shows what needs prompts written.

**Input:** `$ARGUMENTS` — either empty (default) or `build`

---

## Mode 1 — Next Up (default)

Show the next 5 actionable tasks that have prompts ready in `docs/tasks/pending/`.

1. Read `docs/flight-plan.md`
2. Cross-reference with `docs/tasks/pending/` — list actual files
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

  Blocked: TASK-2.1 (needs TASK-1.3 first)
═══════════════════════════════════════════════
  Pending prompts: X | Done: Y | Remaining: Z
═══════════════════════════════════════════════
```

---

## Mode 2 — Build (`/next build`)

Show 5 tasks that need prompts written via `/prompt-builder`.

1. Read `docs/flight-plan.md`
2. Find tasks NOT done and without a prompt file
3. Priority: dependencies met first, smaller size first
4. Show top 5 with description and `/prompt-builder TASK-X.Y` command

---

## Rules
- Do NOT show all tasks — only the focused top 5
- Do NOT read prompt file contents — just check existence
- If `$ARGUMENTS` is anything other than `build` or empty: `Usage: /next or /next build`
