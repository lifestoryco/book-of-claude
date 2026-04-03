# Agents

Claude Code agents are specialized AI personas that handle specific types of work. When Claude delegates to a subagent, that agent gets its own context window, model selection, and tool access — keeping the main conversation focused.

## How Agents Work

Agents are defined as `.md` files in `.claude/agents/`. Each has YAML frontmatter specifying the model, tools, and description. Claude Code automatically discovers them and can delegate work via the Agent tool with `subagent_type`.

## Agents in This Repo

| Agent | Model | Tools | Best For |
|-------|-------|-------|----------|
| `backend-engineer` | sonnet | Read, Grep, Glob, Bash, Edit, Write | API routes, server actions, workers, auth |
| `frontend-engineer` | sonnet | Read, Grep, Glob, Edit, Write, Bash | React components, Tailwind, animations |
| `db-architect` | sonnet | Read, Grep, Glob, Bash, Edit, Write | Schema design, RLS, migrations, indexes |
| `code-reviewer` | haiku | Read, Grep, Glob | Post-implementation quality review |
| `security-reviewer` | sonnet | Read, Grep, Glob | Auth audit, secret detection, OWASP |
| `qa-tester` | sonnet | Read, Grep, Glob, Bash | E2E testing, edge cases, regression |
| `devops-engineer` | sonnet | Read, Grep, Glob, Bash, Edit, Write | Deployment, CI/CD, env vars, infra |

## Model Selection

- **sonnet** — Fast, capable, good for most implementation work
- **haiku** — Fastest, cheapest. Great for review tasks that don't need to write code
- **opus** — Most capable. Use for complex architectural decisions (not included by default — add if needed)

## Customizing

Add your own agents by creating new `.md` files. Restrict tools to limit scope — a reviewer that can only Read/Grep/Glob can't accidentally modify code.
