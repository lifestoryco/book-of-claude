#!/bin/bash
# PreToolUse hook: Block dangerous Bash commands
# Blocks: rm -rf /, force-push main, DROP TABLE, --no-verify, hard reset main
INPUT=$(cat)
COMMAND=$(echo "$INPUT" | jq -r '.tool_input.command // empty')
COMMAND_LOWER=$(echo "$COMMAND" | tr '[:upper:]' '[:lower:]')

if [[ "$COMMAND" == *"rm -rf /"* ]] || [[ "$COMMAND" == *"rm -rf ~"* ]]; then
  echo "BLOCKED: Destructive filesystem command." >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'git push.*(--force|-f).*(main|master)'; then
  echo "BLOCKED: Force push to main/master." >&2; exit 2
fi
if echo "$COMMAND_LOWER" | grep -qE 'drop (table|database|schema)'; then
  echo "BLOCKED: DROP TABLE/DATABASE/SCHEMA." >&2; exit 2
fi
if echo "$COMMAND" | grep -q "\-\-no-verify"; then
  echo "BLOCKED: --no-verify bypasses git hooks." >&2; exit 2
fi
if echo "$COMMAND" | grep -qE 'git reset --hard.*(main|master|origin)'; then
  echo "BLOCKED: git reset --hard to main/origin." >&2; exit 2
fi
exit 0
