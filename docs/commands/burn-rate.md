# /burn-rate

Shows a usage dashboard for your Claude Code subscription — how much you've used, how much remains, and whether your current pace is sustainable for the rest of the billing period.

---

## What It Does

Reads your Claude Code usage data and displays:

- **Session meter:** Tokens used in the current session vs. session limit (if applicable)
- **Daily meter:** Tokens used today vs. daily average that would keep you on track
- **Weekly meter:** Tokens used this week vs. weekly budget
- **Sonnet meter:** Sonnet-specific usage, separated from other models (Sonnet is typically the most expensive model in the stack)
- **Pace indicator:** A simple assessment of whether current usage pace will exhaust the budget before the billing period ends

---

## Setup

The burn rate command requires access to your Claude Code usage data. This is retrieved via the Claude Code OAuth token.

**To set up:**

1. Ensure you're logged into Claude Code: `claude auth login`
2. The command reads usage from the Claude Code API using the credentials stored by `claude auth`
3. No additional configuration is required

The command reads the script at `scripts/claude-usage.sh` (included in the starter kit). If you've customized your scripts directory location, update the command file to point to the correct path.

---

## How to Read the Dashboard

### Session Meter

Shows tokens consumed in the current Claude Code session. A session is a single continuous interaction from `claude` invocation to exit. High session consumption typically means:
- Long multi-agent tasks (code review, security audit)
- Extensive context loading (reading many files)
- Iterative back-and-forth on complex problems

### Weekly Meter

The most useful long-term indicator. Shows total consumption for the current week compared to the weekly budget that would keep you on track for the billing period. If you're at 80% of your weekly budget by Wednesday, you're burning hot.

### Sonnet Meter

Sonnet (the highest-capability model) is typically the most expensive model per token. Commands that run parallel agents — `/code-review`, `/security-audit`, `/ux-audit` — are Sonnet-heavy. The Sonnet meter helps you see whether high-capability model usage is driving your budget consumption.

### Pace Indicator

A simple projection: if you continue using Claude Code at this week's average daily rate, will you exhaust the budget before the billing period ends?

| Indicator | Meaning |
|-----------|---------|
| On track | Current pace fits comfortably within the budget |
| Elevated | You're running hot — sustainable if you have intensive work planned, worth watching |
| Critical | At current pace, budget will exhaust before period end |

The pace indicator is a projection, not a guarantee. A single intensive session (e.g., a full codebase refactor) can spike usage significantly above the weekly average.

---

## Troubleshooting

**"No usage data found"**
You may not be authenticated. Run `claude auth login` and retry.

**"Script not found"**
The command looks for `scripts/claude-usage.sh`. If your scripts are in a different location, edit `.claude/commands/burn-rate.md` (or wherever the command is defined) to update the path.

**Usage data looks stale**
Usage data is typically updated with a short delay (minutes to an hour). Very recent sessions may not appear immediately.

**The meter shows 0 for everything**
This can happen at the start of a billing period. If the billing period just reset, this is expected.

---

## Managing Budget

If the pace indicator is elevated or critical, common levers:

- **Reduce parallel agent commands.** `/code-review` runs 4 agents simultaneously. For routine changes, a single-agent review is sufficient.
- **Narrow context loading.** Loading `docs/reference/` or full codebase scans costs tokens. Load only what the current task requires.
- **Use task prompts.** A well-written task prompt reduces back-and-forth by giving Claude sufficient context up front. Back-and-forth is expensive.
- **Defer non-urgent multi-agent tasks.** Security audits, full UX audits, and compliance scans can wait until early in a billing cycle.
