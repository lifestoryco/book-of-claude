# Book of Claude

My actual Claude Code setup — the commands, hooks, rules, and workflows I use every day building production software solo. Putting it all in the open so you can use it, improve it, and build on it.

Star it if it's useful. Open a PR if you build something better.

---

## Give This to Claude

Want Claude to implement this system in your project? Share this repo URL and say:

> "Read the README and QUICK-START in this repo and implement the full starter kit in my project."

Claude will handle the rest. See [QUICK-START.md](./QUICK-START.md) for the exact steps.

---

## What's Here

```
starter-kit/          # Start here. 5 files, 5 minutes.
  .claude/
    commands/         # /burn-rate, /code-review, /start-session, /end-session
    hooks/            # block-dangerous-commands.sh
    settings.json     # Hook registration + permissions
  scripts/
    claude-usage.sh   # Powers /burn-rate
    start.sh          # Powers /start-session
  CLAUDE.md.template  # Fill this in for your project

.claude/              # The full system — pick what you need
  commands/           # 20+ slash commands
  hooks/              # 3 hooks (dangerous commands, banned patterns, auto-typecheck)
  rules/              # Domain rule files (frontend, security, env-config)
  agents/             # 7 specialist subagents

community/            # Commands contributed by others — add yours here
docs/                 # Templates for advisory board, tasks, state tracking
WAR-STORIES.md        # 16 real production bugs with root causes and fixes
```

---

## Starter Kit (5 minutes)

**Copy into your project:**

```bash
git clone https://github.com/lifestoryco/book-of-claude.git book-of-claude
cp -r book-of-claude/starter-kit/.claude /path/to/your-project/
cp -r book-of-claude/starter-kit/scripts /path/to/your-project/
chmod +x /path/to/your-project/scripts/*.sh
chmod +x /path/to/your-project/.claude/hooks/*.sh
```

**Create your CLAUDE.md:**

```bash
cp book-of-claude/starter-kit/CLAUDE.md.template /path/to/your-project/CLAUDE.md
```

Open it and fill in:
- **Non-negotiable rules table** — write constraints, not descriptions. `"Never use getSession()"` is a constraint. `"This project uses auth"` is not.
- Auth pattern (delete if not applicable)
- Git commit format
- Self-verification commands (what to run before marking work done)

**Launch:**

```bash
cd /path/to/your-project && claude
```

Claude reads `CLAUDE.md` automatically on startup. Run `/burn-rate` to confirm the commands are working.

**What you get:**

| Command | What it does |
|---------|-------------|
| `/burn-rate` | Usage dashboard — session and weekly budget remaining |
| `/code-review` | 4 specialist agents review in parallel (security, logic, UX, architecture) |
| `/start-session` | Load state doc, confirm context, set scope |
| `/end-session` | Commit, rebase onto main, update state doc |

Plus `block-dangerous-commands.sh` — a hook that intercepts every Bash call and blocks `rm -rf`, `git push --force`, `DROP TABLE`, and `--no-verify` before they run. Not a rule Claude can choose to ignore. A hard wall.

---

## The Five Patterns

These are the ideas the whole system is built on.

### 1. Project Constitution

`CLAUDE.md` is an enforcement contract, not documentation. It has three things:

- **Hard bans** — `NEVER hard-delete records, use soft-delete only`
- **Invariants** — `ALWAYS run tsc --noEmit before marking work complete`
- **Patterns** — the one correct way to do auth, commits, error handling in this codebase

A vague CLAUDE.md produces inconsistent behavior across sessions. A tight one doesn't.

Keep domain-specific rules in separate `rules/*.md` files (`security.md`, `frontend.md`, `business-logic.md`) that CLAUDE.md references. Keeps the constitution scannable and makes it easy to update one domain without touching the rest.

### 2. Session Protocol

Each session has a defined start and end.

**Start:** Load `docs/state/project-state.md`, confirm what changed since last session, agree on scope.
**End:** Commit, push, update the state doc with what was done and what comes next.

The state doc is the continuity layer. Without it, every session starts cold. `/start-session` and `/end-session` handle the lifecycle.

