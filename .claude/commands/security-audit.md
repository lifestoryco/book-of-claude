# Security Fortress

> **Preamble:** You are running a comprehensive security audit. Read CLAUDE.md and all .claude/rules/ files before scanning — project-specific rules define what CRITICAL means for this codebase. Every finding must cite a specific file and line. Do not report false positives — verify before flagging.

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
- Check for missing rate limiting on sensitive endpoints

### Database Policy Auditor (agent: db-architect)
- Review all RLS (Row Level Security) policies
- Verify every table with sensitive data has policies
- Check that policies enforce proper ownership/role checks
- Look for overly permissive policies (`USING (true)` or no filter)
- Verify soft-delete items are excluded from relevant queries
- Check that hidden/draft items are gated appropriately

### Code Vulnerability Scanner (agent: security-reviewer)
- OWASP Top 10 check (injection, XSS, CSRF, etc.)
- Grep for hardcoded secrets, API keys, tokens
- Check for exposed environment variables in client code
- Verify webhook signature verification with timing-safe comparison
- Check for insecure direct object references (IDOR)
- Verify encryption at rest for sensitive data

---

## Phase 2 — Deep Checks

After parallel scans:
1. Verify encryption patterns for sensitive data at rest
2. Check CORS configuration and allowed origins
3. Review CSP headers (ensure production-only for dev compatibility)
4. Check for dependency vulnerabilities: `npm audit` or equivalent
5. Verify CLAUDE.md security rules are followed throughout

---

## Phase 3 — Synthesize

**HUMAN GATE:** Present findings before final output.

### Non-Negotiable Rules Verification

| Rule | Status | Evidence |
|------|--------|----------|
| Auth verified server-side | PASS/FAIL | [details] |
| No secrets in client bundle | PASS/FAIL | [details] |
| RLS on all sensitive tables | PASS/FAIL | [details] |
| Webhook signatures verified | PASS/FAIL | [details] |
| Timing-safe comparisons used | PASS/FAIL | [details] |

### Findings by Severity

**CRITICAL** — Exploitable now (auth bypasses, exposed secrets, injection vectors)
**HIGH** — Significant risk if exploited (missing rate limits, weak policies, IDOR)
**MEDIUM** — Defense-in-depth gaps (missing CSP headers, overly permissive CORS)
**LOW** — Hardening recommendations (dependency updates, informational)

## Rules
- Read CLAUDE.md and .claude/rules/security.md for project-specific security rules
- Every finding must cite file:line
- Don't report false positives — verify before flagging
- Check both server and client code paths
- Flag pre-existing issues separately from new issues
