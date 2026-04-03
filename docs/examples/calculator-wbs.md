# Example: WBS for a Calculator App

This is a worked example of how the project management system works — from a blank project to a fully built feature using `/wbs`, `/run-task`, `/next`, and `/prompt-builder`.

The project: a simple web calculator with keyboard support and history.

---

## Step 1 — Write the flight plan

Before Claude touches any code, you decompose the feature into tasks. This lives in `docs/flight-plan.md`.

```markdown
# Calculator App — Flight Plan

| ID | Title | Size | Status | Prompt |
|----|-------|------|--------|--------|
| TASK-1.1 | Project scaffold (Next.js + Tailwind) | S | ✅ DONE | — |
| TASK-1.2 | Calculator UI — display + button grid | S | 🔴 TODO | — |
| TASK-1.3 | Core arithmetic logic + state | S | 🔴 TODO | — |
| TASK-1.4 | Keyboard input support | S | 🔴 TODO | — |
| TASK-1.5 | Calculation history panel | M | 🔴 TODO | — |
| TASK-1.6 | Error states (divide by zero, overflow) | S | 🔴 TODO | — |
| TASK-1.7 | Accessibility audit + WCAG AA | S | 🔴 TODO | — |
```

**Size guide:** S = under 2 hours · M = half day · L = full day · XL = multiple days

**Status pipeline:** 🔴 TODO → 🟡 READY (prompt exists) → 🔵 IN PROGRESS → 🟠 NEEDS VERIFICATION → ✅ DONE

---

## Step 2 — Check status with `/wbs`

Run `/wbs` at any time to see the board:

```
═══════════════════════════════════════════════
  Flight Plan Status
═══════════════════════════════════════════════

Phase 1 — Calculator Core
  TASK-1.1  Project scaffold                   ✅ DONE
  TASK-1.2  Calculator UI                       🔴 TODO
  TASK-1.3  Core arithmetic logic               🔴 TODO
  TASK-1.4  Keyboard input                      🔴 TODO
  TASK-1.5  History panel                       🔴 TODO
  TASK-1.6  Error states                        🔴 TODO
  TASK-1.7  Accessibility audit                 🔴 TODO

Summary: 1/7 done · 6 remaining
═══════════════════════════════════════════════
```

---

## Step 3 — Generate a task prompt with `/prompt-builder`

Before running a task, generate a self-contained prompt for it. Run:

```
/prompt-builder TASK-1.2
```

Claude will:
1. Research your codebase (what's already there, what patterns to follow)
2. Show you a research summary and ask for confirmation
3. Assemble a step-by-step execution prompt
4. Save it to `docs/tasks/pending/TASK-1-2_calculator-ui.md`

The saved prompt looks like this:

```markdown
---
id: TASK-1.2
title: Calculator UI — display + button grid
status: pending
---

# TASK-1.2 — Calculator UI

> Context: Load CLAUDE.md + app/page.tsx + components/

## Step 1 — Create the Calculator component

Create `components/Calculator.tsx`:
- Display panel showing current input and result
- Button grid: digits 0-9, operators (+, -, *, /), clear, equals, decimal
- Use Tailwind for layout — CSS Grid for the button grid
- Props interface: { onCalculate: (result: number) => void }

> ✅ Verify: component renders without errors in dev mode

## Step 2 — Wire up to the page

Import Calculator into app/page.tsx. Center it on the page.

> 👁️ Human Gate: Take a screenshot. Confirm the layout looks correct before continuing.

## Step 3 — Verification checklist
- [ ] All 19 buttons render
- [ ] Display shows "0" on initial load
- [ ] Buttons are keyboard-focusable (tab order correct)
- [ ] No TypeScript errors: npx tsc --noEmit
```

---

## Step 4 — Run the task with `/run-task`

Once the prompt exists, execute it:

```
/run-task TASK-1.2
```

Claude reads the prompt and executes every step exactly as written — including pausing at human gates to show you screenshots and wait for your go-ahead.

---

## Step 5 — Update docs with `/update-docs`

After the task completes:

```
/update-docs TASK-1.2
```

This automatically:
- Marks TASK-1.2 as ✅ DONE in `docs/flight-plan.md`
- Moves the prompt from `docs/tasks/pending/` to `docs/tasks/complete/`
- Prepends a session log entry to `docs/state/project-state.md`

---

## Step 6 — Ask what's next with `/next`

```
/next
```

Output:

```
═══════════════════════════════════════════════
  Next Up — 5 Tasks Ready to Run
═══════════════════════════════════════════════

  1. TASK-1.3  Core arithmetic logic + state    🔴 TODO   S
     → /run-task TASK-1.3
     Prompt: docs/tasks/pending/TASK-1-3_...md

  2. TASK-1.4  Keyboard input support           🔴 TODO   S
     Dep: TASK-1.3 (not done yet — build prompt, run after 1.3)

  Blocked: TASK-1.5 (needs TASK-1.3 + TASK-1.4 first)
═══════════════════════════════════════════════
  Pending: 5 | Done: 2/7
═══════════════════════════════════════════════
```

Claude respects dependencies. TASK-1.5 (history panel) requires the core arithmetic logic to exist first, so it's surfaced as blocked — not as something to run now.

---

## The Full Loop

```
/wbs                          → see current status
/prompt-builder TASK-1.3      → generate the execution prompt
/run-task TASK-1.3            → execute it
/update-docs TASK-1.3         → mark done, sync state
/next                         → what's next?
```

Each task is scoped, prompt-driven, and documented. Claude never wanders into adjacent work. You always know exactly what was done, what's next, and why.

---

## Flight Plan Template

Copy this to `docs/flight-plan.md` to start your own:

```markdown
# [Project Name] — Flight Plan

**Updated:** YYYY-MM-DD

| ID | Title | Size | Status | Prompt |
|----|-------|------|--------|--------|
| TASK-1.1 | [First task] | S | 🔴 TODO | — |
| TASK-1.2 | [Second task] | S | 🔴 TODO | — |
| TASK-1.3 | [Third task] | M | 🔴 TODO | — |
```

**Sizing guide:** S < 2hrs · M = half day · L = full day · XL = multiple days

**Status emoji:** 🔴 TODO · 🟡 READY · 🔵 IN PROGRESS · 🟠 NEEDS VERIFICATION · ✅ DONE · 🔶 BLOCKED
