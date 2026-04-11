# QA Report — Consolidated Bug Report Generator

> **Preamble:** You are generating a bug report for stakeholders. Be accurate about severity — P0 means genuinely blocks launch, not "I noticed this." Every bug needs reproduction steps. The launch readiness verdict must be honest.

Consolidate all QA findings into a prioritized bug report.

---

## Step 1 — Gather findings

Search for QA artifacts:
- `docs/qa/` — any existing reports or notes
- Recent git commits with `fix:` or `bug` in messages
- Open issues or TODOs in the codebase

---

## Step 2 — Categorize by severity

| Severity | Criteria |
|----------|----------|
| **P0** | Blocks launch. Data loss, security hole, complete feature failure |
| **P1** | Must fix soon. Broken flow, bad UX, incorrect data display |
| **P2** | Nice to fix. Visual glitch, minor edge case, polish |

---

## Step 3 — Generate report

Save to `docs/qa/bug-report-{YYYY-MM-DD}.md`:

```markdown
# QA Bug Report — {date}

## Scorecard
- P0 (Critical): X
- P1 (Major): X
- P2 (Minor): X
- Total: X

## Launch Readiness
[GO / NO-GO / CONDITIONAL based on P0 count]

## P0 — Critical
### BUG-001: [Title]
**Steps to reproduce:** ...
**Expected:** ...
**Actual:** ...
**File:** [path:line]

## P1 — Major
...

## P2 — Minor
...

## Recommendations
1. [Prioritized action items]
```

## Rules
- Every bug needs steps to reproduce
- P0 bugs must include the affected file and line if possible
- Don't inflate severity — P0 means genuinely blocks launch
