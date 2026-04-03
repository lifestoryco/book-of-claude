# /ux-audit

Runs a three-agent UX and accessibility audit against your application's current state. Uses preview tools to capture screenshots, then analyzes them against your design system and UX standards.

---

## What It Does

Three subagents audit the application simultaneously:

1. **Visual consistency agent** — design system adherence, color usage, spacing, typography, component consistency
2. **Accessibility agent** — WCAG 2.1 AA compliance, contrast ratios, keyboard navigation, screen reader compatibility, focus states
3. **UX flow agent** — user journey clarity, empty states, error states, loading states, copy quality, mobile behavior

Each agent receives screenshots of the current UI plus your design system documentation. They produce independent reports. The primary agent synthesizes them into a prioritized issue list.

---

## Usage

```
/ux-audit
/ux-audit /dashboard
/ux-audit --mobile
```

With no argument, audits the current page (or the main application routes if run from a fresh session). With a path, focuses the audit on that route. With `--mobile`, captures and audits mobile viewport screenshots in addition to desktop.

---

## Preview Tools Integration

The audit uses Claude Code's browser preview tools to capture screenshots. These tools navigate to your local development server and take screenshots for analysis.

**Prerequisites:**
- Local dev server running (`npm run dev`)
- Preview tools enabled in your Claude Code settings

**Screenshot timing:** Browser-based screenshots can miss animations and transitions. If your UI has entrance animations (fade-in, slide-in), the screenshot may capture the start state rather than the final state. Add explicit waits in your audit command configuration, or rely on DOM inspection for animation-dependent analysis.

---

## Customizing Design System Checks

The visual consistency agent checks against your design system. By default, it looks for:
- Color token usage (are you using design tokens or hardcoded hex values?)
- Typography scale adherence
- Spacing consistency
- Component reuse vs. one-off implementations

**To add your design system specifics:** Create or update `.claude/rules/frontend.md` with your design system constraints. The visual consistency agent loads this file. Examples of useful additions:

```markdown
# Design System Rules

## Color tokens
- Primary CTA: use `bg-brand-600` — never use hex #2563EB directly
- Destructive actions: use `text-error-600` — never use red-500 or custom red values
- No purple anywhere in the product UI

## Typography
- H1: only `text-2xl font-semibold` or `text-3xl font-bold` — no other heading sizes
- Body: `text-sm` (14px) is the standard — `text-base` (16px) only for long-form reading

## Button patterns
- Primary: `btn-primary` component — never custom button styles for CTAs
- Destructive: must include a confirmation step — no instant destructive actions
```

The more specific your rules, the more actionable the audit findings.

---

## Responsive Breakpoints

The standard audit covers desktop (1280px) and tablet (768px). The `--mobile` flag adds:
- iPhone-class (390px) viewport
- Android-class (412px) viewport

Common mobile issues the audit catches:
- Touch targets smaller than 44x44px (WCAG minimum)
- Text that overflows its container at small viewports
- Fixed-width elements that don't adapt
- Horizontal scroll introduced by large elements
- Form inputs that trigger unintended zoom on iOS

---

## Accessibility Standards

The accessibility agent checks against WCAG 2.1 AA, which is the standard required for most commercial software:

**Color contrast:**
- Normal text: minimum 4.5:1 ratio against background
- Large text (18pt+ or 14pt+ bold): minimum 3:1 ratio
- UI components and focus indicators: minimum 3:1 against adjacent colors

**Keyboard navigation:**
- All interactive elements reachable via Tab
- Focus indicator visible and high-contrast
- Modal dialogs trap focus correctly (Tab stays within the modal)
- Escape key dismisses modals and menus

**Screen reader:**
- All images have alt text (or `alt=""` for decorative images)
- Form inputs have associated labels
- Dynamic content updates announced via ARIA live regions
- Page structure uses semantic HTML (headings, lists, landmarks)

**Known limitation:** The audit cannot fully simulate a screen reader. It can check for structural correctness (alt text present, labels associated) but cannot verify that the announced text is actually useful. Manual testing with VoiceOver or NVDA is required for a complete accessibility assessment.

---

## Output Format

```
CRITICAL — Accessibility
  [findings that would prevent users from completing core tasks]

HIGH — Visual Consistency
  [design system violations that affect brand perception or user trust]

MEDIUM — UX Flow
  [missing states, confusing copy, unclear actions]

LOW — Polish
  [minor inconsistencies, small improvements]

Design system compliance: X/Y checks passed
Accessibility: X WCAG AA violations found
Recommended next action: [one sentence]
```

---

## Token Cost

Medium-to-high. Three agents plus screenshot processing is substantial. Run full audits:
- Before shipping major UI features
- Before a public launch
- After large design system changes
- Periodically (monthly or quarterly) on the full application

For targeted checks, ask Claude directly: "review this component for accessibility issues" or "check that this screen matches the design system." Single-agent targeted checks cost a fraction of the full audit.
