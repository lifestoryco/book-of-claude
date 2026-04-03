# book-of-claude

**My actual Claude Code setup — the commands, hooks, and workflows I use building production software solo. Putting it all in the open so you can use it, improve it, and build on it.**

[![GitHub Stars](https://img.shields.io/github/stars/lifestoryco/book-of-claude?style=flat&color=black)](https://github.com/lifestoryco/book-of-claude/stargazers)
[![MIT License](https://img.shields.io/badge/license-MIT-black?style=flat)](./LICENSE)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-black?style=flat)](./CONTRIBUTING.md)

&nbsp;· [Concepts](#-concepts) · [Quick Start](#-quick-start) · [Five Patterns](#️-five-patterns) · [Commands](#-commands-22) · [Tips](#-tips-10) · [Contributing](#-contributing) ·

---

## 🧠 CONCEPTS

| Concept | What it is | Where it lives |
|---------|-----------|---------------|
| **Slash Commands** | Reusable prompt templates. `/code-review` runs 4 agents in parallel. `/alpha-squad` debates architecture decisions. | `.claude/commands/` |
| **Hooks** | Shell scripts that run before Claude's tool calls. Hard walls — not soft rules Claude can choose to ignore. | `.claude/hooks/` |
| **Rules** | Domain rule files. One per concern: `security.md`, `frontend.md`, `env-config.md`. Referenced from CLAUDE.md. | `.claude/rules/` |
| **Agents** | Specialist subagents for parallelizable work. Each has isolated context, custom tools, and persistent identity. | `.claude/agents/` |
| **CLAUDE.md** | The project constitution. Hard bans + invariants + the one correct pattern per domain. Not documentation — enforcement. | root |
| **Session Protocol** | `/start-session` loads the state doc. `/end-session` commits and updates it. Never start a session cold. | `docs/state/` |
| **WBS** | Work breakdown structure: decompose → prompt-build → run → verify. One task = one session max. | `docs/flight-plan.md` |

---

## 🔥 HOT

| Feature | What it does |
|---------|-------------|
| `/alpha-squad` | Simulates a 5-person advisory board (CTO, Product, Growth, COO, UX) debating a decision. Forces both sides. Preserves minority views. |
| `/code-review` | 4 specialist agents review in parallel — security, logic, UX, architecture. High signal, fast. |
| `block-dangerous-commands.sh` | Intercepts every Bash call. Blocks `rm -rf`, `git push --force`, `DROP TABLE`, `--no-verify` before they run. Not a rule — a wall. |
| `calculator-wbs.md` | Full WBS walkthrough from blank project to built feature: `/wbs` → `/prompt-builder` → `/run-task` → `/update-docs` → `/next` |

---

## 📁 WHAT'S HERE

```
starter-kit/           # Start here — 5 files, 5 minutes
  .claude/
    commands/          # /burn-rate, /code-review, /start-session, /end-session
    hooks/             # block-dangerous-commands.sh
    settings.json      # Hook registration + permissions
  scripts/
    claude-usage.sh    # Powers /burn-rate
    start.sh           # Powers /start-session
  CLAUDE.md.template   # Fill this in for your project

.claude/               # Full system — pick what you need
  commands/            # 22 slash commands
  hooks/               # 3 hooks (dangerous commands, banned patterns, auto-typecheck)
  rules/               # frontend · security · env-config · and more
  agents/              # 7 specialist subagents

docs/
  examples/            # calculator-wbs.md — full WBS walkthrough
  advisory-board/      # charter + meeting log for /alpha-squad
  state/               # project-state.md template

community/             # Commands from others — add yours here
```

---

## 🚀 QUICK START

**1. Clone and copy into your project:**

```bash
git clone https://github.com/lifestoryco/book-of-claude.git book-of-claude
cp -r book-of-claude/starter-kit/.claude /path/to/your-project/
cp -r book-of-claude/starter-kit/scripts /path/to/your-project/
chmod +x /path/to/your-project/scripts/*.sh
chmod +x /path/to/your-project/.claude/hooks/*.sh
```

**2. Create your CLAUDE.md:**

```bash
cp book-of-claude/starter-kit/CLAUDE.md.template /path/to/your-project/CLAUDE.md
```

Fill in constraints — not descriptions. `"Never use getSession()"` is a constraint. `"This project uses auth"` is not.

**3. Launch:**

```bash
cd /path/to/your-project && claude
```

Run `/burn-rate` to confirm the commands are working.

> **Want Claude to handle setup for you?** Share this repo and say:
> *"Read the README and QUICK-START in this repo and implement the full starter kit in my project."*

---

## ⚙️ FIVE PATTERNS

| # | Pattern | What it does | The key insight |
|---|---------|-------------|----------------|
| 1 | **Project Constitution** | `CLAUDE.md` with hard bans, invariants, and the one correct pattern per domain | Vague CLAUDE.md = inconsistent behavior across sessions. Tight one doesn't. |
| 2 | **Session Protocol** | `/start-session` loads state doc. `/end-session` commits + updates it. | Without a state doc, every session starts cold. This is the continuity layer. |
| 3 | **Work Breakdown** | Decompose → prompt-build → run → verify. One task = one session max with a clear done state. | The discipline isn't project management — it's scope containment. |
| 4 | **Advisory Board** | `/alpha-squad` simulates a panel of 5 personas. They argue both sides before recommending one. | Way better than asking "what should I do about X" — forced dissent surfaces real tradeoffs. |
| 5 | **Guard Rails** | Hooks run at the shell level before commands execute. Claude cannot override them. | The only way to make certain behaviors truly deterministic. Not a rule — a wall. |

---

## 📋 COMMANDS (22)

&nbsp;· [Session](#session) · [Work Management](#work-management) · [Review](#review) · [Product](#product) · [Marketing](#marketing) ·

#### Session

| Command | What it does | Cost |
|---------|-------------|------|
| `/burn-rate` | Usage dashboard — session, weekly, and model-level budget | Low |
| `/start-session` | Load state doc, confirm context, set scope | Low |
| `/end-session` | Commit, rebase onto main, update state doc | Low |
| `/sync` | Rebase current branch onto origin/main | Low |

#### Work Management

| Command | What it does | Cost |
|---------|-------------|------|
| `/next` | Recommend what to work on based on current state | Low |
| `/wbs` | Work breakdown status board | Low |
| `/update-docs` | Post-task docs sync — flight plan + state | Low |
| `/run-task` | Execute a task by ID from `docs/tasks/pending/` | Med |
| `/prompt-builder` | Generate a self-contained task prompt for autonomous execution | Med |

#### Review

| Command | What it does | Cost |
|---------|-------------|------|
| `/code-review` | 4 specialist agents review in parallel | High |
| `/security-audit` | Full security scan — auth, secrets, OWASP | High |
| `/ux-audit` | UX and accessibility audit | High |
| `/compliance` | GDPR / CCPA / SOC 2 readiness audit | High |
| `/launch-check` | Pre-deploy quality gate | Med |
| `/qa-report` | Consolidated bug report from QA findings | Med |
| `/alpha-squad` | Advisory board — structured debate on a decision | High |

#### Product

| Command | What it does | Cost |
|---------|-------------|------|
| `/analytics` | Cross-platform analytics queries — PostHog, GA4, Clarity | Med |

#### Marketing

| Command | What it does | Cost |
|---------|-------------|------|
| `/scout` | Reddit social listening dashboard | Med |
| `/scout-draft` | Collaborative Reddit reply drafting | Med |
| `/scout-seed` | Plant discussion questions in subreddits | Med |
| `/content` | SEO content generator | Med |
| `/art` | Creative / generative art session | Med |

**Cost guide:** Low < 10K tokens · Med 10–50K · High 50K+ (parallel agents, full-codebase scans)

---

## 💡 TIPS (12)

Things that aren't obvious until they burn you.

&nbsp;· [CLAUDE.md](#claudemd-4) · [Hooks](#hooks-3) · [Sessions](#sessions-2) · [Agents](#agents-3) ·

#### CLAUDE.md (4)

| Tip | What most people get wrong |
|-----|---------------------------|
| Your CLAUDE.md is a constitution, not a readme | If it reads like documentation, it won't change behavior. Every line should be a constraint Claude can violate. Rewrite anything that starts with "This project uses..." |
| Vague rules get vague compliance | `"Be careful with auth"` means nothing. `"NEVER call getSession() — use supabaseAdmin + manual cookie check"` means something. The more specific the ban, the harder it is to ignore. |
| Domain rules belong in `.claude/rules/`, not CLAUDE.md | CLAUDE.md should be scannable in 30 seconds. Move auth rules to `rules/security.md`, frontend rules to `rules/frontend.md`, reference them from CLAUDE.md. Claude reads them all. |
| Stale CLAUDE.md is worse than no CLAUDE.md | Outdated rules confidently point Claude in the wrong direction. Audit it every few weeks. Delete anything that no longer reflects how the codebase actually works. |

#### Hooks (3)

| Tip | What most people get wrong |
|-----|---------------------------|
| `settings.json` silently resets after IDE restarts | The most common Claude setup bug. If your hooks stop working, check if settings.json got overwritten. Commit it to version control — that's the only reliable fix. |
| Hooks run before the command, not after | A PreToolUse hook on Bash runs before every shell command Claude attempts. If it exits non-zero, the command is blocked — Claude sees the hook output, not the command output. |
| One hook can protect the whole repo | `block-dangerous-commands.sh` intercepts every Bash call and checks for `rm -rf`, `--no-verify`, `DROP TABLE`, force push. One file, total coverage. Claude literally cannot run those commands. |

#### Sessions (2)

| Tip | What most people get wrong |
|-----|---------------------------|
| Starting without a state doc is the #1 productivity killer | Claude has zero memory between sessions. Without `project-state.md`, it re-explores the codebase, makes assumptions, and often re-does work. 5 minutes updating it at session end saves 30 minutes at the next start. |
| `/end-session` is not optional | Committing, rebasing, and updating the state doc isn't cleanup — it's the handoff to your next session. Skip it once and you'll spend the next session reconstructing context. |

#### Agents (3)

| Tip | What most people get wrong |
|-----|---------------------------|
| `/alpha-squad` works best on decisions you've already made | Use it right before you commit to a direction, not after you're already building. The CTO and UX Lead arguing at design time is useful. Arguing after 3 days of implementation is just annoying. |
| Parallel agents don't share context | Each subagent in `/code-review` has its own context window. They can't read each other's findings. Design your commands so each agent has everything it needs independently — don't assume Agent B will see what Agent A found. |
| Give agents a specific failure mode to look for | `"Review this for security issues"` is weak. `"Look specifically for: exposed service role keys, missing RLS policies, and places where getSession() was used instead of getUser()"` gets real findings. |

---

## 🤝 CONTRIBUTING

This is my actual daily system — open and actively maintained. If you've built a command that solves something real, drop it in `community/` and open a PR. The only rule: it has to be something you actually use.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the format.

---

MIT · Built by [@tealizard](https://github.com/tealizard) · [handoffpack.com](https://www.handoffpack.com)
