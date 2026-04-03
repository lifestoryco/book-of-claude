# Hooks and Agents

Two mechanisms for making Claude's behavior programmable rather than probabilistic. Hooks intercept tool calls at the shell level. Agents run as subprocesses with specialized context and restricted tool access. Both are powerful; both require care.

---

## Hooks

### What they are

Shell scripts that Claude Code calls before or after specific tool operations. Claude Code has no ability to suppress or modify this behavior once hooks are registered in `.claude/settings.json`. When a hook exits with code 2, the tool call is blocked. When it exits with 0, the tool call proceeds.

### How they work technically

Claude Code passes tool call information to hooks via stdin as a JSON object. The structure varies by tool type:

```json
{
  "tool_name": "Bash",
  "tool_input": {
    "command": "rm -rf ./tmp"
  }
}
```

Your hook reads this from stdin, inspects it, and exits with the appropriate code:
- Exit 0 → allow the tool call
- Exit 2 → block the tool call (Claude sees a rejection message)
- Any output to stdout becomes part of the rejection message Claude sees

A minimal blocking hook:

```bash
#!/bin/bash
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

# Block any command that touches the production database directly
if echo "$command" | grep -q "prod-db"; then
  echo "Blocked: direct production database access is not allowed"
  exit 2
fi

exit 0
```

### Hook types

**PreToolUse** — runs before the tool call, can block it. Use for:
- Blocking dangerous shell commands
- Preventing commits of secret-containing files
- Requiring confirmation before destructive operations

**PostToolUse** — runs after the tool call, cannot block it (it already happened). Use for:
- Logging what Claude did
- Triggering follow-up actions (e.g., running tests after a file is written)
- Auditing

### Registering hooks

Hooks are registered in `.claude/settings.json`:

```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Bash",
        "hooks": [
          {
            "type": "command",
            "command": "bash .claude/hooks/block-dangerous-commands.sh"
          }
        ]
      }
    ]
  }
}
```

The `matcher` field controls which tool calls trigger the hook. `"Bash"` matches all Bash calls. You can also match specific tools like `"Write"` or `"Edit"` if you want to inspect file write operations.

### Writing your own hooks

**The blocklist pattern.** Most useful hook type. Define a list of patterns that should never be executed, check the incoming command against them, block if there's a match.

```bash
#!/bin/bash
input=$(cat)
command=$(echo "$input" | jq -r '.tool_input.command // ""')

BLOCKED_PATTERNS=(
  "rm -rf /"
  "DROP TABLE"
  "DROP DATABASE"
  "chmod 777"
  "> /dev/sda"
)

for pattern in "${BLOCKED_PATTERNS[@]}"; do
  if echo "$command" | grep -qi "$pattern"; then
    echo "Blocked command matching pattern: $pattern"
    exit 2
  fi
done

exit 0
```

**The post-write type-check pattern.** After Claude writes a TypeScript file, automatically run the type checker:

```bash
#!/bin/bash
input=$(cat)
file_path=$(echo "$input" | jq -r '.tool_input.file_path // ""')

if [[ "$file_path" == *.ts || "$file_path" == *.tsx ]]; then
  result=$(npx tsc --noEmit 2>&1)
  if [ $? -ne 0 ]; then
    echo "TypeScript errors detected after writing $file_path:"
    echo "$result"
    # Note: PostToolUse can't block, but the output goes to Claude's context
  fi
fi

exit 0
```

### Security considerations

Hooks run with the same permissions as your shell session. This is both the source of their power and the reason to be careful:

- Read every hook script before deploying it. All of it.
- Hooks from external sources carry the same risk as any shell script you download and run.
- A buggy hook that blocks legitimate operations will frustrate you and break your workflow. Test on low-stakes operations first.
- Never put credentials or secrets in hook scripts.
- Keep hooks simple. One responsibility per script.

The most common mistake is a hook that does too much — tries to be smart about context, makes external API calls, or maintains state. Hooks should be dumb and fast. Inspect the command, make a binary decision, exit.

---

## Agents

### What they are

Subagent Claude instances spun up by the primary Claude session to work on specialized tasks in parallel. The primary agent coordinates; the subagents execute. Each subagent gets its own system prompt, context, tool access restrictions, and model selection.

### How they work

