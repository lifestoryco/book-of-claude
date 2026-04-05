# When to Use What

Claude Code has four mechanisms for shaping behavior: CLAUDE.md rules, hooks, commands, and agents. They overlap. Here's how to pick the right one.

---

## The Quick Decision Table

| I want to... | Use this | Why |
|--------------|----------|-----|
| Ban a dangerous shell command | **Hook** (PreToolUse) | Deterministic. Blocks it every time, regardless of context window state. |
| Enforce an auth pattern | **CLAUDE.md rule** | Advisory but high-signal. Claude reads it at session start. |
| Run a multi-step workflow | **Command** (`/my-command`) | Structured prompt that triggers a repeatable sequence. |
| Get a specialized code review | **Agent** (subagent) | Parallel specialist with narrow context and restricted tools. |
| Prevent committing .env files | **Hook** (PreToolUse on Write) | Mechanical enforcement. Never relies on Claude "remembering." |
| Set project conventions | **Rules file** (`.claude/rules/`) | Domain-specific constraints loaded on demand. |
| Decompose a large feature | **WBS task prompt** | Self-contained instructions with human gates. |
| Make an architecture decision | **Command** (`/alpha-squad`) | Structured debate with multiple perspectives. |

---

## The Four Mechanisms

### CLAUDE.md + Rules Files

**What they are:** Markdown files that Claude reads at session start. CLAUDE.md is the constitution — hard constraints, auth patterns, banned approaches. Rules files (`.claude/rules/*.md`) are domain-specific supplements.

**When to use:** For conventions, patterns, architecture decisions, and anything that shapes behavior across the entire session. "Never use this deprecated function." "Always log mutations to the audit table." "Use this auth pattern, not that one."

**Limitation:** Advisory, not enforced. When Claude's context window is full of task-specific code, rules can get crowded out. Works ~95% of the time.

**Use for:** Conventions, patterns, banned imports, architectural constraints, auth patterns, domain rules.

### Hooks

**What they are:** Shell scripts that run before (PreToolUse) or after (PostToolUse) Claude's tool calls. PreToolUse hooks can block operations. PostToolUse hooks can verify or log.

**When to use:** For the 5% of cases where "usually follows the rule" is not acceptable. Destructive commands, secret exposure, commits of sensitive files. Anything where the consequence of a miss is severe.

**Limitation:** They're shell scripts — keep them simple. A hook that makes API calls or maintains state is a hook that will break in surprising ways. One job per script.

**Use for:** Blocking dangerous commands, preventing secret commits, auto-running type checkers, logging tool usage.

### Commands

**What they are:** Markdown files in `.claude/commands/` that define structured workflows. Invoked with `/command-name` in a Claude Code session.

**When to use:** For repeatable multi-step workflows. Code reviews, session management, status dashboards, task execution. Anything you do more than twice.

**Limitation:** Commands consume context window tokens. A large command (like `/alpha-squad`) can use 15-40% of a session. Use simple commands for routine tasks, reserve complex ones for high-stakes decisions.

**Use for:** Session start/end, code reviews, status boards, task execution, analytics queries, audits.

### Agents

**What they are:** Subagent Claude instances with specialized mandates, restricted tool access, and optionally different models. Run by the primary agent using the Task tool.

**When to use:** For parallel specialized work. Multiple reviewers examining code simultaneously, each from their own angle. Or for tasks where restricted tool access is a safety requirement (read-only reviewers that can't accidentally modify code).

**Limitation:** Each agent uses tokens independently. Four parallel agents = ~4x token cost. Use agents for high-value tasks (pre-release reviews, security audits), not for routine operations.

**Use for:** Parallel code reviews, security audits, specialized implementation tasks, advisory board simulations.

---

## Decision Flowchart

```
Is this a hard safety constraint?
  YES → Hook (PreToolUse)
  NO ↓

Is this a repeatable workflow?
  YES → Command (/.claude/commands/)
  NO ↓

Does it need parallel specialists?
  YES → Agent (subagent)
  NO ↓

Is it a project convention or pattern?
  YES → CLAUDE.md or Rules file
  NO ↓

Is it a one-time task with multiple steps?
  YES → WBS Task Prompt
  NO → Just tell Claude what to do
```

---

## Common Mistakes

**Using CLAUDE.md for things that need hooks.** "Never run `rm -rf /`" in CLAUDE.md is advisory. A hook that blocks it is a hard wall. Use hooks for the things that absolutely cannot slip.

**Using hooks for things that need CLAUDE.md.** "Use React Query for server state" doesn't belong in a hook — it's a convention, not a safety constraint. Put it in CLAUDE.md or a rules file.

**Making every workflow a command.** If you only do something once, just ask Claude to do it. Commands are for repeatable workflows. Don't build infrastructure for one-off tasks.

**Running agents for simple reviews.** A 4-agent parallel review for a one-line bug fix is overkill. Match the tool to the stakes.
