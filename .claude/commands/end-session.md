# END SESSION

Execute in order. No commentary between steps.

---

## Step 1 — Verify + commit all changes

Run your project's type checker (e.g., `npx tsc --noEmit`). If there are NEW errors you introduced, fix them.

Then `git status`. If uncommitted changes exist:
- Stage and commit with appropriate prefix
- Prefixes: `feat:` · `fix:` · `refactor:` · `docs:` · `test:` · `chore:`
- One commit per logical change. Don't batch unrelated work.

---

## Step 2 — Update project state

If `docs/state/project-state.md` exists, update these sections:

**Header:** `_Last updated: YYYY-MM-DD | Session: <name> — <1-line description>_`

**What Was Just Done:** Insert a NEW block above the old one:
```markdown
## What Was Just Done (YYYY-MM-DD — Session: <name>)
### <Task/Feature>
**New files:** `path` — purpose
**Modified:** `path` — what changed
**Commits:** `hash` — message
```

**What's Next:** Re-rank top 5. Remove completed items.

Commit: `docs: update session state for <name>`

---

## Step 3 — Run the end script

```bash
bash scripts/end.sh "$PWD"
```

The script validates clean tree, summarizes commits, rebases onto origin/main, pushes, and handles cleanup.

If it fails, report the exact error. Do not attempt manual workarounds.

---

## Step 4 — Final report

```
═══════════════════════════════════════════════
  Session Complete: <name>
  Commits: <n>  |  Main: <hash>  |  Pushed: ✅
═══════════════════════════════════════════════

What was done:
• bullet 1
• bullet 2

What's next:
1. Top priority
2. Second
3. Third
```

## Rules
- Do NOT skip the state file update if it exists
- Do NOT use `--force` push
- If `end.sh` fails, report the error — don't work around it
