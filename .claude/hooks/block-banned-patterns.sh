#!/bin/bash
# PreToolUse hook: Block banned import patterns
# Configure by adding patterns to .claude/banned-patterns.txt (one per line)
# Lines starting with # are comments. Empty lines are skipped.
INPUT=$(cat)
TOOL_NAME=$(echo "$INPUT" | jq -r '.tool_name // empty')

if [ "$TOOL_NAME" = "Write" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.content // empty')
elif [ "$TOOL_NAME" = "Edit" ]; then
  CONTENT=$(echo "$INPUT" | jq -r '.tool_input.new_string // empty')
else
  exit 0
fi

PATTERNS_FILE="$CLAUDE_PROJECT_DIR/.claude/banned-patterns.txt"
[ ! -f "$PATTERNS_FILE" ] && exit 0

while IFS= read -r pattern; do
  [ -z "$pattern" ] && continue
  [[ "$pattern" == \#* ]] && continue
  if echo "$CONTENT" | grep -q "$pattern"; then
    if echo "$CONTENT" | grep -q "BANNED.*$pattern\|// .*$pattern"; then
      continue
    fi
    echo "BLOCKED: '$pattern' is in your banned patterns list (.claude/banned-patterns.txt)" >&2
    exit 2
  fi
done < "$PATTERNS_FILE"

exit 0
