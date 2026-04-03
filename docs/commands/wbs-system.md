# WBS System: /wbs, /run-task, /next, /update-docs

Four commands that form a work management system. The flight plan tracks what needs to be done. Task prompts make individual tasks self-contained. The execution commands run and navigate them.

---

## The Problem They Solve

Without structured task management, large features decompose in real-time as Claude works. Claude starts implementing a feature, makes architectural decisions mid-stream, discovers the scope was larger than expected, and either delivers something incomplete or delivers something complete but inconsistent with prior decisions.

The WBS system moves decomposition before implementation. You (or Claude, following your direction) write out the tasks, their dependencies, their scope, and their acceptance criteria before any code is written. Then Claude executes tasks one at a time, with explicit human checkpoints.

---

## /wbs

**What it does:** Displays the current flight plan — a table of all tasks with status, size, and prompt availability.

**Usage:**

```
/wbs
/wbs phase-2
/wbs blocked
```

With no argument, shows all phases. With a phase name, filters to that phase. With `blocked`, shows only blocked tasks and their blockers.

**What the output looks like:**

```
Phase 2 — Core Product

TASK-2.1  Dashboard layout          M  ✅ DONE
TASK-2.2  Project list view         M  🟠 NEEDS VERIFICATION
TASK-2.3  Task list view            L  🔵 IN PROGRESS
TASK-2.4  Task detail modal         XL 🟡 READY  pending/TASK-2-4_...
TASK-2.5  Guest read-only view      M  🔴 TODO
TASK-2.6  Slack notifications       L  🔶 BLOCKED (needs TASK-2.4)

Summary: 1 done, 1 needs verification, 1 in progress, 1 ready, 1 todo, 1 blocked
```

**Keeping it current:** Update the flight plan file at the end of each session as part of the end-session ritual. Status should reflect actual reality, not aspirational state.

---

## /run-task

**What it does:** Executes a specific task using its task prompt file as the complete specification.

**Usage:**

```
/run-task TASK-2.4
```

Claude reads the task prompt for TASK-2.4, confirms the context and goal, and begins executing the steps. Human gates in the task prompt create stopping points where Claude waits for your confirmation before continuing.

**What makes this work:** The task prompt is self-contained. Claude doesn't need to remember prior sessions, read additional docs, or make inferences about scope. Everything it needs is in the prompt: context, steps, verification, DoD, rollback.

**Updating task status:** When you run `/run-task`, Claude should update the task's status in the flight plan to `IN PROGRESS`. When the DoD is met, it updates to `DONE` or `NEEDS VERIFICATION` depending on whether manual testing is required.

**If a task prompt doesn't exist yet:** Claude will tell you there's no prompt for that task and offer to write one. You can also use `/run-task TASK-2.5 --build-prompt` to have Claude write the prompt first, then present it for your review before executing.

---

## /next

**What it does:** Recommends what to work on next, given the current state of the flight plan.

**Usage:**

```
/next
```

Claude reads the flight plan, identifies tasks that are:
- `READY` (prompt exists, dependencies met)
- `TODO` with all dependencies done

And recommends one, with a brief rationale. If multiple tasks are ready, it considers: which is blocking the most downstream tasks? which is smallest? which aligns with what was just done?

**When to use it:** After completing a task and before starting the next one. The recommendation is a suggestion, not a command — you can override it. But having an explicit recommendation forces a moment of reflection rather than just grabbing the next thing on the list.

---

## /update-docs

**What it does:** Updates documentation files after a task completes. Typically run as part of the end-session ritual.

**Usage:**

```
/update-docs TASK-2.4
```

Claude reviews what was built in the task and updates:
- Flight plan status (mark task as DONE)
- `docs/state/project-state.md` (add to "What Was Just Done")
- Any relevant reference docs that the task changed (API docs, architecture notes, etc.)

This command is often combined with end-session: "run `/update-docs TASK-2.4` then `/end-session`."

---

## Setting Up a WBS From Scratch

For a new project:

**Step 1: Define phases.** What are the natural stages of your build? Typical structure: Foundation (infrastructure, auth, schema) → Core Product (main user-facing features) → Polish and Launch Prep. Three to four phases is usually right.

**Step 2: List tasks per phase.** For each phase, list every distinct unit of work. Be specific: "implement email notifications" is not a task; "create the Inngest function that sends a welcome email on user signup" is. Size each task (S/M/L/XL).

**Step 3: Map dependencies.** Which tasks must complete before others can start? Be explicit. Draw the dependency graph if it helps.

**Step 4: Write task prompts for the first 3-4 tasks.** You don't need prompts for everything up front. Write prompts for tasks you're about to execute, and for any tasks that have ambiguous scope that needs to be resolved before starting.

**Step 5: Create the flight plan file.** Use `templates/flight-plan.md.template` as the base. Fill in your phases and tasks.

---

## The Execution Cycle

A typical session using the WBS system:

```
/start-session
→ Claude reads project-state.md, sees TASK-2.3 is in progress

/wbs
→ Review current status, confirm what's next

/run-task TASK-2.3
→ Claude continues from where it left off
→ [Human gate reached]
→ Review output, say "proceed" or "stop here and do X differently"
→ [Task reaches DoD]

/run-task TASK-2.3 --verify
→ Claude runs verification commands, confirms all checks pass

/next
→ Claude recommends TASK-2.4 as next

/update-docs TASK-2.3
→ Flight plan updated, state doc updated

/end-session
→ Commits, rebases, pushes, final state doc update
```

---

## Task Prompt Quality

The quality of task prompt execution is entirely determined by the quality of the task prompt. Weak prompts produce weak execution.

Signs of a weak task prompt:
- Steps are described at the feature level ("implement the notification system") rather than the file level ("create `lib/notifications/send.ts` with a `sendNotification(userId, message)` function")
- No human gates — Claude makes all decisions without checkpoints
- Verification section says "check that it works" rather than specifying exact commands and expected output
- Definition of Done is a single checkbox

Signs of a strong task prompt:
- Each step names specific files to create or modify
- Human gates at natural decision points
- Verification section lists exact commands with expected output
- DoD has 5-8 specific, checkable items
- Rollback section explains how to undo if something goes wrong

See `docs/examples/sample-task-prompt.md` for a full example of a strong task prompt.
