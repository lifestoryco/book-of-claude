# Community Commands

Want to share your own commands? Drop them here and open a PR.

---

## How to contribute

1. Fork the repo
2. Copy `command-template.md` and rename it to your command name (use lowercase with hyphens: `my-command.md`)
3. Fill in all the sections
4. Test it in at least one real Claude Code session
5. Open a PR with a one-sentence description

See [CONTRIBUTING.md](../CONTRIBUTING.md) for the full guidelines.

---

## What belongs here

Any Claude Code slash command that:
- Works for projects other than your own (generalized, no hardcoded specifics)
- Does one thing clearly
- Has been tested in a real session

---

## What doesn't belong here

- Commands with hardcoded credentials, API keys, or project names
- Commands that are identical to ones already in `.claude/commands/`
- Untested commands

---

## Browse community commands

| Command | What it does | Author |
|---------|-------------|--------|
| [deploy-check](./deploy-check.md) | Pre-deployment verification gate (build, types, secrets, bundle size) | Community |
| [dependency-audit](./dependency-audit.md) | Scan for vulnerabilities, outdated packages, unused deps | Community |

Use `command-template.md` to add your own.
