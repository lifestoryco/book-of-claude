# Hooks

Claude Code hooks are shell scripts that run automatically before or after tool calls. They're the **enforcement layer** — while CLAUDE.md is advisory (~80% compliance), hooks are deterministic (100%).

## How Hooks Work

| Event | When it runs | Exit code 0 | Exit code 2 |
|-------|-------------|-------------|-------------|
| **PreToolUse** | Before a tool executes | Allow | **Block** the tool call |
| **PostToolUse** | After a tool executes | Pass | N/A (informational only) |

Hooks receive JSON on stdin with the tool name and input parameters. They can read the input, check for patterns, and decide whether to allow or block.

## Hooks in This Repo

### `block-dangerous-commands.sh` (PreToolUse → Bash)
Blocks destructive commands before they execute:
- `rm -rf /` or `rm -rf ~/` — catastrophic filesystem deletion
- `git push --force` to main/master — overwrites shared history
- `DROP TABLE/DATABASE/SCHEMA` — irreversible data loss
- `--no-verify` — bypasses git hooks (defeats the point)
- `git reset --hard` to main/origin — discards uncommitted work

### `block-banned-patterns.sh` (PreToolUse → Write/Edit)
Reads from `.claude/banned-patterns.txt` and blocks any write containing a banned pattern. Use this to enforce architectural decisions:

```
# .claude/banned-patterns.txt
# One pattern per line. Lines starting with # are comments.
some-deprecated-import
dangerousFunction()
```

### `auto-typecheck.sh` (PostToolUse → Write/Edit)
Runs your type checker after every code edit. Detects your stack automatically:
- **TypeScript** → `npx tsc --noEmit`
- **Python** → `mypy` or `pyright`
- **Rust** → `cargo check`
- **Go** → `go vet`

Errors appear as context for Claude — they don't block the edit, but Claude sees them and can fix issues immediately.

### `surface-learnings.sh` (PreToolUse → Write/Edit) — Optional
Surfaces relevant past learnings before Claude edits a file. Reads a `learnings.jsonl` index and shows matching entries (by filename and directory) as context before the edit starts.

This prevents Claude from repeating mistakes that were discovered and documented in previous sessions.

**Setup:** Create `.claude/learnings.jsonl` in your project with entries in this format:
```json
{ "title": "Gotcha name", "content": "What to watch out for and why", "file": "affected-file.ts" }
```

You can build this file manually or with a sync script that extracts entries from your project's memory/notes system.

**To enable:** Add to `settings.json`:
```json
{
  "hooks": {
    "PreToolUse": [
      {
        "matcher": "Write|Edit",
        "hooks": [{ "type": "command", "command": "\"$CLAUDE_PROJECT_DIR\"/.claude/hooks/surface-learnings.sh" }]
      }
    ]
  }
}
```

## Security

**Read every hook script before copying into your project.** Hooks run with your shell permissions. See [SECURITY.md](../../SECURITY.md) for the full threat model.

## Adding Your Own Hooks

1. Write a shell script that reads JSON from stdin
2. Use `jq` to extract what you need
3. Exit 0 to allow, exit 2 to block (PreToolUse only)
4. Register in `.claude/settings.json` under the appropriate event

```bash
#!/bin/bash
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
# Your logic here
exit 0
```
