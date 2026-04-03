# Code Review

Run a multi-agent code review on the current changes.

## Step 1 — Gather Context

Read CLAUDE.md for project rules. Run `git diff` to see what changed. Identify the files and scope of the review.

## Step 2 — Launch Specialist Reviews

Launch 4 agents in parallel using the Agent tool:

### Security Reviewer
- Check for auth bypasses, injection vulnerabilities, exposed secrets
- Verify API routes check authentication
- Look for OWASP top 10 issues

### Performance Reviewer
- Check for N+1 queries, missing indexes
- Look for unnecessary re-renders, large bundle imports
- Verify proper caching and memoization

### Frontend/UX Reviewer
- Accessibility: ARIA labels, keyboard navigation, color contrast
- Responsive: test at mobile/tablet/desktop breakpoints
- Component patterns: proper composition, prop drilling avoidance

### Domain Expert
- Business logic correctness
- Edge cases in data flow
- Error handling completeness

## Step 3 — Synthesize

Merge all findings. Deduplicate. Prioritize:

| Severity | Meaning | Action |
|----------|---------|--------|
| CRITICAL | Security hole, data loss, crash | Must fix before merge |
| MODERATE | Bug, performance issue, accessibility gap | Should fix |
| MINOR | Style, naming, minor improvement | Nice to fix |

## Step 4 — Report

Print the consolidated review:
```
═══════════════════════════════════════════════
  Code Review — [scope description]
═══════════════════════════════════════════════

CRITICAL (X)
  1. [file:line] — description

MODERATE (X)
  1. [file:line] — description

MINOR (X)
  1. [file:line] — description

Score: X/10
═══════════════════════════════════════════════
```

## Rules
- Read CLAUDE.md before reviewing — project rules are non-negotiable
- Cite specific file:line for every finding
- Don't flag style preferences — only real issues
- Respect existing patterns in the codebase