Claude Code's `Task` tool spins up a subagent. The primary agent provides:
- A system prompt defining the subagent's role and constraints
- A task description
- Optional tool restrictions (e.g., read-only access)
- Optional model selection (faster/cheaper models for simpler tasks)

The subagent runs, produces output, and returns it to the primary agent. Multiple subagents can run in parallel.

```
Primary agent
├── Subagent A (security review) → read-only access to codebase
├── Subagent B (logic review) → read-only access to codebase
├── Subagent C (UX review) → read-only access to codebase
└── Subagent D (architecture review) → read-only access to codebase
```

This is the pattern behind `/code-review` — four specialists look at the same code simultaneously and produce independent reports. The primary agent synthesizes them.

### Subagent design principles

**Narrow the context.** Give each subagent only what it needs. A security reviewer doesn't need the full project history — it needs the changed files and the security rules. A logic reviewer doesn't need the design system docs. Narrow context produces sharper output.

**Restrict the tools.** A review agent that can only read files cannot accidentally modify them. Tool restrictions are a safety measure, not a performance optimization. Use them aggressively for review-type agents. Only give write access when the agent's job requires it.

**Give it a mandate, not just a role.** "You are a security reviewer" is a role. "You are a security reviewer whose job is to find authentication bypasses, exposed secrets, and unvalidated user inputs. You are looking for bugs, not style issues. Report every finding, even minor ones." is a mandate. The mandate produces actionable output.

**Model selection matters.** Not every subagent needs the most capable model. A subagent that counts lines of code or formats a report can use a faster, cheaper model. Reserve the high-capability model for subagents that need to reason about complex tradeoffs.

### The parallel review pattern

The most practical application of agents. Instead of asking one Claude instance to review code across multiple dimensions (which produces a diluted review across all dimensions), spin up one specialized reviewer per dimension and run them in parallel.

The dimensions depend on your project. Common ones:
- Security: auth, data access, secrets, injection vulnerabilities
- Logic: business logic correctness, edge cases, error handling
- Architecture: coupling, cohesion, adherence to project conventions
- UX: user-facing copy, error messages, loading states, accessibility

Each reviewer gets:
1. The diff or the changed files
2. The relevant section of CLAUDE.md and rules files (security reviewer gets `rules/security.md`, etc.)
3. A specific mandate stating what to look for
4. Read-only tool access

The primary agent collects all four reports and formats a consolidated review.

### The advisory board pattern

The alpha-squad command uses agents differently: multiple personas arguing different sides of a decision. Each persona is a subagent with a specific mandate that creates natural disagreement with the other personas.

The key is that the personas run sequentially, not in parallel, and each one can see what the previous ones argued. This produces genuine debate rather than independent opinions that happen to be aggregated. The CTO reads the product strategist's argument before making the technical counterargument.

### Writing effective subagent prompts

The subagent system prompt is the most important thing to get right. It determines the quality of output more than any other factor.

**Be explicit about what "good output" looks like.** Don't say "review the code." Say "produce a numbered list of findings. Each finding must include: the file and line number, a description of the issue, the severity (critical/high/medium/low), and a specific recommendation for how to fix it."

**Define scope explicitly.** "Do not comment on code style, formatting, or naming conventions. Focus only on correctness and security." Without this, reviewers pad their output with low-signal observations.

**Give it the right context, not all context.** Load only the files and rule docs relevant to the subagent's domain. A subagent with a 50K-token context window that's 40K tokens of irrelevant background material is less effective than one with 10K tokens of precisely relevant material.

**Tell it to be direct.** "Do not soften findings. If you find a security bug, say it plainly." Claude's default tendency toward diplomatic framing reduces the signal quality of review output. Subagents with explicit mandates to be direct produce more useful findings.

### Where agents break down

Coordination overhead. Running five subagents in parallel produces five independent reports that the primary agent has to synthesize. If the synthesis is shallow, you lose the benefit of specialization. Write the synthesis instructions carefully — what should the final output include? How should conflicts between reviewers be handled?

Model cost. Parallel subagents multiply token usage. A four-agent code review uses roughly 4x the tokens of a single-agent review. For routine changes, this may not be worth it. For pre-release reviews or changes to security-critical paths, it is. Match the tool to the stakes.
