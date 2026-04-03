# The Five Patterns — Deep Dive

The README introduces five patterns. This guide goes deeper on each one: what it is, what problem it solves, how to implement it, and where it breaks down.

---

## Pattern 1: Project Constitution

### What it is

A `CLAUDE.md` file at the root of your project that Claude reads automatically at the start of every session. It establishes the behavioral contract for every Claude instance that touches the codebase.

### What problem it solves

Without a constitution, Claude makes up the rules as it goes. It infers conventions from the existing code, which works until the existing code has inconsistencies (it always does). It makes architecture decisions based on general best practices, which may conflict with specific decisions your project has already made. It has no way to know what's off-limits unless you tell it in the current session — and you'll forget to tell it eventually.

A CLAUDE.md that loads automatically means Claude always has the rules before it starts. You don't have to remember to say "oh and by the way, don't use that deprecated function."

### What goes in CLAUDE.md

**Non-negotiable rules table.** This is the most important section. Five to ten hard constraints, phrased as imperatives. "Every mutation must call `insertAuditEntry()`." "Never hard-delete records." "All API routes must verify auth before any data access." These are the invariants — if Claude violates one, it's a bug.

**Auth pattern.** Show the exact code. Copy-paste the correct pattern from a working file. If you use a non-standard approach (custom cookie-based auth, magic links, etc.), explain why the obvious approach is wrong. Claude will reach for the obvious approach unless you actively redirect it.

**Banned patterns.** Explicit list of imports, functions, or patterns that must never be used, with reasons. The reasons matter — "we banned X because it caused a security issue in production, use Y instead" is more robust than "we banned X" alone.

**Self-verification commands.** Tell Claude exactly what to run before considering work done. The type checker. The build command. Any project-specific tests. Make it mechanical: run these commands, fix any errors, then and only then is the task complete.

### What doesn't go in CLAUDE.md

Your entire codebase architecture. General best practices. Anything that's obvious from reading the code. The README. Documentation that never changes behavior.

CLAUDE.md is a behavioral contract, not a description. The test for inclusion: if this rule weren't here and Claude didn't follow it, would something break or become inconsistent? If yes, put it in. If no, leave it out.

### The rules file pattern

For larger projects, one CLAUDE.md becomes unwieldy. The solution: split domain rules into separate files in `.claude/rules/` — `security.md`, `frontend.md`, `business-logic.md`, etc. — and have CLAUDE.md reference them. This keeps the constitution scannable while allowing deep rules per domain. Claude loads the domain rules on demand rather than loading everything into every context.

### Where it breaks down

CLAUDE.md is advisory, not enforced. A packed context window can crowd out rules. The fix is hooks (Pattern 5) for the things that absolutely cannot slip. CLAUDE.md handles the 95%; hooks handle the 5% where the stakes are too high for advisory.

---

## Pattern 2: Session Protocol

### What it is

A defined start and end ritual for every Claude Code session, backed by a state document that persists across sessions and a git worktree that isolates session work.

### What problem it solves

Without a protocol, sessions drift. Claude starts without knowing what changed yesterday, makes decisions without the context of prior decisions, and leaves unfinished work in an undefined state. The person picking up a new session has to reconstruct context from memory, which is lossy and inconsistent.

With a protocol, every session starts with accurate state and ends with that state updated for the next session. Claude always knows what's been done, what's been decided, and what's next.

### The state document

A markdown file — call it `docs/state/project-state.md` or whatever works for your project — that follows a consistent format:

- Current status: phase, build state, blockers
- What was just done: files changed, commits, decisions made and why
- What's next: ordered priority list
- Previous sessions: condensed history, max four entries

The start-session command tells Claude to read this first. The end-session command tells Claude to update it before closing. Both are mechanical; neither requires judgment.

### The worktree model

Each session gets its own git worktree branch (e.g., `claude/session-name`). This provides:

- Isolation: session work doesn't pollute main until it's reviewed
- Parallelism: multiple sessions can run simultaneously without conflicts
- Rollback: if a session goes wrong, you can discard it without affecting main
- Clean state: each session starts from a known-good base

The `/start-session` command creates the worktree. The `/end-session` command rebases onto main and updates state. The `/sync` command rebases a live worktree onto a changed main without ending the session.

