# Security

The hooks in this repo are shell scripts that run with your user account's permissions. That means they can read files, write files, make network requests, and run commands — anything your shell can do.

This is not a reason to avoid hooks. It's a reason to read them before using them.

---

## Before you copy any hook

Open the script in your editor and read every line. Ask yourself:
- What does this script read?
- What does it write or execute?
- Does it make any network calls?
- Does it have any conditional logic that could behave unexpectedly?

The hooks in this repo are intentionally minimal. Each one does one thing and nothing else. If you're pulling hooks from somewhere else, the same standard applies.

---

## What each hook in this repo does

### `block-dangerous-commands.sh`

Intercepts every Bash tool call before it runs. Checks the command against a blocklist of patterns (things like recursive deletes targeting the filesystem root or home directory). If the command matches a blocked pattern, the hook exits with code 2, which causes Claude Code to abort the tool call.

That's the entire script. It does not log commands, does not send data anywhere, and does not modify any files. It reads the incoming tool call from stdin, checks a grep pattern, and exits.

---

## The permissions config

`starter-kit/.claude/settings.json` includes a `permissions` block that works alongside the hook:

- **deny** — absolute hard blocks (Claude cannot even ask to run these)
- **ask** — Claude must ask for confirmation before running (git push, reading .env files)
- **allow** — pre-approved tool types that don't require per-call confirmation

The deny list includes recursive deletes targeting `/` and `~/`, and reads of private key files and SSH config. Adjust this for your own threat model, but err toward more restrictive on deny and ask.

---

## What hooks cannot protect against

Hooks run on Claude Code tool calls. They do not protect against:
- Code that Claude writes to disk that you then run manually
- Packages installed from npm/pip/etc. that contain malicious code
- Commands run outside of Claude Code (directly in your terminal)

Hooks are a guardrail for Claude's automated actions, not a general security boundary.

---

## Verifying a hook script

Before registering any hook, verify it does what it claims:

```bash
# Read the script
cat .claude/hooks/block-dangerous-commands.sh

# Check what it imports or sources
grep -E "^source|^\.|^import" .claude/hooks/block-dangerous-commands.sh

# Verify it makes no network calls
grep -E "curl|wget|fetch|nc |ncat" .claude/hooks/block-dangerous-commands.sh

# Check for any file writes
grep -E ">" .claude/hooks/block-dangerous-commands.sh
```

If any of those checks return unexpected results, do not use the hook until you understand why.

---

## Claude Code's hook documentation

Claude Code's official hook documentation covers the full event model (PreToolUse, PostToolUse, Notification, Stop), the input/output format, and how exit codes are interpreted:

- Exit 0: proceed normally
- Exit 2: block the tool call (Claude sees the stderr output as the reason)
- Any other non-zero exit: treated as a hook error (different from a tool block)

Read the official docs before writing your own hooks: https://docs.anthropic.com/en/docs/claude-code/hooks

---

## Reporting a security issue

If you find a vulnerability in a hook or script in this repo, open a GitHub issue marked `[security]` or email directly. Do not open a public PR that demonstrates the exploit.
