#!/bin/bash
# PostToolUse hook: Auto-run type checker after code edits
# Detects stack (TypeScript/Python/Rust/Go) and runs appropriate checker
INPUT=$(cat)
FILE_PATH=$(echo "$INPUT" | jq -r '.tool_input.file_path // empty')

if [[ "$FILE_PATH" == *"node_modules"* ]] || [[ "$FILE_PATH" == *".next"* ]]; then
  exit 0
fi

cd "$CLAUDE_PROJECT_DIR" 2>/dev/null || exit 0

# TypeScript
if [[ "$FILE_PATH" =~ \.(ts|tsx)$ ]] && [ -f "tsconfig.json" ]; then
  TSC_OUTPUT=$(npx tsc --noEmit --pretty false 2>&1 | head -30)
  if [ $? -ne 0 ]; then
    echo "TypeScript errors after editing $FILE_PATH:" >&2
    echo "$TSC_OUTPUT" >&2
  fi
  exit 0
fi

# Python
if [[ "$FILE_PATH" =~ \.py$ ]]; then
  if [ -f "pyproject.toml" ] || [ -f "setup.py" ]; then
    if command -v mypy &>/dev/null; then
      mypy "$FILE_PATH" --no-error-summary 2>&1 | head -20 >&2
    elif command -v pyright &>/dev/null; then
      pyright "$FILE_PATH" 2>&1 | head -20 >&2
    fi
  fi
  exit 0
fi

# Rust
if [[ "$FILE_PATH" =~ \.rs$ ]] && [ -f "Cargo.toml" ]; then
  cargo check --message-format=short 2>&1 | head -20 >&2
  exit 0
fi

# Go
if [[ "$FILE_PATH" =~ \.go$ ]] && [ -f "go.mod" ]; then
  go vet ./... 2>&1 | head -20 >&2
  exit 0
fi

exit 0
