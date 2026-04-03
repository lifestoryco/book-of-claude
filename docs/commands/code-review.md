# /code-review

Runs a multi-agent parallel code review. Four specialist subagents examine the same code simultaneously from different angles and produce independent reports. More thorough than a single-agent review; catches issues that generalist review misses.

---

## What It Does

Spins up four subagents with distinct review mandates:

1. **Security reviewer** — auth bypasses, exposed secrets, injection vulnerabilities, insecure data flows
2. **Logic reviewer** — business logic correctness, edge cases, error handling, data integrity
3. **Architecture reviewer** — coupling, cohesion, adherence to project conventions, tech debt
4. **UX reviewer** — user-facing copy, error messages, loading states, accessibility, mobile behavior

Each reviewer gets read-only access to the changed files and the relevant section of your project's rules. They run simultaneously. The primary agent collects all four reports and formats a consolidated review.

---

## Usage

```
/code-review
/code-review --fix
/code-review path/to/specific/file.ts
```

With no argument, reviews the current git diff (staged + unstaged changes). With a file path, reviews that specific file. With `--fix`, Claude attempts to automatically apply fixes for issues identified as low-risk (style issues, obvious bugs, missing error handling). High-risk fixes are flagged for human review rather than applied automatically.

---

## How It Works

**Step 1:** The primary agent identifies the scope — what changed? It reads the diff or the specified file.

**Step 2:** Four subagents are spun up in parallel. Each receives:
- The changed files (or the diff)
- Their specific review mandate
- The relevant section of `.claude/rules/` (security reviewer gets `security.md`, etc.)
- Explicit instructions about output format

**Step 3:** Each subagent produces a report. Format is consistent across all four:
- Numbered list of findings
- Each finding: file, line, description, severity (critical/high/medium/low), recommendation
- Summary: total findings by severity, overall assessment

**Step 4:** Primary agent synthesizes the four reports into a consolidated review. Duplicate findings are merged. Conflicting assessments are flagged (rare, but it happens when a tradeoff looks good from one angle and bad from another).

**Output structure:**
```
CRITICAL (resolve before merging)
  [findings]

HIGH (resolve soon)
  [findings]

MEDIUM (address in a follow-up task)
  [findings]

LOW (informational / style)
  [findings]

Approved by: Security, Logic, Architecture, UX
Issues requiring attention: [count]
```

---

## The --fix Flag

`--fix` applies automatic fixes for findings where the correct change is unambiguous:
- Missing null checks that have an obvious safe default
- Obvious typos in user-facing copy
- Unused variables and imports
- Missing `await` on async calls
- Hardcoded strings that should reference constants

`--fix` does NOT automatically apply:
- Security fixes (always require human review)
- Logic changes (too high risk of unintended consequences)
- Architecture changes (require broader context)
- Anything that changes public API behavior

After `--fix` runs, it shows you what it changed and asks for confirmation before committing.

---

## Customizing Agent Focus Areas

The default review mandates are general-purpose. For your project, you may want to add project-specific focus areas to each reviewer.

**Technique 1: Add rules to the relevant `.claude/rules/` file.** The code review command loads `rules/security.md` for the security reviewer. If your project has specific security rules (e.g., "all queries against the `tasks` table must include a `workspace_id` filter"), add them to `rules/security.md` and the security reviewer will check for them.

**Technique 2: Add a project-specific reviewer.** If your project has a domain that doesn't fit the four default reviewers (e.g., a payment processing domain with specific compliance requirements), add a fifth reviewer by editing the `/code-review` command. Give it a specific mandate and load the relevant rules.

**Technique 3: Pre-populate the prompt with context.** For a specific review session, you can add context inline:

```
/code-review
Context: This diff implements the guest access feature. Guests must never see tasks with visibility='internal'. Pay particular attention to the RLS policies and API route auth checks.
```

---

## Integration with CLAUDE.md

The code review agents load your project's CLAUDE.md rules. The architecture reviewer specifically checks whether the diff violates any of your non-negotiable rules. This means your investment in writing good CLAUDE.md rules pays back at review time — the reviewer knows what invariants to check.

Example: if your CLAUDE.md says "every task mutation must call `logTaskEvent()`," the logic reviewer will check whether any new task mutation routes include that call.

---

## Token Cost

This is a high-token command. Four agents running in parallel, each with context including the diff and relevant rules, is substantial. For routine small changes, a single-agent review is sufficient. Reserve `/code-review` for:

- Features touching security-critical paths (auth, data access, payments)
- Changes affecting multiple feature areas
- Pre-release reviews
- Any change you'd want a second pair of eyes on in a human code review

For low-stakes changes, ask Claude to review in-session with a specific focus area: "review this for security issues only." That costs a fraction of the full multi-agent review.
