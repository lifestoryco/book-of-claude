# Book of Claude

A battle-tested Claude Code playbook. Commands, agents, hooks, and workflows I use every day.

> I've been building production software with Claude Code as my only engineering teammate.
> This repo is everything I've figured out — the systems, the commands, the hard-won lessons.
> Take what you want, ignore the rest.

---

## Start Here

Copy `starter-kit/` into your project. 5 files, 5 minutes. You get:

- **Burn rate tracking** — know exactly how much usage you have left before you hit the limit
- **Multi-agent code review** — 4 specialists review your code in parallel (security, logic, UX, architecture)
- **Session management** — clean worktree-based start/end lifecycle so Claude always knows where it is
- **Project constitution** — a `CLAUDE.md` template that actually constrains behavior instead of just describing it

That's 80% of the value. The rest of this repo is the other 20%.

```bash
cp -r starter-kit/.claude your-project/
cp -r starter-kit/scripts your-project/
cp starter-kit/CLAUDE.md.template your-project/CLAUDE.md
# Edit CLAUDE.md for your project, then: claude
```

See [QUICK-START.md](./QUICK-START.md) for the full 5-minute walkthrough.

---

## The Five Patterns

These are the ideas. The files in this repo are just implementations.

### 1. Project Constitution

`CLAUDE.md` is not documentation — it is a contract. The difference is enforceability. A contract tells Claude what it must never do (hard bans), what it must always do (invariants), and what patterns to follow. A good CLAUDE.md is a single file that makes Claude behave consistently across every session, every worktree, every context reload.

The anti-pattern is writing a CLAUDE.md that describes your project. The right pattern is writing one that constrains Claude's behavior. "Never use this deprecated library" is a constraint. "This project uses X" is just description.

The template in `starter-kit/CLAUDE.md.template` gives you the skeleton. The non-negotiable rules table is the most important section — fill it in aggressively.

### 2. Session Protocol

Claude Code runs best when each session has a defined start and end. At start: load state, confirm context, agree on scope. At end: commit, push, update docs. This sounds obvious but most people skip it, and the result is sessions that drift — Claude loses context mid-task, makes decisions without knowing what changed yesterday, and leaves half-finished work in a confused state.

The worktree model makes this clean. Each session gets its own git worktree branch. Start creates it, sets the context, and runs a pre-flight check. End rebases onto main and updates the session state doc. Claude always knows what session it's in and what came before.

`/start-session` and `/end-session` handle this. The state lives in `docs/state/handoff.md` (or whatever you name it). After a few sessions, the pattern becomes muscle memory.

### 3. Work Breakdown Structure

Large features need to be decomposed before Claude touches any code. A WBS is a numbered task list with explicit dependencies, acceptance criteria, and effort estimates. The point isn't project management — it's cognitive load management. A well-written WBS task tells Claude exactly what to do, what not to touch, and how to know when it's done.

The `/wbs` command shows status. `/run-task T-123` executes a specific task. `/next` asks Claude to recommend what to work on based on current state. The discipline of writing WBS tasks up front pays back immediately when Claude executes them without scope creep.

### 4. Advisory Board (Alpha Squad)

Some decisions need a second opinion — architecture choices, product direction, tradeoffs with no obvious answer. The Alpha Squad pattern simulates a panel of advisors (CTO, product strategist, security lead, UX lead, etc.) who debate a question and reach a recommendation. It runs as a single Claude session with multiple named personas.

The output is a structured recommendation with minority opinions preserved. It's not magic — it's just forcing Claude to argue both sides of a decision before committing to one. But the output quality is noticeably better than asking Claude "what should I do about X?"

`/alpha-squad [topic]` runs the full board. `/alpha-squad huddle: [topic]` runs a faster 3-member version.

### 5. Guard Rails (Hooks)

Hooks run before or after Claude tool calls. They are the only way to make certain behaviors deterministic. If you want Claude to never run `rm -rf` unattended, a permission rule helps — but a hook that blocks it at the shell level is a hard wall. The difference matters when the stakes are high.

The hooks in this repo are minimal and auditable. `block-dangerous-commands.sh` is the most important one — it intercepts Bash calls and checks against a blocklist. Read every hook script before using it. They run with your shell permissions, which means a malicious hook can do anything your user account can do. See [SECURITY.md](./SECURITY.md).

