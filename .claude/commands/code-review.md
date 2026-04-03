# Code Review

Run a multi-agent code review on the current changes.

---

## Phase 1 — Context Gathering

1. Read CLAUDE.md for project rules and non-negotiables
2. Run `git diff` (or `git diff HEAD~N` if reviewing multiple commits) to identify changed files
3. Read each changed file in full to understand context
4. Identify the scope: new feature, bug fix, refactor, etc.

---

## Phase 2 — Launch Specialist Reviews

Launch 4 agents in parallel using the Agent tool:

### Security Reviewer (agent: security-reviewer)
- Auth bypasses, injection vulnerabilities, exposed secrets
- API routes missing authentication checks
- OWASP top 10 issues
- Hardcoded credentials or tokens

### Performance Reviewer (agent: backend-engineer)
- N+1 queries, missing database indexes
- Unnecessary re-renders, large bundle imports
- Missing caching, memoization opportunities
- Memory leaks in event listeners or subscriptions

### Frontend/UX Reviewer (agent: frontend-engineer)
- Accessibility: ARIA labels, keyboard navigation, color contrast
- Responsive: mobile/tablet/desktop breakpoints
- Component patterns: composition, prop drilling, state management

### Domain Expert (agent: code-reviewer)
- Business logic correctness per CLAUDE.md rules
- Edge cases in data flow
- Error handling completeness
- Pattern consistency with existing codebase

---

## Phase 3 — Synthesize

Merge all findings. Deduplicate. Prioritize:

| Severity | Meaning | Action |
|----------|---------|--------|
| **CRITICAL** | Security hole, data loss, crash | Must fix before merge |
| **MODERATE** | Bug, performance issue, a11y gap | Should fix |
| **MINOR** | Style, naming, improvement | Nice to fix |

---

## Phase 4 — Auto-Fix (if `--fix` in $ARGUMENTS)

**HUMAN GATE:** Present all CRITICAL and MODERATE findings. Ask: "Fix these automatically?"

If approved:
1. Fix CRITICAL issues first
2. Fix MODERATE issues
3. Run type checker and build after fixes
4. Show diff of changes made

---

## Phase 5 — Report

```
═══════════════════════════════════════════════
  Code Review — [scope]
═══════════════════════════════════════════════

CRITICAL (X)
  1. [file:line] — description — [agent]

MODERATE (X)
  1. [file:line] — description — [agent]

MINOR (X)
  1. [file:line] — description — [agent]

Score: X/10
═══════════════════════════════════════════════
```

## Rules
- Read CLAUDE.md before reviewing — project rules are non-negotiable
- Cite specific file:line for every finding
- Don't flag style preferences — only real issues
- Respect existing patterns in the codebase
