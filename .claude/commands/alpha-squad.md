# ALPHA SQUAD — Advisory Board Meeting

Convene an advisory board to debate a topic and produce an actionable blueprint. Each member researches independently, argues from their expertise, and the Founder makes key decisions in real-time.

Topic: $ARGUMENTS

---

## Step 0 — Context Gathering (silent)

Read these files silently — do NOT output anything yet:

1. `docs/meetings/README.md` — count table rows to determine next meeting number. Extract the last 3 meeting entries.
2. Read those 3 most recent meeting files — focus on **Decisions** and **Action Items** for continuity.
3. `docs/state/project-state.md` (if exists) — current project state, blockers, recent work.
4. `CLAUDE.md` — project rules and context.

If `$ARGUMENTS` is empty, ask the Founder: `What topic should the board debate today?`

---

## Step 1 — Scope Lock

```
═══════════════════════════════════════════════════════════════
  ADVISORY BOARD — Meeting #N
  Date:    YYYY-MM-DD
  Topic:   {topic}

  Board:   CTO · CMO · COO · Product Lead · UX/UI Lead · Finance · Legal
  Guests:  {1-3 dynamic consultants based on topic}
═══════════════════════════════════════════════════════════════
  Confirm topic, or adjust.
```

Wait for confirmation.

---

## Step 2 — Independent Research

Each board member prepares INDEPENDENTLY using tools:

**CTO** — Grep/Read codebase for relevant implementations. WebSearch for tech trends. Form a technical position with file paths and data.

**CMO** — WebSearch for market trends, positioning, growth strategies. Form a go-to-market position.

**COO** — Assess operational cost, timeline, process efficiency. Form an efficiency-first position.

**Product Lead** — Review roadmap context, assess pain point alignment and adoption. Form a user-needs position.

**UX/UI Lead** — WebSearch for best-in-class UX patterns (Linear, Notion, Vercel, Stripe). Analyze user journey impact. Form a user-experience position.

**Finance** — Analyze revenue implications, CAC, unit economics. Form a financial position.

**Legal** — Assess compliance, licensing, privacy implications. Form a risk-aware position.

**Each member must arrive with a POSITION, not just observations.**

---

## Step 3 — The Meeting

### Tone Rules
- Assertive and direct. No hedging.
- Evidence-based. Cite research — file paths, data, competitor examples.
- Genuine disagreement. Challenge each other.
- Practical. Tied to current goals and timeline.

### Flow

1. **Context** — Most relevant lead sets the stage (2-3 sentences)
2. **Key Findings** — Each member presents under their own heading
3. **The Debate** — Members react, challenge, build on each other
4. **Dissent Protocol** — At least ONE member MUST argue the contrarian position. Mandatory. Named explicitly.
5. **Founder Decision Points** — When the board hits a genuine fork:

```
┌─────────────────────────────────────────────────────┐
│  FOUNDER DECISION NEEDED                            │
│                                                     │
│  [Describe the fork]                                │
│                                                     │
│  Option A: [description]                            │
│    → Who supports and why                           │
│                                                     │
│  Option B: [description]                            │
│    → Who supports and why                           │
│                                                     │
│  Board recommendation: [Option X] because [reason]  │
└─────────────────────────────────────────────────────┘
```

**PAUSE and wait for input.**

6. **Decisions Table:**

| # | Decision | Rationale | Confidence |
|---|----------|-----------|------------|
| 1 | ... | ... | High/Med/Low |

7. **Action Items:**

| # | Action | Owner | Priority |
|---|--------|-------|----------|
| 1 | ... | ... | High/Med/Low |

---

## Step 4 — Save & Index

1. Save to `docs/meetings/{YYYY-MM-DD}-{topic-slug}.md`
2. Update `docs/meetings/README.md` with new row
3. Confirm: `✅ Meeting #N saved. Decisions: X | Action items: Y`

---

## Step 5 — Post-Meeting

```
What's next?
• "prompt N"   → Generate a task prompt for action item #N
• "deepen N"   → Reconvene focused on decision #N
• "done"       → Close the meeting
```

## Rules
- NEVER skip independent research. Each member earns their seat.
- NEVER let the board reach unanimous agreement without testing it. Dissent is mandatory.
- NEVER simulate Founder decisions. PAUSE and ASK.
- ALWAYS save the meeting file and update the index.
