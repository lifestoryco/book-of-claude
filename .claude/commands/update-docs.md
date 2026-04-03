# UPDATE DOCS — Update Flight Plan, Prompts & State

Use after finishing one or more tasks. Keeps all records in sync.

---

## Usage

Provide:
- **Task ID(s):** e.g., `TASK-1.3` or `TASK-1.1 TASK-1.2` (space-separated)
- **New status:** defaults to DONE if not specified
- **What was done:** free-form description

**Status pipeline:** 🔴 TODO → 🟡 READY → 🔵 IN PROGRESS → 🟠 NEEDS VERIFICATION → 🔶 BLOCKED → ✅ DONE

---

## Step 1 — Parse inputs

Extract task IDs, new status, and summary from the user's message.

## Step 2 — Update `docs/flight-plan.md`

For each task: find the row, update the status. If DONE, update the Prompt column from `pending/...` to `complete/...`.

## Step 3 — Move prompt files

For each task marked DONE: move from `docs/tasks/pending/` to `docs/tasks/complete/`.

## Step 4 — Update `docs/state/project-state.md`

If the file exists, prepend a new "What Was Just Done" entry with the task summary.

## Step 5 — Commit

```bash
git add docs/flight-plan.md docs/state/ docs/tasks/
git commit -m "docs: complete TASK-X.Y — <summary>"
```

## Step 6 — Report

```
═══════════════════════════════════════════════
  Task(s) Complete
═══════════════════════════════════════════════
  TASK-1.3 → ✅ DONE
    Prompt: moved to docs/tasks/complete/
  Flight plan updated ✅
  State updated ✅
═══════════════════════════════════════════════
```

## Rules
- NEVER hard-delete tasks from the flight plan — only change the status
- NEVER move prompts to complete/ unless status is DONE
- This command does NOT run end-session — wait for the user to do that
