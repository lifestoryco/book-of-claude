# /launch-check

A go/no-go gate for launching or shipping. Runs a structured checklist across build quality, security, integrations, and product completeness. Surfaces blockers before they become post-launch incidents.

---

## What It Does

Runs a series of checks against your application and produces a binary output: ready to ship, or here's what needs to be resolved first.

The check is not a code review — it assumes code quality has been reviewed separately. It's a final gate that checks whether the application is complete, functional, and safe to expose to users.

---

## Usage

```
/launch-check
/launch-check --soft
/launch-check --category build
```

With no argument, runs the full checklist. With `--soft`, runs but doesn't block on medium-severity items (surfaces them as warnings). With `--category`, runs only that category of checks.

---

## Build Checks

These are mechanical. Every item must pass or the launch is blocked.

- [ ] `npx tsc --noEmit` passes with zero errors
- [ ] `npm run build` produces a successful build
- [ ] `npm run lint` passes (or lint errors are explicitly documented as known/acceptable)
- [ ] No `console.log` statements in production code paths
- [ ] No hardcoded development URLs or API endpoints
- [ ] No `TODO` or `FIXME` comments in security-critical code paths
- [ ] Environment variable validation passes (all required vars present)

**How to customize:** Add your project's build and lint commands to the launch check configuration. If you have a test suite, add `npm test` to this section.

---

## Security Checks

These check for common launch-day security gaps.

- [ ] All API routes have auth verification before data access
- [ ] No API keys, tokens, or secrets committed to the repository (checked via `git log --all -S 'SECRET_KEY'` pattern)
- [ ] `npm audit` shows no critical or high severity vulnerabilities in production dependencies
- [ ] HTTPS enforced in production configuration
- [ ] CORS configuration is not set to `*` in production
- [ ] Error messages don't expose stack traces to end users
- [ ] Rate limiting enabled on auth endpoints (login, signup, password reset)
- [ ] Session tokens expire (no infinite sessions)

**How to customize:** Add your project's security invariants from `.claude/rules/security.md`. If your rules say "all queries must include workspace_id filter," add a check for that.

---

## Integration Checks

These verify that external services are configured and operational.

- [ ] Email delivery working (send a test email, verify receipt)
- [ ] Payment processing working (Stripe checkout completes in test mode)
- [ ] File uploads working (upload a test file, verify storage)
- [ ] Webhooks configured and receiving (verify at least one webhook endpoint is receiving)
- [ ] Analytics tracking firing (verify events appearing in PostHog/GA4 dashboard)
- [ ] Error monitoring active (verify Sentry/equivalent is receiving events)
- [ ] Background jobs processing (verify queue workers are running and completing jobs)

**How to customize:** Remove integrations you don't use. Add integrations specific to your product. The integration check is the most project-specific section.

---

## Quality Checks

These are subjective but important. Handled by human review, not automation.

- [ ] Core user journey works end-to-end without errors (manual test)
- [ ] All empty states have appropriate messaging
- [ ] All error states show user-friendly messages (not "Error 500" or stack traces)
- [ ] Loading states exist for all async operations
- [ ] The product works on mobile (test on a real device, not just the browser's mobile emulator)
- [ ] The product works in Safari (if your users are on iOS/Mac)
- [ ] Pricing and billing flows work correctly

---

## Content and Legal Checks

- [ ] Privacy policy published and linked from the application
- [ ] Terms of service published and linked
- [ ] Cookie consent in place (if required for your geography/user base)
- [ ] All user-facing copy reviewed (no placeholder text, no "Lorem Ipsum")
- [ ] Support contact or help mechanism available to users

---

## Customizing the Checklist

The default checklist is a starting point. Three types of customization:

**1. Add project-specific checks.** If your product has a critical feature that must work before launch (e.g., "AI analysis pipeline produces results within 60 seconds"), add it to the checklist. The most important checks are the ones specific to your product.

**2. Remove irrelevant checks.** If you don't have payments, remove the Stripe check. If your target users are all desktop professionals, mobile may not be a launch blocker (though it should still be on the roadmap).

**3. Categorize differently.** Move items between "blocking" and "warning" based on your actual risk tolerance. For a private beta with 10 users, some items that would block a public launch are acceptable to defer.

---

## Output Format

```
GO / NO-GO: [decision]

BLOCKING ISSUES (must resolve before launch)
  [list of failing checks with specific details]

WARNINGS (should resolve, but won't block)
  [list of medium-severity items]

PASSED
  [summary of passing checks — count per category]

Recommendation: [one sentence]
```

If all blocking checks pass, the output is `GO`. If any blocking check fails, the output is `NO-GO` with a specific list of what needs to be resolved.

The no-go output is not a judgment — it's a prioritized action list. Each blocking item should have enough detail that you can go fix it immediately.

---

## Running it Incrementally

You don't have to run the full launch check in one session. Run it category by category:

```
/launch-check --category build
/launch-check --category security
/launch-check --category integrations
```

Each category produces its own go/no-go. Fix the failures. Re-run. The final full `/launch-check` is a confirmation that all categories pass simultaneously.
