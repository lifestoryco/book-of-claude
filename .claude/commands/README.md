# Commands

Drop-in slash commands for Claude Code. Copy the ones you want into your project's `.claude/commands/` directory.

## Install

```bash
# Copy a single command
cp book-of-claude/.claude/commands/burn-rate.md your-project/.claude/commands/

# Copy all commands
cp book-of-claude/.claude/commands/*.md your-project/.claude/commands/
```

## Command Reference

| Command | What it does | Token Cost |
|---------|-------------|------------|
| `/alpha-squad` | AI advisory board debates your decisions | High |
| `/art` | Creative lab for generative art projects | Med |
| `/burn-rate` | Claude Code usage dashboard | Low |
| `/start-session` | Begin a worktree-isolated session | Low |
| `/end-session` | End session, rebase, push | Low |
| `/run-task` | Execute a WBS task by ID | Med |
| `/next` | Show next actionable tasks | Low |
| `/wbs` | Work breakdown status board | Low |
| `/update-docs` | Post-task status + doc updates | Low |
| `/scout` | Reddit social listening dashboard | Med |
| `/code-review` | 4-agent parallel code review | High |
| `/ux-audit` | Accessibility + design + responsive audit | High |
| `/analytics` | Multi-platform analytics queries | Med |
| `/security-audit` | OWASP + auth + secrets scan | High |
| `/compliance` | GDPR/CCPA/SOC 2 audit | High |
| `/launch-check` | Build + quality + integration gate | Med |
| `/sync` | Rebase worktree onto latest main | Low |
| `/qa-report` | Consolidated P0/P1/P2 bug report | Med |
| `/content` | SEO content generator | Med |
| `/prompt-builder` | Self-contained task prompt generator | Med |

**Token Cost Guide:**
- **Low** — Reads files, runs a script. Minimal token usage.
- **Med** — Some agent work or web research. Moderate usage.
- **High** — Multiple parallel agents. Can use 15-40% of a session window.
