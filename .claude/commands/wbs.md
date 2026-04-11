# WBS STATUS

> **Constraints — read-only command.**
> You MUST NOT call Edit, Write, or any Bash command that creates/modifies/deletes files.
> Display status only — do not update the flight plan.

Read `docs/flight-plan.md`. Output a compact status table:

```
═══════════════════════════════════════════════
  Flight Plan Status
═══════════════════════════════════════════════
```

For each phase, list every task:

```
Phase 1 — [Name]
  TASK-1.1  Task Title                    ✅ DONE
  TASK-1.2  Task Title                    🔴 TODO  → docs/tasks/pending/TASK-1-2_...md
  TASK-1.3  Task Title                    📋 POST
  TASK-1.4  Task Title                    🔵 FUTURE
```

Then print summary (total tasks, done, remaining per phase).

## Rules
- Show ALL phases, ALL tasks — nothing hidden
- For TODO tasks with a prompt file, show the path after →
- For DONE tasks, no path needed
- For POST/FUTURE tasks, just show the status
- Do NOT load or read any prompt files — paths only
- Keep output compact — no descriptions, just ID + title + status + path
