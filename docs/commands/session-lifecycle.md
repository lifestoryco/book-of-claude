# Session Lifecycle: /start-session, /end-session, /sync

Three commands that form a system. They handle the beginning, end, and mid-session maintenance of the worktree-based development workflow.

---

## The Problem They Solve

Without session management, every Claude Code session starts from scratch. Claude reads CLAUDE.md, reads whatever files are in context, and makes its best guess at what happened before and what should happen next. For a project with any history, this produces inconsistency: decisions get re-made, conventions drift, work from prior sessions gets accidentally overwritten.

The session lifecycle commands solve this by:
1. Creating an isolated branch for each session's work (so main stays clean)
2. Loading accurate prior state at the start of each session
3. Capturing decisions and changes at the end of each session
4. Rebasing cleanly onto main when the session is done

---

## /start-session

**What it does:**

1. Generates a session name (or uses one you provide)
2. Creates a git worktree at `.claude/worktrees/[session-name]/` on a new branch `claude/[session-name]`
3. Copies `.env.local` from the project root into the worktree
4. Tells Claude to read `docs/state/project-state.md`
5. Runs a quick pre-flight check: is the build passing? Any merge conflicts? Any stale state?

**Usage:**

```
/start-session
/start-session my-feature-name
```

If you don't provide a name, the command generates one. The generated name format is two words — an adjective and a surname — which makes sessions easy to refer to in conversation ("the agitated-wiles session").

**What you see after:**

A brief orientation summary: what session this is, what the last session did, what the priority queue says to work on next. Claude's first message should orient you to the current state without requiring you to read the state doc yourself.

**Why isolation matters:**

Main stays on a known-good state throughout your session. If the session goes wrong — Claude takes a wrong direction, a migration fails, you decide to abandon the approach — you discard the worktree and nothing happened to main. This changes the psychology of experimentation. You can try things that might not work.

---

## /end-session

**What it does:**

1. Commits any uncommitted changes in the worktree with a summary commit message
2. Updates `docs/state/project-state.md`:
   - Moves the current "What Was Just Done" to the previous sessions section
   - Writes a new "What Was Just Done" for this session: files changed, commits made, decisions and their rationale
   - Updates "What's Next" based on what was completed
3. Rebases the session branch onto main
4. Fast-forward merges main to the session branch (keeps a linear history)
5. Pushes main
6. Removes the worktree

**Usage:**

```
/end-session
```

**The state doc update is the most important step.** Everything else is mechanical. The state doc update requires Claude to reflect on what happened in the session and write it in a form that will be useful to the next session's Claude instance. The quality of this update directly determines the quality of the next session's start.

**What a good end-session state doc entry looks like:**

- Files changed: specific paths and one-sentence description of what changed
- Decisions: what was decided AND why, including alternatives considered
- What's next: specific enough that the next session can start immediately without clarification
- Known issues: anything noticed but intentionally left for later

**What a bad one looks like:**

- "Updated some files" (not useful)
- "Fixed bugs" (which bugs? what was wrong?)
- "Work in progress" for what's next (gives the next session nothing to act on)

---

## /sync

**What it does:**

Rebases the current worktree branch onto the current state of main, without ending the session. Use this when:
- You're mid-session and main has changed (another session merged)
- You want to pull in a hotfix from main before continuing
- You want to ensure your session will merge cleanly before finishing

**Usage:**

```
/sync
```

**What happens:**

1. Fetches the latest main from origin
2. Runs `git rebase origin/main` on the current worktree branch
3. Reports any conflicts that need resolution

If there are conflicts, resolve them normally (`git status` → edit files → `git add` → `git rebase --continue`). If the rebase produces too many conflicts and you want to abandon it: `git rebase --abort` returns you to the pre-sync state.

---

## The System Together

A typical workflow across multiple sessions:

```
Session 1:
  /start-session               → creates worktree, loads state
  [Claude does work]
  /end-session                 → updates state, merges to main, pushes

Session 2:
  /start-session               → creates new worktree, loads updated state
  [Claude does work]
  /sync                        → pulls in a hotfix that landed on main mid-session
  [Claude continues work]
  /end-session                 → updates state, merges to main, pushes

Session 3 (parallel):
  /start-session feature-x     → separate worktree for a different feature
  [Claude does work in parallel with Session 2]
  /end-session                 → independent merge to main
```

The state document is the connective tissue. It lives in the main working tree (not in any worktree) and is updated by every session's end-session command. Each session reads the state that all prior sessions left behind.

---

## Worktree Environment Variables

Worktrees do not automatically inherit `.env.local`. The start-session command copies it at creation time. If you add new environment variables to the project during a session, remember to propagate them to the worktree:

```bash
cp .env.local .claude/worktrees/[session-name]/.env.local
```

This is the most common source of "why is this broken in the worktree?" issues.

---

## State Document Location

By default: `docs/state/project-state.md`

If your project uses a different path, update the start-session and end-session commands to reference it. The location doesn't matter; consistency does. Every session needs to read from and write to the same file.

---

## When to Skip the Lifecycle

The session lifecycle is most valuable for:
- Multi-session projects with significant history
- Projects where Claude needs to maintain consistency across many decisions
- Any project where you've had sessions go wrong and lost context

It's overhead you might skip for:
- Throwaway experiments
- One-off scripts with no ongoing maintenance
- Projects shorter than 3-4 sessions

If you're not sure, use it. The overhead is 2-3 minutes per session. The payoff is that session 10 starts with accurate context instead of a stale guess.
