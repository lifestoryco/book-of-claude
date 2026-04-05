# The WBS System — A Step-by-Step Guide for Beginners

**By ksqueeze's friend who already made all the mistakes**

You're building something with Claude Code. It's going great until the project gets big enough that Claude starts losing track of what's done, what's next, and what decisions you already made three sessions ago. The WBS system fixes that.

WBS stands for Work Breakdown Structure. Fancy name, simple idea: **before you build anything, write down what you're going to build as a numbered list of tasks.** Then execute them one at a time.

---

## Why You Need This

Without a task list, here's what happens:

1. You tell Claude "build me a notification system"
2. Claude starts making decisions about the database, the UI, the email template, and the delivery logic — all at once
3. Some decisions are good, some are bad, and you don't find out which is which until everything is tangled together
4. Three sessions later, Claude doesn't remember what it decided or why

With a task list:

1. You break "notification system" into 4 tasks: database schema, send function, UI trigger, email template
2. Claude builds one thing at a time
3. You review each piece before moving on
4. Every session starts by reading the task list, so Claude always knows where things stand

That's it. That's the whole system.

---

## The Three Files You Need

The WBS system uses three types of files. Don't overthink this — just create them and fill them in as you go.

### File 1: The Flight Plan

This is your master task list. One file, one table per phase. Lives at `docs/flight-plan.md` in your project.

```markdown
# Flight Plan

**Updated:** 2026-04-04 | **Project:** My Cool App

---

## Status Legend

| Symbol | Meaning |
|--------|---------|
| 🔴 | TODO — haven't started |
| 🟡 | READY — instructions written, ready to go |
| 🔵 | IN PROGRESS — working on it right now |
| 🟠 | NEEDS VERIFICATION — built it, need to test |
| ✅ | DONE |
| 🔶 | BLOCKED — can't start until something else finishes |

---

## Phase 1 — Foundation

Get the basics working. Database, auth, core data model.

| ID | Task | Size | Status | Prompt |
|----|------|------|--------|--------|
| TASK-1.1 | Set up database tables | M | 🔴 TODO | — |
| TASK-1.2 | Build login flow | L | 🔴 TODO | — |
| TASK-1.3 | Create the main API routes | M | 🔴 TODO | — |

**Done when:** A user can sign up, log in, and create a record via the API.

---

## Phase 2 — Core Features

The main stuff your users will actually use.

| ID | Task | Size | Status | Prompt |
|----|------|------|--------|--------|
| TASK-2.1 | Dashboard page | M | 🔴 TODO | — |
| TASK-2.2 | Create/edit form | L | 🔴 TODO | — |
| TASK-2.3 | Search and filters | M | 🔴 TODO | — |

**Done when:** A user can log in, create stuff, find it, and edit it.

---

## Dependencies

- TASK-1.2 (login) must be done before any Phase 2 task
- TASK-2.2 depends on TASK-2.1 (need the dashboard before the form makes sense)
```

**Size guide:**
- **S** = less than 1 hour. One file, small change.
- **M** = 1-3 hours. A few files, one feature.
- **L** = 3-8 hours. Multiple files, maybe a migration.
- **XL** = too big. Break it into smaller tasks.

### File 2: Task Prompts

These are the detailed instructions for each task. They live in `docs/tasks/pending/` (before you do them) and get moved to `docs/tasks/complete/` after.

You don't need to write all of them up front. Write them as you're about to start a task. Here's the minimum viable task prompt:

