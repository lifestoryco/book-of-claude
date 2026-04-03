# Security Fortress

Comprehensive security audit of the codebase.

---

## Phase 1 — Launch Parallel Scans

Launch 3 agents in parallel:

### API Auth Scanner (agent: security-reviewer)
- Check every API route for authentication verification
- Verify middleware is applied consistently
- Look for routes that bypass auth checks
- Check for proper role-based access control
- Verify token validation patterns

### Database Policy Auditor (agent: db-architect)
- Review all RLS (Row Level Security) policies
- Verify every table with sensitive data has policies
- Check that policies enforce proper ownership/role checks
- Look for overly permissive policies
- Verify soft-delete items are excluded from public queries

### Code Vulnerability Scanner (agent: security-reviewer)
- OWASP Top 10 check (injection, XSS, CSRF, etc.)
- Grep for hardcoded secrets, API keys, tokens
- Check for exposed environment variables in client code
- Verify webhook signature verification
- Check for timing-safe comparison in auth code

---

## Phase 2 — Deep Checks

After parallel scans:
1. Verify encryption patterns for sensitive data at rest
2. Check CORS configuration
3. Review CSP headers
4. Check for dependency vulnerabilities (`npm audit`)
5. Verify CLAUDE.md security rules are followed

---

## Phase 3 — Synthesize

**HUMAN GATE:** Present findings before final output.

### Non-Negotiable Rules Verification

| Rule | Status | Evidence |
|------|--------|----------|
| Auth verified server-side | PASS/FAIL | [details] |
| No secrets in client bundle | PASS/FAIL | [details] |
| RLS on sensitive tables | PASS/FAIL | [details] |
| Webhook signatures verified | PASS/FAIL | [details] |

### Findings by Severity

**CRITICAL** — Must fix immediately (security holes)
**MODERATE** — Should fix before production (defense gaps)
**MINOR** — Hardening recommendations

## Rules
- Read CLAUDE.md for project-specific security rules
- Every finding must cite file:line
- Don't report false positives — verify before flagging
- Check both server and client code paths
