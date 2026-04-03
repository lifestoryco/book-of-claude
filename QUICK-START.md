# Quick Start

Five minutes. That's all this takes. Follow the steps in order.

---

## Step 1 — Clone this repo

```bash
git clone https://github.com/tealizard/book-of-claude.git
cd book-of-claude
```

---

## Step 2 — Copy the starter kit into your project

```bash
cp -r starter-kit/.claude /path/to/your-project/
cp -r starter-kit/scripts /path/to/your-project/
```

Make the scripts executable:

```bash
chmod +x /path/to/your-project/scripts/*.sh
chmod +x /path/to/your-project/.claude/hooks/*.sh
```

---

## Step 3 — Create your CLAUDE.md from the template

```bash
cp starter-kit/CLAUDE.md.template /path/to/your-project/CLAUDE.md
```

Open it and fill in:
- Your project name and one-line description
- Your non-negotiable rules (the most important section — don't skip it)
- Your auth pattern (or delete that section if not applicable)
- Your git commit format preference

The template has comments explaining what goes in each section.

---

## Step 4 — Open Claude Code in your project

```bash
cd /path/to/your-project
claude
```

Claude will automatically read your CLAUDE.md on startup.

---

## Step 5 — Try the starter commands

**Check your usage budget:**
```
/burn-rate
```
This runs `scripts/claude-usage.sh` and prints a dashboard. You'll see how much of your monthly limit is used and an estimated runway.

**Run a code review:**
```
/code-review
```
This launches 4 parallel agents (security, logic, UX, architecture) that each review the current codebase. Results are consolidated into a single report. This is a High token-cost command — use it when you want a thorough check, not on every small change.

**Start a clean session:**
```
/start-session
```
This runs `scripts/start.sh`, prints session info, and waits for your go-ahead before doing anything. Clean session hygiene from the first interaction.

---

## Step 6 — Read WAR-STORIES.md

Before you hit your first production bug that's already documented here:

```bash
cat WAR-STORIES.md
```

Or just read it in your editor. 20 real bugs, each with the root cause and fix. Ten minutes now saves hours later.

---

## Step 7 — Explore the full `.claude/` for more

The starter kit is the curated 80%. When you're ready for more:

- `.claude/commands/` — all slash commands
- `.claude/hooks/` — all hook scripts
- `.claude/rules/` — domain-specific rule files (frontend, security, business-logic, etc.)

Add what you need. Skip what you don't.

---

## What's Next

Once the starter kit is running smoothly, the highest-value additions in order:

1. **Session protocol** — add `docs/state/handoff.md` and wire up `/start-session` and `/end-session` properly
2. **WBS discipline** — start decomposing features into numbered tasks before Claude touches code
3. **Alpha Squad** — add `/alpha-squad` for architecture decisions and tradeoff analysis
4. **Domain rules** — move domain-specific constraints out of CLAUDE.md into separate `rules/*.md` files

See [README.md](./README.md) for the full pattern documentation.
