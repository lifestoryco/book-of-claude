# RUN TASK

**Input:** `$ARGUMENTS` (Task ID, e.g., `TASK-1.3`)

---

## Step 1 — Parse the task ID

Extract the task ID from `$ARGUMENTS`. Normalize format: `TASK-1.3` → file pattern `TASK-1-3_*`.

If no task ID provided, print: `Usage: /run-task TASK-X.Y` and stop.

---

## Step 2 — Find the prompt

Search `docs/tasks/pending/` for a file matching the pattern.

- **Found in pending/** → proceed to Step 3
- **Found in complete/** → print `⚠️ TASK-X.Y already completed. Re-run?` → stop
- **Not found** → print `❌ No prompt exists for TASK-X.Y. Run /prompt-builder TASK-X.Y first.` → stop

---

## Step 3 — Load and execute

Read the prompt file in full. It contains a self-contained session prompt with step-by-step instructions.

Print:
```
═══════════════════════════════════════════════
  Running: TASK-X.Y — <title from frontmatter>
  Prompt:  docs/tasks/pending/<filename>
═══════════════════════════════════════════════
```

Then execute the prompt exactly as written — follow every step, respect every human gate, run every verification command.

---

## Rules
- Do NOT modify the prompt file itself
- Do NOT skip human gates in the prompt
- After task completes, run `/update-docs TASK-X.Y` to update flight plan and move prompt to complete/