```markdown
---
task: TASK-1.1
title: Set up database tables
phase: Phase 1 — Foundation
size: M
depends_on: []
created: 2026-04-04
---

# TASK-1.1: Set up database tables

## Context

We're starting from scratch. No tables exist yet. We need a `users` table
and a `projects` table. This task unblocks everything else.

**Current state:** Empty database
**Why now:** Nothing works without tables
**Constraints:** Use Supabase migrations, not raw SQL

---

## Goal

Database has `users` and `projects` tables with correct columns, types,
and a foreign key from projects to users.

---

## Steps

### Step 1 — Create the users table

Create a migration file that adds:
- `id` UUID primary key (default gen_random_uuid())
- `email` TEXT NOT NULL UNIQUE
- `name` TEXT NOT NULL
- `created_at` TIMESTAMPTZ DEFAULT NOW()

### Step 2 — Create the projects table

Create a migration file that adds:
- `id` UUID primary key
- `user_id` UUID FK → users(id)
- `title` TEXT NOT NULL
- `status` TEXT DEFAULT 'active'
- `created_at` TIMESTAMPTZ DEFAULT NOW()

---

**HUMAN GATE:** Stop here. Let me review the migration files before
you apply them. Tell me "proceed" when I confirm.

---

### Step 3 — Apply the migrations

Run the migrations. Verify both tables exist.

---

## Verification

npx tsc --noEmit    # no type errors
npm run build       # clean build

Check: both tables exist in the database with correct columns.

---

## Definition of Done

- [ ] users table created with correct columns
- [ ] projects table created with FK to users
- [ ] Migrations applied without errors
- [ ] tsc passes
- [ ] Build passes
```

**The key thing:** The Human Gate. This is where Claude stops and waits for you to check its work before continuing. Put these at natural checkpoints — after the database stuff but before the API stuff, for example. This is how you stay in control.

### File 3: Project State (Optional but Worth It)

This is the file that carries context between sessions. Lives at `docs/state/project-state.md`. When you end a session, you (or Claude) update it with what was done and what's next. When you start a new session, Claude reads it first.

```markdown
# Project State

_Last updated: 2026-04-04 | Session: my-first-session_

## What Was Just Done

### TASK-1.1: Set up database tables
- Created users and projects tables
- Both migrations applied cleanly

## What's Next

1. TASK-1.2 — Build login flow (next up)
2. TASK-1.3 — Create API routes (after login works)
3. TASK-2.1 — Dashboard page (after Phase 1 complete)
```

---

## The Four Commands

Once your files are set up, you use four slash commands to manage everything:

### `/wbs` — "Where are we?"

Shows your flight plan as a status board. Run this at the start of every session.

```
You type:  /wbs

Claude shows:
═══════════════════════════════════════
  Flight Plan Status
═══════════════════════════════════════

Phase 1 — Foundation
  TASK-1.1  Set up database tables     ✅ DONE
  TASK-1.2  Build login flow           🔵 IN PROGRESS
  TASK-1.3  Create API routes          🔴 TODO

Phase 2 — Core Features
  TASK-2.1  Dashboard page             🔴 TODO
  TASK-2.2  Create/edit form           🔶 BLOCKED (needs TASK-2.1)

Done: 1 | In Progress: 1 | Remaining: 3
```

That's it. One glance, you know exactly where things stand.

### `/next` — "What should I work on?"

Claude looks at your flight plan, checks which tasks have their dependencies met, and recommends what to do next.

```
You type:  /next

Claude shows:
═══════════════════════════════════════
  Next Up
═══════════════════════════════════════

  1. TASK-1.2  Build login flow    🔵 IN PROGRESS  L
     → /run-task TASK-1.2

  Blocked: TASK-2.1 (needs TASK-1.3 first)
```

You can ignore the recommendation and pick a different task. It's a suggestion, not an order.

### `/run-task TASK-1.2` — "Do this task"

This is the big one. Claude reads the task prompt file and executes it step by step. It follows the instructions exactly, stops at Human Gates, and runs the verification at the end.

```
You type:  /run-task TASK-1.2

Claude shows:
═══════════════════════════════════════
  Running: TASK-1.2 — Build login flow
  Prompt: docs/tasks/pending/TASK-1-2_login-flow.md
═══════════════════════════════════════

[Claude starts working through the steps...]

[Reaches a Human Gate...]

HUMAN GATE: I've created the login page and the API route.
Before I wire up the session cookies, confirm:
- [ ] The login form looks right
- [ ] The API route returns the correct response

Tell me "proceed" or flag any issues.
```

You review, say "proceed" (or tell Claude to change something), and it continues.

### `/update-docs TASK-1.2` — "Mark it done"

After a task is complete, this updates your flight plan and project state file.

```
You type:  /update-docs TASK-1.2

Claude:
- Changes TASK-1.2 status from 🔵 to ✅ in the flight plan
- Moves the prompt file from pending/ to complete/
- Updates project-state.md with what was built
```

---

## A Full Session, Start to Finish

Here's what a real work session looks like:

