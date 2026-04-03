# Starter Kit

Start here. 5 files. 5 minutes.

---

## What's in here

```
starter-kit/
  .claude/
    commands/
      burn-rate.md       # Usage dashboard
      code-review.md     # 4-agent parallel code review
      start-session.md   # Session start with context load
    hooks/
      block-dangerous-commands.sh
    settings.json        # Permissions + hook registration
  scripts/
    claude-usage.sh      # Usage tracking script
    start.sh             # Session start script
  CLAUDE.md.template     # Project constitution scaffold
```

Five files that give you the highest-leverage pieces of the full system.

---

## How to install

```bash
# From inside the book-of-claude repo
cp -r starter-kit/.claude /path/to/your-project/
cp -r starter-kit/scripts /path/to/your-project/
cp starter-kit/CLAUDE.md.template /path/to/your-project/CLAUDE.md

# Make scripts executable
chmod +x /path/to/your-project/scripts/*.sh
chmod +x /path/to/your-project/.claude/hooks/*.sh
```

Then open your CLAUDE.md and fill in the sections. The non-negotiable rules section is the most important one — don't leave it empty.

---

## What you get

**Burn rate tracking (`/burn-rate`)**

Runs `scripts/claude-usage.sh` and prints a usage dashboard. Token budget remaining, percentage used, estimated days of runway. Know where you stand before you kick off a big session.

**Multi-agent code review (`/code-review`)**

Launches 4 parallel sub-agents — security analyst, logic reviewer, UX auditor, architecture reviewer — each examining the codebase from their perspective. Results are consolidated into a single prioritized report. High token cost; use when it counts.

**Session management (`/start-session`)**

Runs `scripts/start.sh`, prints current session info (branch, last commit, any staged changes), and waits for your go-ahead before doing anything. Forces a clean, deliberate start to every session.

**Hook protection (`block-dangerous-commands.sh`)**

A PreToolUse hook that intercepts every Bash call and checks it against a blocklist before Claude runs it. The default blocklist covers recursive filesystem deletes. Read the script before using it — it's short and auditable. See [SECURITY.md](../SECURITY.md).

**Project constitution (`CLAUDE.md.template`)**

A scaffold for the most important file in your project. Fill in your non-negotiable rules, your auth pattern, your git commit format, and your self-verification steps. This file is what makes Claude behave consistently across sessions.

---

## What's not in here

The full system has more: the Alpha Squad advisory board, WBS task management, social listening, analytics commands, compliance audits, and more. All of that lives in `.claude/commands/` in the root of this repo. Add it as you need it.

The starter kit is the part that works immediately for any project. The rest of the system is specialized and grows with your project's complexity.

---

## After install

See [QUICK-START.md](../QUICK-START.md) for the step-by-step walkthrough and the recommended order for adding more pieces.
