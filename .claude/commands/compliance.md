# Compliance Shield

Data privacy and regulatory compliance audit.

---

## Phase 1 — Launch Parallel Audits

### Data Flow Auditor (agent: security-reviewer)
- Map all PII data flows: collection → storage → processing → deletion
- Identify every form that collects user data
- Check data retention policies
- Verify data export/deletion capabilities (right to erasure)
- Check third-party data sharing (analytics, email, payment)

### Regulatory Checklist (agent: backend-engineer)
- **GDPR:** Consent collection, data portability, right to erasure, DPA with processors
- **CCPA:** Do-not-sell mechanism, privacy policy accuracy, data disclosure
- **SOC 2:** Access controls, audit logging, encryption at rest/transit, incident response
- **Cookie/Tracking:** Cookie consent banner, tracking pixel disclosure

---

## Phase 2 — Deep Checks

1. Verify privacy policy matches actual data practices
2. Check cookie/tracking implementations against consent
3. Review data encryption (at rest and in transit)
4. Verify audit logging captures security-relevant events
5. Check user data export functionality

---

## Phase 3 — Compliance Matrix

**HUMAN GATE:** Present findings before final output.

| Requirement | Status | Evidence | Remediation |
|-------------|--------|----------|-------------|
| GDPR: Consent | PASS/PARTIAL/FAIL | [details] | [fix if needed] |
| GDPR: Right to erasure | PASS/PARTIAL/FAIL | ... | ... |
| CCPA: Privacy policy | PASS/PARTIAL/FAIL | ... | ... |
| SOC 2: Access controls | PASS/PARTIAL/FAIL | ... | ... |
| SOC 2: Audit logging | PASS/PARTIAL/FAIL | ... | ... |
| Cookies: Consent | PASS/PARTIAL/FAIL | ... | ... |

## Rules
- Check actual implementation, not just documentation
- Flag PARTIAL when policy exists but implementation is incomplete
- Prioritize FAIL items that could result in regulatory action