---

## Command Reference

All commands live in `.claude/commands/`. Run them with `/command-name` in a Claude Code session.

| Command | What it does | Token Cost |
|---------|-------------|------------|
| `/alpha-squad` | AI advisory board simulation — structured debate on a topic | High |
| `/art` | Creative lab / generative art session | Med |
| `/burn-rate` | Usage dashboard — how much budget remains | Low |
| `/start-session` | Begin a worktree session with context load | Low |
| `/end-session` | End session, rebase onto main, push | Low |
| `/run-task` | Execute a WBS task by ID | Med |
| `/next` | Recommend what to work on next | Low |
| `/wbs` | Work breakdown status board | Low |
| `/update-docs` | Post-task documentation updates | Low |
| `/scout` | Reddit social listening dashboard | Med |
| `/scout-draft` | Collaborative Reddit reply drafting | Med |
| `/scout-seed` | Plant authentic discussion questions | Med |
| `/code-review` | Multi-agent parallel code review | High |
| `/ux-audit` | UX and accessibility audit | High |
| `/analytics` | Multi-platform analytics queries | Med |
| `/security-audit` | Security scan across the codebase | High |
| `/compliance` | GDPR / CCPA / SOC 2 audit | High |
| `/launch-check` | Launch readiness gate | Med |
| `/sync` | Rebase worktree onto main | Low |
| `/qa-report` | Consolidated bug report | Med |
| `/content` | SEO content generator | Med |
| `/prompt-builder` | Task prompt generator | Med |

**Token cost guide:** Low = under 10K tokens. Med = 10-50K. High = 50K+ (parallel agents, full-codebase scans).

---

## War Stories

See [WAR-STORIES.md](./WAR-STORIES.md).

The gotchas that cost me hours. BullMQ silently drops duplicate jobs. Framer Motion can't interpolate `'transparent'`. `merge2` swallows stream errors. `Set-Cookie` headers vanish on 307 redirects. 20 entries, each with the root cause and the fix. Read it before you hit them.

---

## The Full System

If you want everything — agents, hooks, rules, templates, and all the commands — the `.claude/` directory is the complete harness. The starter kit is the curated best-of. The rest is stuff that grew organically from months of daily use.

```
.claude/
  commands/        # All slash commands
  hooks/           # Shell scripts for PreToolUse / PostToolUse
  rules/           # Domain-specific rule files (imported into CLAUDE.md)
  worktrees/       # Per-session git worktrees (gitignored content)

starter-kit/
  .claude/
    commands/      # burn-rate, code-review, start-session
    hooks/         # block-dangerous-commands.sh
    settings.json  # Minimal permissions + hook registration
  scripts/
    claude-usage.sh
    start.sh
  CLAUDE.md.template

community/
  command-template.md
  README.md

docs/
  patterns/        # Longer writeups on each of the five patterns
  adr/             # Architecture decision records
```

The `rules/` pattern is worth calling out: instead of one giant CLAUDE.md, domain-specific rules live in separate files (`security.md`, `frontend.md`, `business-logic.md`, etc.) that CLAUDE.md references. This keeps the constitution scannable and makes it easy to update one domain without touching others.

---

## FAQ

**"Why not Cursor / Windsurf?"**

I use Claude Code because I want full control over context, hooks for deterministic enforcement, and terminal-native workflows. The IDE tools are great and plenty of people get more done with them. Use what works for you. This repo assumes you're already in Claude Code.

**"Isn't this over-engineered?"**

Start with `starter-kit/`. It's 5 files. Add pieces as you need them. The full system grew organically over months of daily use — you don't need all of it on day one, and you probably never will. The value compounds as the project gets complex.

**"Can I contribute?"**

Yes. See [CONTRIBUTING.md](./CONTRIBUTING.md). Drop your commands in `community/` and open a PR.

**"What kind of projects is this good for?"**

Anything where you're the only engineer (or close to it) and you need Claude to maintain consistent behavior across many sessions. Works for web apps, APIs, CLIs, data pipelines. The session protocol and CLAUDE.md patterns matter most for long-running projects. The commands work for anything.

---

## License

MIT — see [LICENSE](./LICENSE).

## Credits

Built by [@tealizard](https://github.com/tealizard). Feedback welcome — open an issue or PR.
