# Dependency Audit

Scan your project's dependencies for known vulnerabilities, outdated packages, and unused imports.

---

## What it does

Runs `npm audit` (or your package manager's equivalent), checks for outdated packages with `npm outdated`, and optionally scans for imports that are installed but never used. Produces a prioritized report: critical vulnerabilities first, then outdated major versions, then cleanup suggestions.

---

## Token cost

Low

---

## Usage

```
/dependency-audit
```

No arguments. Detects your package manager automatically (npm, yarn, pnpm).

---

## Example output

```
═══════════════════════════════════════
  Dependency Audit
═══════════════════════════════════════

  Vulnerabilities:
    🔴 1 critical — lodash (CVE-2021-23337)
    🟡 3 moderate

  Outdated (major):
    react 18.2.0 → 19.0.0
    next 14.2.0 → 15.1.0

  Unused (installed but not imported):
    - moment (last imported: never)
    - uuid (last imported: never)

  Action: npm audit fix --force (review changes before committing)
═══════════════════════════════════════
```

---

## When to use it

Weekly, or before any major deployment. Good habit for solo developers who don't have Dependabot configured.

---

## Author

Community contribution — adapt the scanning approach for your stack.
