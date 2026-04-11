# UX Lighthouse

> **Preamble:** You are running a UX audit. Use preview tools for evidence — never guess about visual issues. WCAG AA is the floor, not the ceiling. Start with mobile (375px), then expand. Every finding needs a screenshot or DOM inspection to prove it.

Run a comprehensive UX audit using Claude Preview tools.

---

## Phase 1 — Launch Parallel Audits

Launch 3 agents in parallel:

### Accessibility Agent
Using preview_snapshot and preview_inspect:
- Check ARIA labels on interactive elements
- Verify keyboard navigation (tab order, focus indicators)
- Check color contrast ratios (WCAG AA minimum)
- Verify form labels and error messages
- Check image alt text

### Design System Agent
Using preview_snapshot and preview_inspect:
- Verify consistent spacing, typography, colors
- Check component usage matches design system
- Verify semantic color tokens (not hardcoded colors)
- Check button sizes (min 48px touch target)
- Verify consistent border radius and shadows

### Responsive Layout Agent
Using preview_resize and preview_snapshot:
- Test at 375px (mobile), 768px (tablet), 1280px (desktop)
- Check for horizontal overflow
- Verify navigation adapts properly
- Check text readability at each breakpoint
- Verify images scale correctly

---

## Phase 2 — Additional Checks

After parallel audits complete:

1. **Dark mode** — toggle theme, check all components render correctly
2. **Interactions** — preview_click on key buttons/links, verify behavior
3. **Error states** — Check form validation messages display correctly
4. **Empty states** — Verify pages without data show helpful messages
5. **Loading states** — Check skeleton/spinner states exist

---

## Phase 3 — Synthesize

**HUMAN GATE:** Present findings before final report.

Compile findings by severity:
- **CRITICAL** — Accessibility violation, broken layout, unusable on mobile
- **HIGH** — Poor contrast, missing error states, keyboard trap
- **MEDIUM** — Inconsistent design, missing loading states, visual noise
- **LOW** — Polish, minor alignment, cosmetic issues

Include preview_screenshot evidence for every visual finding.

## Rules
- Use preview tools for evidence — don't guess about visual issues
- WCAG AA is the minimum standard
- Test both light and dark mode
- Mobile-first: start at 375px, expand from there
