# book-of-claude

**My actual Claude Code setup — the commands, hooks, and workflows I use building production software solo. Putting it all in the open so you can use it, improve it, and build on it.**

[![GitHub Stars](https://img.shields.io/github/stars/lifestoryco/book-of-claude?style=flat&color=black)](https://github.com/lifestoryco/book-of-claude/stargazers)
[![MIT License](https://img.shields.io/badge/license-MIT-black?style=flat)](./LICENSE)
[![Contributions Welcome](https://img.shields.io/badge/contributions-welcome-black?style=flat)](./CONTRIBUTING.md)

&nbsp;· [Concepts](#-concepts) · [Quick Start](#-quick-start) · [Five Patterns](#️-five-patterns) · [Commands](#-commands-22) · [Tips](#-tips-10) · [War Stories](#️-war-stories-16) · [Contributing](#-contributing) ·

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
| `WAR-STORIES.md` | 16 real production bugs. BullMQ silent drops. useRef staleness in async loops. backdrop-filter stacking contexts. Claude hooks silently disappearing. |

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
WAR-STORIES.md         # 16 real bugs with symptoms, causes, and fixes
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

## 💡 TIPS (10)

&nbsp;· [CLAUDE.md](#claudemd-3) · [Hooks](#hooks-2) · [Sessions](#sessions-2) · [WBS](#wbs-2) · [Agents](#agents-1) ·

#### CLAUDE.md (3)

| Tip | Why |
|-----|-----|
| Keep CLAUDE.md under 200 lines | Longer files reduce adherence. Move domain rules to `.claude/rules/*.md` and reference them. |
| Write constraints, not descriptions | `"Never hard-delete records"` enforces behavior. `"This project uses soft delete"` doesn't. |
| Use `NEVER` and `ALWAYS` | Soft language gets soft compliance. Hard language in CLAUDE.md gets hard compliance. |

#### Hooks (2)

| Tip | Why |
|-----|-----|
| Hooks are not rules | A rule can be ignored. A hook enforced at shell level cannot. Put hard bans in hooks. |
| Read every hook before using it | Hooks run before every matching tool call. Know what they block before they block something you need. |

#### Sessions (2)

| Tip | Why |
|-----|-----|
| Update `project-state.md` every session | Without it every session starts cold. It's the only continuity layer between sessions. |
| Run `tsc --noEmit` before marking work done | TypeScript errors at commit time are expensive. Catch them at task time instead. |

#### WBS (2)

| Tip | Why |
|-----|-----|
| Use `/prompt-builder` before `/run-task` | A well-written prompt = Claude executes without wandering into adjacent work. |
| One task = one session max | Scope creep is the #1 reason sessions fail. A clear done state = clean execution. |

#### Agents (1)

| Tip | Why |
|-----|-----|
| Use `/alpha-squad` before architecture decisions | Forced dissent surfaces problems you didn't think of. Use it before committing to a direction, not after. |

---

## ☠️ WAR STORIES (16)

Real bugs that cost real time. Each entry has the symptom, root cause, fix, and detection signal.

| Category | Entries |
|----------|---------|
| **Claude Config** | Hooks silently disappear after IDE restart |
| **Async / State** | `useRef` staleness in async loops · BullMQ silent job drops · Set-Cookie headers on redirects |
| **CSS / Layout** | `backdrop-filter` stacking contexts · Framer Motion color interpolation · `bg-dark` not theme-adaptive |
| **Data / Files** | Multi-part archive stream detection · Large file upload cap surprises |
| **Video / Media** | Mux signed URL pitfalls · Webhook asset readiness delays |
| **Build / Config** | CSP headers breaking React hydration · `allowedDevOrigins` not in Next.js 14 |

→ **[Read all 16 in WAR-STORIES.md](./WAR-STORIES.md)**

---

## 🤝 CONTRIBUTING

This is my actual daily system — open and actively maintained. If you've built a command that solves something real, drop it in `community/` and open a PR. The only rule: it has to be something you actually use.

See [CONTRIBUTING.md](./CONTRIBUTING.md) for the format.

---

MIT · Built by [@tealizard](https://github.com/tealizard) · [handoffpack.com](https://www.handoffpack.com)
