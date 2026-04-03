# /security-audit

Runs a three-agent security scan across your codebase using OWASP methodology. More thorough than in-line code review security checks; designed for periodic full-codebase assessment.

---

## What It Does

Three security-focused subagents scan the codebase in parallel:

1. **Authentication and authorization agent** — auth bypasses, session management, token handling, RLS policies, role enforcement
2. **Data exposure agent** — secrets in code, unvalidated inputs, injection vulnerabilities, insecure data flows, logging of sensitive data
3. **Infrastructure and configuration agent** — environment variable handling, CORS policies, CSP headers, dependency vulnerabilities, deployment configuration

Each agent produces a prioritized findings list. The primary agent synthesizes them, deduplicates, and formats a report with severity ratings and specific recommendations.

---

## Usage

```
/security-audit
/security-audit --auth-only
/security-audit --deps
```

With no argument, runs the full three-agent scan. With `--auth-only`, runs only the auth/authz agent (fastest, most common use case). With `--deps`, adds a dependency vulnerability check using `npm audit`.

---

## OWASP Methodology

The audit is structured around the OWASP Top 10. Agents check specifically for:

**A01 — Broken Access Control**
- API routes accessible without auth
- Horizontal privilege escalation (user A accessing user B's data)
- Missing role checks on sensitive operations
- RLS policies that have gaps

**A02 — Cryptographic Failures**
- Secrets or tokens in plaintext (in code, in logs, in error messages)
- Weak encryption (MD5, SHA-1 for passwords, HTTP instead of HTTPS)
- Sensitive data in localStorage or cookies without HttpOnly flag

**A03 — Injection**
- SQL injection via string concatenation in queries
- Command injection in shell exec calls
- Unvalidated user input reaching database, filesystem, or shell

**A04 — Insecure Design**
- Missing rate limiting on sensitive endpoints
- No account lockout on login attempts
- Magic links that don't expire
- Predictable resource IDs (sequential integers vs UUIDs)

**A05 — Security Misconfiguration**
- CORS set to `*` in production
- Error messages that expose stack traces to users
- Missing security headers (CSP, HSTS, X-Frame-Options)
- Development configuration reaching production

**A07 — Authentication Failures**
- Session tokens that don't expire
- Missing timing-safe comparison for token validation
- Password reset flows that are vulnerable to enumeration

---

## RLS Policy Verification

For applications using Postgres Row-Level Security, the audit includes an RLS policy review:

- Every table has a policy (no unprotected tables)
- Policies correctly filter by authenticated user
- Policies for public/read-only users are restrictive enough
- Draft or soft-deleted records are excluded from public policies

This is project-specific. The audit reads your `.claude/rules/security.md` (if it exists) to understand what your RLS policies are supposed to enforce, then verifies the actual policies match the intention.

---

## Adding Project-Specific Security Rules

The audit agents load your `.claude/rules/security.md`. Add project-specific rules to make the audit more targeted:

```markdown
# Security Rules

## Authentication
- Session tokens use HMAC-SHA256 with key from SESSION_SECRET env var
- Tokens expire after 24 hours — reject any token older than this
- Guest sessions use a separate sessions table with a 30-day TTL

## Data Access
- Every query against `tasks` must include `WHERE workspace_id = ?` —
  no cross-workspace data access
- The `internal_notes` column must never appear in API responses

## Secrets
- Slack bot tokens stored AES-256-GCM encrypted in `workspace_settings`
- The `SLACK_ENCRYPTION_KEY` env var must never appear in logs
```

The more specific your rules, the more accurately the audit can verify them.

---

## Dependency Vulnerability Check

`/security-audit --deps` runs `npm audit` and categorizes findings:

- **Critical/High:** Block deployment. These are known vulnerabilities with available fixes.
- **Medium:** Schedule for next maintenance cycle. Known vulnerabilities, lower exploitability.
- **Low/Info:** Informational. Track but don't block.

The audit interprets `npm audit` output in the context of your actual usage. A critical vulnerability in a dev-only dependency is less urgent than one in a production runtime dependency. The agent notes this context.

---

## How Often to Run

**Full audit:** Before any major release, after significant feature additions, quarterly at minimum.

**Auth-only (`--auth-only`):** Before launching any new auth-related feature (new role, new auth method, new public endpoint).

**Deps (`--deps`):** Monthly, or when `npm audit` is showing alerts in your CI pipeline.

**Inline code review security:** Every PR via `/code-review`. The security reviewer in `/code-review` covers the diff; `/security-audit` covers the whole codebase.

---

## Output Format

```
CRITICAL — resolve before next deployment
  [findings with file:line, description, specific fix]

HIGH — resolve this sprint
  [findings]

MEDIUM — schedule for next maintenance cycle
  [findings]

LOW / INFORMATIONAL
  [findings]

RLS Policy Summary:
  Tables with policies: X
  Tables missing policies: Y (list)
  Policy gaps found: Z

Dependency audit:
  Critical: X  High: Y  Medium: Z

Overall assessment: [one sentence]
Recommended next action: [one sentence]
```

---

## Token Cost

High. Full-codebase three-agent scan with RLS verification is one of the most token-intensive commands. Reserve for the use cases above. For routine changes, rely on `/code-review`'s security reviewer, which covers the diff at lower cost.
