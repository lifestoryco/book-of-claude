#!/bin/bash
# PreToolUse hook: Surface relevant learnings before file edits
#
# Triggers on: Write, Edit (configure via settings.json matcher)
# Reads learnings.jsonl and surfaces entries matching the file being edited
# Output to stderr = Claude sees it as context. Exit 0 = never blocks.
#
# To enable: add a learnings.jsonl file at the path below (project-specific).
# Format: one JSON object per line: { "title": "...", "content": "...", "file": "..." }
# Build this file from your project's MEMORY.md or notes using sync-learnings.sh

LEARNINGS_FILE="$CLAUDE_PROJECT_DIR/.claude/learnings.jsonl"
[ ! -f "$LEARNINGS_FILE" ] && exit 0

INPUT=$(cat)

FILE_PATH=$(printf '%s' "$INPUT" | grep -o '"file_path"[[:space:]]*:[[:space:]]*"[^"]*"' | head -1 | sed 's/.*"file_path"[[:space:]]*:[[:space:]]*"//; s/"$//')
[ -z "$FILE_PATH" ] && exit 0

BASENAME=$(basename "$FILE_PATH" | sed 's/\.[^.]*$//')
DIRNAME=$(dirname "$FILE_PATH" | sed 's|.*/||')

# Build keyword set: basename + individual words + dirname
KEYWORDS=$(printf '%s\n%s\n%s' "$BASENAME" "$DIRNAME" "$(echo "$BASENAME" | tr '-' '\n' | tr '_' '\n')" | sort -u | grep -v '^$' | tr '\n' '|' | sed 's/|$//')

MATCHES=$(grep -iE "$KEYWORDS" "$LEARNINGS_FILE" 2>/dev/null | head -3)
[ -z "$MATCHES" ] && exit 0

echo "" >&2
echo "LEARNINGS relevant to $BASENAME:" >&2
while IFS= read -r line; do
  TITLE=$(printf '%s' "$line" | grep -o '"title":"[^"]*"' | sed 's/"title":"//; s/"$//')
  CONTENT=$(printf '%s' "$line" | grep -o '"content":"[^"]*"' | sed 's/"content":"//; s/"$//' | cut -c1-200)
  [ -n "$TITLE" ] && echo "  $TITLE: $CONTENT" >&2
done <<< "$MATCHES"
echo "" >&2

exit 0