### The start ritual

1. Read `project-state.md` — what did the last session leave behind?
2. Confirm scope — what is this session's specific goal?
3. Pre-flight check — is the build passing? Any obvious issues to address first?
4. Begin work

### The end ritual

1. Commit all changes with proper commit message format
2. Update `project-state.md`: what was done, what was decided, what's next
3. Rebase onto main
4. Push

### Where it breaks down

The protocol only works if you maintain it. A stale state document is worse than none — it gives Claude false context. The discipline is in the end ritual. If you skip updating the state doc when you end a session, the next session starts with bad information.

---

## Pattern 3: Work Breakdown Structure

### What it is

A structured task list (the "flight plan") where each task has an ID, size estimate, status, and a separate prompt file that makes the task self-contained. The `/wbs` command shows status. `/run-task TASK-X.Y` executes a specific task using its prompt file.

### What problem it solves

Large features decomposed on-the-fly produce scope creep. Claude starts implementing a "notification system" and ends up making decisions about schema, UI, email template, delivery timing, and retry logic — all in one session, all without explicit checkpoints for human review. Some of those decisions are good. Some need to be different. Without a forcing function, there's no natural moment to redirect.

A WBS forces decomposition before implementation. The task prompt for "notification system" splits into four tasks: schema migration, send function, UI trigger, email template. Each has its own self-contained prompt with a clear scope, explicit human gates, and a definition of done. Claude works one task at a time. The human sees each piece as it lands.

### The flight plan

A table in `docs/flight-plan.md` (or wherever you put it) with:
- Task ID (e.g., TASK-2.3)
- Task title
- Size (S/M/L/XL)
- Status (TODO / READY / IN PROGRESS / NEEDS VERIFICATION / DONE)
- Prompt file path (once the prompt exists)

The flight plan is the bird's-eye view. The task prompts are the ground-level instructions.

### Task prompts

The most important element. A task prompt is a self-contained markdown file that a fresh Claude instance can execute without additional context. It includes:

- Context: why this task exists, what it builds on
- Goal: one sentence, observable outcome
- Steps: numbered, with specific file-level instructions
- Human gates: stopping points that require human confirmation before proceeding
- Verification: exactly what to run and what passing looks like
- Definition of done: checkbox list
- Rollback: how to undo if something goes wrong

The human gate is the key innovation. It breaks a large task into supervised chunks. Claude executes Step 1 and Step 2, stops, and says "here's what I built — confirm before I proceed to Step 3." This catches scope creep and wrong-direction work before it compounds.

### Writing good task prompts

Specificity is everything. "Implement the notification schema" is not a step. "Create a migration file in `supabase/migrations/` that adds a `notifications` table with columns `id UUID PRIMARY KEY`, `user_id UUID FK`, `type VARCHAR(50)`, `read_at TIMESTAMP`" is a step.

Write task prompts as if you're writing them for a contractor who is competent but has never seen your codebase. What do they need to know? What would a reasonable person do wrong if you didn't tell them?

### Where it breaks down

Keeping the flight plan current requires discipline. Tasks drift in scope. New tasks emerge. The fix is not to maintain perfect fidelity, but to update the flight plan at the end of each session as part of the end ritual. Two minutes of maintenance per session keeps it useful.

---

## Pattern 4: Advisory Board

### What it is

A simulated panel of advisors — personas with distinct expertise and mandates — that debates a question and produces a structured recommendation with minority opinions preserved. Triggered by `/alpha-squad [topic]`.

### What problem it solves

When you ask Claude "what should I do about X?", you get Claude's best guess at what a helpful assistant would recommend. That's a single perspective, optimized for agreeableness. It's useful, but it doesn't catch the second-order problems.

The advisory board pattern forces Claude to argue multiple positions. The CTO persona asks about technical debt and scalability. The security lead asks about attack surface. The product strategist asks about user impact. Each persona has a mandate that creates natural disagreement. The output preserves dissent — it doesn't paper over the minority view to produce a tidy consensus. The founder (you) reads the debate and makes the call.

### The board composition