### 3. Work Breakdown Structure

Before Claude touches code on any non-trivial feature:
1. Decompose into a numbered task list with explicit dependencies and acceptance criteria
2. One task = one session max, with a clear done state
3. Use `/run-task TASK-1.3` to execute, `/next` to get a recommendation, `/wbs` to see status

The discipline isn't project management — it's scope containment. A well-written task means Claude executes without wandering into adjacent work.

### 4. Advisory Board

`/alpha-squad [topic]` simulates a panel of advisors (CTO, Product Lead, Head of Growth, COO, UX Lead) who debate a decision and produce a structured recommendation with minority opinions preserved.

Use it when there's no obviously right answer — architecture choices, tech tradeoffs, product direction. Way better output than asking "what should I do about X" because it's forced to argue both sides before recommending one.

### 5. Guard Rails

Hooks run before and after Claude's tool calls. They're the only way to make certain behaviors truly deterministic.

```json
// .claude/settings.json — already configured in the starter kit
{
  "hooks": {
    "PreToolUse": [{
      "matcher": "Bash",
      "hooks": [{ "type": "command", "command": ".claude/hooks/block-dangerous-commands.sh" }]
    }]
  }
}
```

Claude cannot override a hook — it's enforced at the shell level before the command runs. **Read every hook script before using it.** See [SECURITY.md](./SECURITY.md).

---

## Command Reference

All commands live in `.claude/commands/`. Copy the ones you want into your project.

| Command | What it does | Cost |
|---------|-------------|------|
| `/burn-rate` | Usage dashboard — session, weekly, and model-level budget | Low |
| `/start-session` | Load state, confirm context, set scope | Low |
| `/end-session` | Commit, rebase onto main, update state doc | Low |
| `/sync` | Rebase current branch onto origin/main | Low |
| `/next` | Recommend what to work on based on current state | Low |
| `/wbs` | Work breakdown status board | Low |
| `/update-docs` | Post-task docs sync (flight plan + state) | Low |
| `/run-task` | Execute a task by ID from docs/tasks/pending/ | Med |
| `/prompt-builder` | Generate a self-contained task prompt for autonomous execution | Med |
| `/code-review` | 4 specialist agents review in parallel | High |
| `/security-audit` | Full security scan — auth, secrets, OWASP | High |
| `/ux-audit` | UX and accessibility audit | High |
| `/compliance` | GDPR / CCPA / SOC 2 readiness audit | High |
| `/launch-check` | Pre-deploy quality gate | Med |
| `/qa-report` | Consolidated bug report from QA findings | Med |
| `/alpha-squad` | Advisory board — structured debate on a decision | High |
| `/analytics` | Cross-platform analytics queries (PostHog, GA4, Clarity) | Med |
| `/scout` | Reddit social listening dashboard | Med |
| `/scout-draft` | Collaborative Reddit reply drafting | Med |
| `/scout-seed` | Plant discussion questions in subreddits | Med |
| `/content` | SEO content generator | Med |
| `/art` | Creative / generative art session | Med |

**Cost guide:** Low < 10K tokens · Med 10–50K · High 50K+ (parallel agents, full-codebase scans)

---

## Example: WBS in Action

Not sure how the project management system works? [docs/examples/calculator-wbs.md](./docs/examples/calculator-wbs.md) walks through building a calculator app from scratch — flight plan, prompt generation, task execution, and state tracking. The full loop.

---

## War Stories

[WAR-STORIES.md](./WAR-STORIES.md) — 16 real production bugs. Each has the symptom, root cause, fix, and detection signal.

BullMQ silent job drops. Framer Motion color interpolation failures. Set-Cookie headers on redirects. useRef staleness in async loops. backdrop-filter stacking contexts. Claude hooks config silently disappearing. Read it before you hit them.

---

## Contributing

This is my actual daily system, open and actively maintained. If you've built a command that solves something real, drop it in `community/` and open a PR. The only rule: it has to be something you actually use.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the format.

---

MIT · Built by [@tealizard](https://github.com/tealizard) · [handoffpack.com](https://www.handoffpack.com)
