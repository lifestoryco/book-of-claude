# Launch Readiness Checker

Pre-launch quality gate. Run all checks and report go/no-go.

---

## Group 1 — Build Checks (parallel)

```bash
npx tsc --noEmit          # TypeScript compilation
npm run build             # Production build
```

Check environment:
- All required env vars present
- No placeholder values in production config

---

## Group 2 — Code Quality (parallel)

- ESLint: `npx eslint . --max-warnings 0` (or your linter)
- Console.log scan: grep for `console.log` in production code paths
- TODO scan: grep for `TODO` and `FIXME` — flag any blocking ones
- Type coverage: check for `any` types in critical paths

---

## Group 3 — Integration Checks

- **Database:** Connection test, pending migrations check
- **Auth:** Login flow works, protected routes redirect
- **Email:** Template rendering, delivery test (if possible)
- **External APIs:** Health check on critical integrations

---

## Group 4 — Security Quick Check

- No hardcoded secrets in codebase
- HTTPS enforced
- CSP headers configured
- Auth on all sensitive routes

---

## Output

```
═══════════════════════════════════════════════
  Launch Readiness Check
═══════════════════════════════════════════════

  Build          ✅ PASS / ❌ FAIL
  TypeScript     ✅ 0 errors / ❌ N errors
  Lint           ✅ PASS / ⚠️ N warnings
  Console.log    ✅ Clean / ⚠️ N found
  TODOs          ✅ None blocking / ⚠️ N blocking
  Database       ✅ Connected / ❌ Failed
  Auth           ✅ Working / ❌ Broken
  Security       ✅ PASS / ⚠️ N issues

  Verdict:       🟢 GO / 🔴 NO-GO / 🟡 GO WITH WARNINGS
═══════════════════════════════════════════════
```

**HUMAN GATE:** If GO or GO WITH WARNINGS, ask for confirmation before declaring launch-ready.

## Rules
- Run ALL checks — don't skip on first failure
- Be specific about what failed and how to fix it
- Warnings don't block launch, failures do