```
1. /start-session
   → Claude creates a worktree, loads your project state

2. /wbs
   → You see the status board, confirm where you left off

3. /next
   → Claude recommends TASK-1.3 (API routes)

4. /run-task TASK-1.3
   → Claude works through the steps
   → Stops at Human Gates for your review
   → You say "proceed" or redirect
   → Task reaches the end, verification passes

5. /update-docs TASK-1.3
   → Flight plan updated, state doc updated

6. /end-session
   → Claude commits everything, pushes to main
```

That's the loop. Every session. Start, check status, pick a task, execute it, update docs, end. Rinse and repeat until your project is done.

---

## Writing Good Tasks (The Part That Actually Matters)

The WBS system is only as good as your task prompts. Here's how to not suck at writing them:

### Bad task prompt:
> "Build the notification system"

Claude has no idea what you mean. How do notifications work? Email? Push? In-app? What triggers them? Where's the data stored? Claude will make up answers to all these questions, and some of them will be wrong.

### Good task prompt:
> **Step 1:** Create a `notifications` table with columns: id, user_id, type, message, read_at, created_at.
>
> **Step 2:** Create `lib/notifications/send.ts` with a function `sendNotification(userId, type, message)` that inserts a row.
>
> **HUMAN GATE:** Let me see the table and function before you build the UI.
>
> **Step 3:** Add a notification bell icon to the header that shows unread count.

See the difference? Each step names specific files. The Human Gate gives you a checkpoint. Claude knows exactly what to build.

### Rules of thumb:
- **Name specific files.** Not "create the API" but "create `app/api/notifications/route.ts`"
- **One feature per task.** If a task touches more than 5-6 files, split it.
- **Put Human Gates at decision points.** Before Claude builds UI on top of your database, let yourself review the database first.
- **Include verification commands.** "Run `npx tsc --noEmit` and `npm run build`" at the end of every task.
- **XL tasks are a smell.** If you estimate XL, break it into two M tasks instead.

---

## Setting Up From Scratch (The Quick Version)

If you're starting a brand new project and want to use the WBS system:

**Step 1:** Create the directories:
```bash
mkdir -p docs/tasks/pending docs/tasks/complete docs/state
```

**Step 2:** Create your flight plan:
```bash
# Copy the template from book-of-claude, or just create docs/flight-plan.md
# and write your phases + tasks (see the example above)
```

**Step 3:** Write your first task prompt:
```bash
# Create docs/tasks/pending/TASK-1-1_your-first-task.md
# Use the template above. Keep it simple.
```

**Step 4:** Copy the commands into your project:
```bash
cp book-of-claude/.claude/commands/wbs.md your-project/.claude/commands/
cp book-of-claude/.claude/commands/run-task.md your-project/.claude/commands/
cp book-of-claude/.claude/commands/next.md your-project/.claude/commands/
cp book-of-claude/.claude/commands/update-docs.md your-project/.claude/commands/
```

**Step 5:** Run `/wbs` in Claude Code to verify it reads your flight plan.

That's it. You're set up. Write task prompts as you go, not all at once.

---

## Common Mistakes

**"I wrote 30 tasks before starting."** Don't. Write your phases and task titles up front. Write the detailed task prompts only for the next 2-3 tasks you're about to do. Plans change. Writing 30 detailed prompts that you'll rewrite anyway is wasted effort.

**"I didn't put any Human Gates."** Now Claude made 8 decisions without asking you, and 2 of them are wrong, and they're baked into the next 3 steps. Human Gates are cheap. Use them.

**"My task is too vague."** If you can't picture the specific files Claude will create or modify, the task isn't specific enough. Break it down further.

**"I forgot to update the flight plan."** The status board is only useful if it's accurate. Update it at the end of every session. Takes 30 seconds.

**"I skipped the project state file."** Works fine for small projects. Falls apart when you have 10+ sessions. The next Claude instance has zero memory of what you did yesterday. The state file IS its memory.

---

## That's It

The WBS system is not complicated. It's three files and four commands:

- **Flight plan** = your task list with statuses
- **Task prompts** = detailed instructions for each task
- **Project state** = what happened last session + what's next

- `/wbs` = show the board
- `/next` = what should I do
- `/run-task` = do it
- `/update-docs` = mark it done

Start simple. Add complexity only when you feel the pain of not having it.
