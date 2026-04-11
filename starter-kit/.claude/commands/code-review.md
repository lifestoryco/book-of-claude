---
description: Multi-agent parallel code review. Four specialist subagents examine code simultaneously. Use for any change touching auth, data access, or multiple feature areas.
---

# /code-review

Run a multi-agent code review on the current changes.

---

## Phase 1 — Context Gathering

1. Read CLAUDE.md for project rules and non-negotiables
2. Run `git diff` to identify changed files
3. Read each changed file in full to understand context

---

## Phase 2 — Launch Specialist Reviews

Launch 4 agents in parallel using the Agent tool:

### Security Reviewer (agent: security-reviewer)
- Auth bypasses, injection vulnerabilities, exposed secrets
- API routes missing authentication checks
- OWASP top 10 issues, hardcoded credentials or tokens
- Violations of CLAUDE.md security rules → always CRITICAL

### Architecture Reviewer (agent: code-reviewer)
- N+1 queries, memory leaks, missing indexes
- DRY violations, unused imports, dead code
- Pattern consistency with existing codebase
- Type safety per CLAUDE.md

### Frontend/UX Reviewer (agent: frontend-engineer)
- Accessibility: ARIA labels, keyboard navigation, WCAG AA contrast
- Responsive breakpoints, missing loading/error states
- Design system compliance per CLAUDE.md
- Skip if no frontend files changed

### Domain Expert (agent: code-reviewer)
- Business logic correctness per CLAUDE.md rules
- Edge cases, null handling, missing error handling
- Regression risk

---

## Phase 3 — Synthesize + Report

| Severity | Meaning | Action |
|----------|---------|--------|
| **CRITICAL** | Security hole, data loss, crash | Must fix before merge |
| **HIGH** | Significant bug, broken flow | Fix soon |
| **MEDIUM** | Performance issue, pattern violation | Follow-up |
| **LOW** | Style, naming, minor improvement | Nice to fix |

Verdict: **PASS** (0 CRITICAL, 0 HIGH) | **NEEDS ATTENTION** (1+ HIGH) | **NEEDS WORK** (1+ CRITICAL)

```
═══════════════════════════════════════════════
  Code Review — [scope] | Verdict: [PASS/...]
═══════════════════════════════════════════════
CRITICAL (X)  1. [file:line] — description — fix
HIGH (X)      1. [file:line] — description — fix
MEDIUM / LOW  ...
PRE-EXISTING  [issues not introduced by this change]
═══════════════════════════════════════════════
```

---

## Phase 4 — Auto-Fix (if `--fix`)

HUMAN GATE → fix CRITICAL + HIGH only → run type checker → show diff.

---

## Phase 5 — Quality Gate

```bash
npx tsc --noEmit  # or your stack's type checker
```

## Rules
- CLAUDE.md rules are non-negotiable — violations = CRITICAL
- Every finding needs a concrete fix, not just a description
- Mark pre-existing issues separately