The default board has five members, but you should customize it for your project:
- CTO / technical lead — architecture, debt, scalability
- Product strategist — user value, prioritization
- Security lead — attack surface, trust, compliance
- UX lead — user experience, accessibility
- Financial/business lead — ROI, risk, runway

For a consumer app, you might swap the financial lead for a growth/marketing persona. For a B2B enterprise product, you might add a compliance/legal persona. The personas are tools; configure them for your context.

### The huddle format

`/alpha-squad huddle: [topic]` runs a shorter version with three members instead of five. Use this for tactical decisions that don't need the full board — "should we use Redis or Postgres for this job queue?" benefits from a huddle. "Should we pivot to enterprise-only pricing?" warrants the full board.

### Mandatory dissent

The most important constraint on any advisory board: someone must disagree. If all five advisors reach the same conclusion with no dissent, either the question was trivial or the simulation collapsed into groupthink. Well-written board prompts explicitly require minority opinions. "If you would vote against this recommendation, state your objection clearly before the conclusion" is the kind of instruction that produces useful output.

### The founder decision point

Every board session ends with a Founder Decision Point: a structured summary of the recommendation, the primary dissent, the confidence level, and the reversibility of the decision. This forces the output into a form that's actually useful for making a decision, rather than a long discursive debate that the founder has to synthesize themselves.

### Where it breaks down

The board can become an echo chamber if the personas are defined too loosely. "A CTO who cares about quality" is not a persona with a mandate. "A CTO whose primary responsibility is preventing technical debt from blocking the team and who will push back on shipping fast at the cost of maintainability" is a persona with a mandate. The more specific the mandate, the more genuine the disagreement.

---

## Pattern 5: Guard Rails (Hooks)

### What it is

Shell scripts that run automatically before or after Claude tool calls, enforcing constraints at the OS level rather than the context level. The critical distinction: hooks are not advisory. They execute regardless of what's in Claude's context window.

### What problem it solves

Advisory rules (CLAUDE.md, rules files) work most of the time. Hooks exist for the cases where "most of the time" is not acceptable: deleting production data, running dangerous shell commands, committing secrets, overwriting critical files.

The difference between an advisory rule and a hook is the difference between "the speed limit is 65" and a physical road barrier. One shapes behavior through compliance; the other prevents outcomes through mechanics.

### How hooks work

Claude Code supports two hook types:
- `PreToolUse` — runs before a tool call executes, can block it
- `PostToolUse` — runs after a tool call completes, can log or react

A `PreToolUse` hook that exits with code 2 blocks the tool call. A hook that exits with 0 allows it. The hook receives the tool name and input as JSON via stdin, which lets you inspect what Claude is about to do before it does it.

The `block-dangerous-commands.sh` hook in the starter kit is the canonical example: it intercepts every Bash tool call, checks the command against a blocklist of dangerous patterns (`rm -rf /`, `DROP TABLE`, `chmod 777`, etc.), and exits 2 if there's a match. Claude sees a rejection; the command never runs.

### What to enforce vs. what to advise

Use hooks for:
- Commands that can cause irreversible data loss
- Operations that can expose secrets (committing `.env` files)
- Shell patterns that are never legitimate (`rm -rf /`)
- Post-task verification you want to be automatic (type check after every commit)

Use CLAUDE.md for:
- Patterns and conventions
- Architectural decisions
- Code style and organization
- Domain-specific rules

The overlap zone — "never use this deprecated function" — depends on severity. For a deprecated function that causes security issues if used, write a hook. For one that just produces messy code, a CLAUDE.md rule is sufficient.

### Security considerations

Hooks run with your shell permissions. A malicious hook can do anything your user account can do. Read every hook script before deploying it. Hooks from external sources should be treated the same way you'd treat any shell script from the internet: read it, understand it, then decide.

The hooks in this repo are intentionally minimal and auditable. Each one does one thing. They have no external dependencies. Read them before using them.

### Where it breaks down

Hooks add complexity. Every hook is a script that can fail, block legitimate operations, or interact unexpectedly with other hooks. Start with the minimum viable set (the starter kit includes only one hook) and add hooks deliberately, not because they seem like good ideas in the abstract.

The worst outcome is a hook that blocks legitimate operations silently. A hook that rejects a command should exit with a clear error message explaining what was rejected and why. Silence is a debugging nightmare.
