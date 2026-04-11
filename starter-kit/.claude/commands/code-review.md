---
description: Multi-agent parallel code review. Four specialist subagents examine code simultaneously. Use for any change touching auth, data access, or multiple feature areas.
---

# /code-review

Runs a 4-agent parallel code review. Specialists examine code simultaneously.

---

## Phase 1 — Context Gathering

1. Read CLAUDE.md for project rules and non-negotiables
2. Run `git diff` (or `git diff HEAD~N` for multiple commits) to identify changed files
3. Read each changed file in full to understand context
4. Identify the scope: new feature, bug fix, refactor, etc.

---

## Phase 2 — Launch Specialist Reviews

Launch 4 agents in parallel using the Agent tool:

### Security Reviewer (agent: security-reviewer)
- Auth bypasses, injection vulnerabilities, exposed secrets
- API routes missing authentication checks
- OWASP top 10 issues, hardcoded credentials
- Project-specific security rules from CLAUDE.md

### Architecture Reviewer (agent: code-reviewer)
- N+1 queries, memory leaks, missing indexes
- DRY violations, unused imports, dead code
- Pattern consistency with existing codebase
- Type safety and naming conventions

### Frontend/UX Reviewer (agent: frontend-engineer)
- Accessibility: ARIA labels, keyboard navigation, color contrast (WCAG AA)
- Responsive: mobile/tablet/desktop breakpoints
- Component patterns, missing loading/error states
- Design system compliance per CLAUDE.md

### Domain Expert (agent: code-reviewer)
- Business logic correctness per CLAUDE.md rules
- Edge cases in data flow
- Error handling completeness
- Regression risk

---

## Phase 3 — Synthesize

Merge all findings. Deduplicate. Prioritize:

| Severity | Meaning | Action |
|----------|---------|--------|
| **CRITICAL** | Security hole, data loss, crash | Must fix before merge |
| **HIGH** | Significant bug or accessibility gap | Should fix soon |
| **MEDIUM** | Performance issue, pattern violation | Fix in follow-up |
| **LOW** | Style, naming, minor improvement | Nice to fix |

Verdict: **PASS** (0 CRITICAL, 0 HIGH) | **NEEDS ATTENTION** (1+ HIGH) | **NEEDS WORK** (1+ CRITICAL)

---

## Phase 4 — Auto-Fix (if `--fix` in $ARGUMENTS)

**HUMAN GATE:** Present all CRITICAL and HIGH findings. Ask: "Fix these automatically?"

If approved:
1. Fix CRITICAL issues first, then HIGH
2. Run type checker after fixes
3. Show diff of changes made

---

## Phase 5 — Report

```
═══════════════════════════════════════════════
  Code Review — [scope] | Verdict: [PASS/NEEDS ATTENTION/NEEDS WORK]
═══════════════════════════════════════════════

CRITICAL (X)
  1. [file:line] — description — impact — fix

HIGH (X)
  1. [file:line] — description

MEDIUM (X) / LOW (X)
  ...

Score: X/10
═══════════════════════════════════════════════
```

## Rules
- Read CLAUDE.md before reviewing — project rules are LAW, violations = CRITICAL
- Cite specific file:line for every finding
- Every finding needs a concrete fix — not just "this is bad"
- Don't flag style preferences — only real issues
