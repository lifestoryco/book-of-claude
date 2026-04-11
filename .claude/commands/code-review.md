---
description: Multi-agent parallel code review. Four specialist subagents (Security, Logic, Architecture, UX) examine the same code simultaneously and produce independent reports. Use for any change touching auth, data access, or multiple feature areas.
---

# /code-review

Runs a 4-agent parallel code review. Specialists examine code simultaneously; more thorough than single-agent review.

---

## PHASE 1: SCOPE DISCOVERY

**Target:** `$ARGUMENTS`

1. **Determine scope.** If `$ARGUMENTS` is empty or `--fix`, review ALL uncommitted changes:
   ```bash
   git diff --stat && git diff --cached --stat && git status -s
   ```
   If `$ARGUMENTS` contains file paths, scope to those files only.

2. **Capture the full diff.** Run `git diff` and `git diff --cached`. For specific files, read them in full.

3. **Load project rules.** Read `CLAUDE.md` and all files in `.claude/rules/`. These rules are LAW — violations are automatically CRITICAL.

Print scope summary:
```
================================================================
  REVIEW SCOPE
  Files:    [N] changed
  Domains:  [frontend | backend | DB | auth | ...]
  Mode:     [report-only | report + auto-fix]
================================================================
```

---

## PHASE 2: PARALLEL REVIEW — 4 AGENTS SIMULTANEOUSLY

Launch all four subagents in parallel via the Agent tool.

### Agent 1 — Security Reviewer

```
subagent_type: security-reviewer
prompt: |
  Paranoid security audit. Assume every input is malicious.

  PROJECT RULES: Read CLAUDE.md and .claude/rules/security.md — any violation is CRITICAL.

  DIFF / FILES: [paste full diff]

  SCAN FOR: auth bypasses, injection vulnerabilities, exposed secrets,
  missing authentication on routes, OWASP top 10 issues, RLS policy gaps,
  race conditions, CSRF/SSRF, insecure data flows, hardcoded credentials,
  timing-unsafe comparisons, unverified webhook signatures.

  OUTPUT (strict JSON):
  { "findings": [{ "severity": "CRITICAL|HIGH|MEDIUM|LOW", "file": "...",
    "line": 0, "title": "...", "why": "...", "fix": "...",
    "preExisting": false, "effort": "LOW|MED|HIGH" }],
    "positives": [] }
```

### Agent 2 — Logic Reviewer

```
subagent_type: code-reviewer
prompt: |
  Domain expert reviewing for correctness and business logic integrity.

  PROJECT RULES: Read CLAUDE.md and all .claude/rules/ files — violations are CRITICAL.

  DIFF / FILES: [paste full diff]

  SCAN FOR: business logic errors, missing error handling, incomplete
  implementations, off-by-one errors, null/undefined edge cases,
  data integrity issues, actor permission violations, regression risk,
  incorrect state transitions, missing audit logging for mutations.

  OUTPUT: same strict JSON format as Security Reviewer.
```

### Agent 3 — Architecture Reviewer

```
subagent_type: code-reviewer
prompt: |
  Senior performance engineer and software architect.

  PROJECT RULES: Read CLAUDE.md — any type safety or pattern violations are HIGH.

  DIFF / FILES: [paste full diff]

  SCAN FOR: memory leaks, N+1 queries, missing indexes, DRY violations,
  naming convention violations, unused imports, dead code, unnecessary
  re-renders, bundle size impact, stale closures in async callbacks,
  module-level singletons reading env at import time, deduplication
  pitfalls (silent drops on repeated job IDs, etc.), pattern deviations
  from existing code in the same directory.

  OUTPUT: same strict JSON format as Security Reviewer.
```

### Agent 4 — UX Reviewer

```
subagent_type: frontend-engineer
prompt: |
  Senior frontend engineer and accessibility expert.
  Only review frontend files (.tsx, .css, components/, app/, pages/).
  If no frontend files changed, return: { "findings": [], "positives": ["No frontend files in changeset."] }

  PROJECT RULES: Read CLAUDE.md and .claude/rules/frontend.md.

  DIFF / FILES: [paste full diff]

  SCAN FOR: WCAG AA contrast violations, missing ARIA labels, keyboard
  navigation gaps, responsive layout issues, SSR hydration mismatches,
  design system violations (hardcoded colors, wrong component patterns),
  missing loading/error states, animation pitfalls, fixed overlay
  stacking context issues (backdrop-filter parents), raw img tags
  instead of framework image components.

  OUTPUT: same strict JSON format as Security Reviewer.
```

---

## PHASE 3: SYNTHESIS & REPORT

1. Parse each agent's JSON. Extract findings manually if prose was returned.
2. Deduplicate — same file + line + issue = merge, keep highest severity.
3. Filter false positives that contradict explicit project rules.
4. Sort: CRITICAL → HIGH → MEDIUM → LOW. Within tier, sort by effort (LOW first).
5. Verdict: **PASS** (0 CRITICAL, 0 HIGH) | **NEEDS ATTENTION** (0 CRITICAL, 1+ HIGH) | **NEEDS WORK** (1+ CRITICAL)

```
================================================================
  CODE REVIEW — [N] files | [M] findings
  Verdict: [PASS | NEEDS ATTENTION | NEEDS WORK]
================================================================

WHAT'S GOOD
  [merged positives, deduplicated]

CRITICAL (resolve before merging)
  [file:line] Title
  Impact: [why]
  Fix: [code]
  Effort: LOW|MED|HIGH  Pre-existing: yes|no

HIGH (resolve soon)
  [same format]

MEDIUM (address in follow-up)
  [same format]

LOW (informational / style)
  [same format]

PRE-EXISTING ([count])
  [preExisting: true items, listed separately]

Approved by: Security, Logic, Architecture, UX
Issues requiring attention: [CRITICAL + HIGH count]
```

---

## PHASE 4: AUTO-FIX

**Only runs if `$ARGUMENTS` contains `--fix`.**

Fix order: CRITICAL → HIGH. Skip MEDIUM, LOW, and PRE-EXISTING.

For each fix: read file → Edit tool → verify no downstream breakage.
No `// TODO` or placeholder comments — write the actual implementation.

`--fix` does NOT apply security fixes, public API changes, or architecture refactors without explicit confirmation.

If `--fix` is absent:
```
Tip: Run /code-review --fix to auto-remediate CRITICAL and HIGH issues.
```

---

## PHASE 5: QUALITY GATE

Run the project's type checker:
```bash
npx tsc --noEmit   # TypeScript projects
# or: mypy .       # Python
# or: cargo check  # Rust
# or: go vet ./... # Go
```

If `--fix` was applied and errors appear, fix your own mistakes (up to 3 cycles).

```
================================================================
  QUALITY GATE: [PASS | FAIL]
  Type check: [0 errors | N errors]
================================================================
```

---

## Rules

- Do NOT sugarcoat bad code. Be direct and specific.
- Every finding MUST include a concrete fix (code, not advice).
- Every finding MUST explain WHY it matters (impact, not just "bad practice").
- CLAUDE.md rules are LAW — violations are always CRITICAL.
- Pre-existing issues are flagged but kept separate from new issues.
- Review is read-only by default. Only `--fix` enables writes.
- If nothing changed and no files specified: "Nothing to review." and stop.
