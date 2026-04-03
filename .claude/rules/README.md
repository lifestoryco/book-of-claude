# Rules

Rules are domain-specific constraints that Claude Code loads into context automatically. They live in `.claude/rules/` as `.md` files and are always available — unlike CLAUDE.md which has a size budget.

## How Rules Work

Every `.md` file in `.claude/rules/` is loaded into Claude's context at the start of each conversation. Use rules for patterns that apply across the entire codebase but are too specific for CLAUDE.md.

## Rules in This Repo

- **security.md** — Universal security rules (secrets, auth, encryption)
- **frontend.md** — React/Next.js patterns (portals, animations, themes)
- **env-config.md** — Environment variable management (worktrees, validation, CSP)

## Adding Your Own Rules

Create a `.md` file in `.claude/rules/` with patterns specific to your project. Good candidates:
- Banned libraries or deprecated patterns
- Naming conventions
- Testing requirements
- API design standards
- Database conventions
