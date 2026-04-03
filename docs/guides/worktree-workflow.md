# The Worktree Workflow

Git worktrees let you check out multiple branches of the same repository simultaneously, each in its own directory with its own working tree. For Claude Code development, this solves a specific problem: how do you isolate each session's work so it doesn't pollute the main branch until it's reviewed?

---

## Why Worktrees

The naive approach is to work directly on main. This creates several problems:

- Half-finished sessions leave the main branch in an undefined state
- If something goes wrong mid-session, rolling back is messy
- Parallel sessions (if you ever run more than one Claude instance) are impossible
- There's no clean boundary between "in progress" and "reviewed and merged"

The worktree approach creates a clean boundary. Each session gets its own branch in its own directory. Main stays stable. Session work is isolated until it's deliberately merged.

The other benefit is session identity. When Claude starts in a worktree at path `.claude/worktrees/session-name/`, it knows which session it is. The session name is right there in the path. This matters for state handoff — the end-of-session commit and the state doc update both know where they're going.

---

## Directory Structure

```
project-root/                    # Main working tree (always on main)
├── .claude/
│   ├── commands/               # Slash commands
│   ├── hooks/                  # Hook scripts
│   ├── rules/                  # Domain rule files
│   ├── worktrees/              # Git worktrees live here
│   │   ├── session-name-1/     # One worktree per active session
│   │   └── session-name-2/     # Can run parallel sessions
│   └── settings.json
├── docs/
│   └── state/
│       └── project-state.md    # Session state (shared, in main)
└── [rest of project]
```

The worktrees directory is typically gitignored for its contents (the actual worktrees are separate git objects), but the directory itself exists in the repo.

---

## Start Script

The `/start-session` command runs a `start.sh` script that:

1. Generates a session name (typically `claude/[adjective-surname]` format, or you can specify one)
2. Creates a new git worktree branch off of the current main: `git worktree add .claude/worktrees/[session-name] -b claude/[session-name]`
3. Copies the `.env.local` file into the worktree (environment variables are not shared automatically)
4. Opens the session in the new worktree directory
5. Tells Claude to read `docs/state/project-state.md`

```bash
#!/bin/bash
SESSION_NAME=${1:-"claude/$(date +%s)"}
WORKTREE_PATH=".claude/worktrees/$SESSION_NAME"

# Create the worktree
git worktree add "$WORKTREE_PATH" -b "$SESSION_NAME"

# Copy environment (worktrees don't inherit .env.local)
cp .env.local "$WORKTREE_PATH/.env.local" 2>/dev/null || true

echo "Session started: $SESSION_NAME"
echo "Worktree: $WORKTREE_PATH"
echo "Next: claude --cwd $WORKTREE_PATH"
```

---

## End Script

The `/end-session` command runs an `end.sh` script that:

1. Commits any uncommitted work in the worktree
2. Updates `docs/state/project-state.md` with what was done this session
3. Rebases the session branch onto main: `git rebase main`
4. Fast-forward merges main to the session branch: `git checkout main && git merge --ff-only [session-branch]`
5. Pushes main
6. Removes the worktree: `git worktree remove [path]`

The rebase-then-fast-forward pattern keeps a linear git history. Each session's commits appear as a clean sequence on main after the session ends.

```bash
#!/bin/bash
SESSION_NAME=$1
WORKTREE_PATH=".claude/worktrees/$SESSION_NAME"

# In the worktree: rebase onto current main
cd "$WORKTREE_PATH"
git fetch origin main
git rebase origin/main

# Back in main: fast-forward
cd ../../../  # back to project root
git checkout main
git merge --ff-only "$SESSION_NAME"
git push origin main

# Clean up
git worktree remove "$WORKTREE_PATH"
git branch -d "$SESSION_NAME"
```

---

## The Sync Command

`/sync` rebases a live worktree onto main without ending the session. Use this when:
- Main has changed while your session is in progress (another session merged)
- You want to pull in a fix from main before continuing

```bash
#!/bin/bash
# Run from within the worktree
git fetch origin main
git rebase origin/main
```

If there are conflicts, resolve them and continue: `git rebase --continue`. If things go sideways: `git rebase --abort` returns you to the pre-sync state.

---

## Environment Variables

Worktrees do not inherit `.env.local` from the main working tree. This catches people off guard.

The start script copies `.env.local` at creation time. If new environment variables are added to the main `.env.local` during a session, you need to sync them to the worktree manually:

```bash
cp .env.local .claude/worktrees/[session-name]/.env.local
```

This is a common source of confusing errors — "why is this feature broken in the worktree but working on main?" Check the environment variables first.

---

## Parallel Sessions

Worktrees make it possible to run two sessions simultaneously on different tasks, with full isolation. Each session has its own branch, its own directory, its own `.env.local`.

Practical considerations:
- Both sessions share the same database (if local) — be aware of conflicting migrations
- Both sessions share the same node_modules (linked, not copied) — this is fine
- If both sessions modify the same file, the second one to merge will have a conflict to resolve

For most solo development, parallel sessions are rare. The value of the worktree model is primarily the clean boundary between sessions, not the parallelism.

---

## State Handoff

The session state document is the connective tissue between sessions. It lives in the main working tree (not in any worktree) so it's shared across all sessions.

The end-session ritual updates it. The start-session ritual reads it. Between them, it carries:
- What was done in the last session (files changed, decisions made, commits)
- What's next (ordered priority list)
- Current blockers
- Context that the next session needs but might not be obvious from the code

Writing a good "what's next" section is the most important part of the end-of-session update. The next Claude instance will read this cold, without memory of the current session. The more specific you are — "next task is to implement the email send function in `lib/notifications/send.ts`, the schema is already done, don't modify the migration" — the less ramp-up time the next session needs.

---

## Conflict Resolution

Merge conflicts in the worktree workflow typically happen when:
- Two sessions modified the same file
- You rebased onto a main branch that changed the same file you changed

Resolve conflicts the normal way: `git status` to see what's conflicted, edit the files to resolve, `git add [file]`, `git rebase --continue`.

For the state document specifically, conflicts are almost always in the "What Was Just Done" section. The resolution is usually to keep both sessions' entries, not to pick one. Read both, merge them into a coherent history, commit.

---

## What to Do When a Session Goes Wrong

If a session produced bad output and you want to discard everything:

```bash
# Option 1: Discard from within the worktree
git checkout HEAD -- .           # Reset all changes in worktree
git clean -fd                    # Remove untracked files

# Option 2: Nuke the worktree entirely
cd project-root
git worktree remove .claude/worktrees/[session-name] --force
git branch -D claude/[session-name]
# Start fresh with /start-session
```

The worktree model makes this consequence-free for main. The bad session's branch is gone; main was never touched.

---

## Common Mistakes

**Forgetting to copy .env.local.** The most common issue. Start script handles it, but if you add new env vars mid-project, remember to propagate them to active worktrees.

**Committing in the main working tree instead of the worktree.** If you forget you're supposed to be in a worktree and run Claude from project root, changes land on main directly. The fix: start-session creates the worktree for you. Always use it.

**Stale state docs.** If you skip the end-session update, the next session starts with a state doc that doesn't reflect the last session's work. Take the five minutes.

**Long-running worktrees.** A worktree that lives for multiple weeks while main accumulates significant changes will have a painful rebase at the end. Keep sessions focused. End them when the work is done, even if it's not perfect. Smaller, more frequent merges are easier than one big one.
