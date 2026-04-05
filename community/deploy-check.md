# Deploy Check

Pre-deployment verification gate. Runs build, type check, and checks for common deployment mistakes.

---

## What it does

Runs your project's build pipeline and checks for issues that commonly break deployments: missing environment variables, TypeScript errors, unresolved merge conflicts, debug code left in production paths, and oversized bundles. Produces a pass/fail report.

---

## Token cost

Med

---

## Usage

```
/deploy-check
```

No arguments. Runs against the current working directory.

---

## Example output

```
═══════════════════════════════════════
  Deploy Check
═══════════════════════════════════════

  ✅ TypeScript — 0 errors
  ✅ Build — clean
  ✅ No merge conflict markers
  ⚠️  console.log found in 2 files:
     - src/api/users.ts:47
     - src/lib/auth.ts:12
  ✅ No .env files staged
  ✅ Bundle size: 245KB (under 500KB limit)

  Result: PASS (1 warning)
═══════════════════════════════════════
```

---

## When to use it

Before pushing to production or merging a feature branch. Catches the things CI should catch but doesn't always.

---

## When NOT to use it

On every small commit during development — save it for pre-merge and pre-deploy moments.

---

## Author

Community contribution — adapt for your own build pipeline.
