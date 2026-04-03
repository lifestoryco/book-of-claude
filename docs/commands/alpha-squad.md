# /alpha-squad

Runs a simulated advisory board that debates a topic and produces a structured recommendation. Use this for decisions where a single perspective is insufficient — architecture pivots, product direction, security tradeoffs, pricing strategy.

---

## What It Does

A panel of five named advisors — each with a distinct mandate — receives your question. They debate it. Each advisor argues from their specific perspective. The output includes a majority recommendation, preserved minority dissent, and a Founder Decision Point that summarizes the recommendation in a form you can act on.

The value is not that Claude becomes five different people. The value is that structuring the output as a debate forces Claude to argue multiple sides before committing to a recommendation, and to preserve the strongest counterargument even when the majority favors a different answer.

---

## Usage

```
/alpha-squad [topic or question]
```

For faster decisions:

```
/alpha-squad huddle: [topic]
```

The huddle format runs three members instead of five. Use it for tactical questions ("should we use Redis or Postgres for this queue?"). Use the full board for strategic questions ("should we pivot to enterprise-only?").

---

## Default Board Members

The default board is configured for a B2B SaaS product context. Adjust for your project.

| Member | Mandate |
|--------|---------|
| **CTO** | Technical architecture, scalability, debt. Pushes back on shipping fast at the cost of maintainability. Will argue for deferring features if the foundation isn't ready. |
| **Product Strategist** | User value and prioritization. Asks "does this solve a real problem for the customer?" Will challenge over-engineering and advocate for shipping sooner. |
| **Security Lead** | Attack surface, trust, compliance. Treats every new feature as a potential vulnerability until proven otherwise. Will advocate for the most conservative approach. |
| **UX Lead** | User experience, accessibility, copy. Asks "what does the user see and feel?" Will push back on technical solutions that create confusing UI. |
| **CFO/Business Lead** | ROI, risk, runway. Frames every decision in terms of cost, revenue impact, and risk to the business. Will advocate for the cheapest path to validation. |

---

## Customizing the Board

Swap members for your domain. The key is giving each member a **specific mandate** that creates natural disagreement with the others. A vague role produces a vague advisor.

**Good mandate:** "You are the Security Lead. Your job is to identify every way this decision could expose user data or enable unauthorized access. You will advocate for the most restrictive approach. You do not consider feature velocity; that's someone else's job."

**Weak mandate:** "You care about security." (Too vague — produces generic security advice, not genuine debate.)

Example customizations:
- **Consumer app:** Swap CFO for a Growth Lead (acquisition cost, retention, viral loops)
- **Enterprise product:** Add a Compliance/Legal Lead (SOC 2, GDPR, enterprise procurement)
- **Infrastructure product:** Swap UX Lead for a DevEx Lead (developer experience, API design, docs)
- **Early-stage startup:** Swap CFO for a Customer Lead (specific user personas, sales feedback)

---

## Meeting Formats

### Full Board (5 members)

Use for:
- Product direction decisions
- Architecture decisions with long-term implications
- Security or compliance questions
- Pricing and business model decisions
- "We're stuck and keep going in circles" situations

Output includes: position statement from each member, cross-member debate, majority recommendation, strongest minority dissent, Founder Decision Point.

### Huddle (3 members)

Use for:
- Tactical technical decisions
- Library or tool selection
- Implementation approach questions
- "Quick sanity check" on a decision already mostly made

Output includes: three positions, brief debate, recommendation with confidence level.

---

## The Founder Decision Point

Every board session ends with a Founder Decision Point — a structured summary designed to make the recommendation actionable:

- **Recommendation:** What the board recommends, in one sentence
- **Confidence:** High / Medium / Low — and why
- **Primary dissent:** The strongest argument against the recommendation, in one sentence
- **Reversibility:** Is this easy to undo if it turns out to be wrong?
- **Next action:** Specifically what you should do next if you accept the recommendation

You read the Founder Decision Point first. If it's enough context to decide, you decide. If you want the debate behind it, read the full transcript.

---

## Referencing Prior Meetings

Board meetings are not automatically stored. If a prior meeting's conclusion is relevant to a new question, paste the Founder Decision Point from the prior meeting into the new `/alpha-squad` prompt as context:

```
/alpha-squad We're reconsidering the pricing decision from last week.
Prior decision: [paste Founder Decision Point here]
New context: [what changed]
```

This gives the board the prior recommendation to argue with or build on, rather than starting from scratch.

---

## Example: Founder Decision Point Output

**Question posed:** Should we build a native mobile app for v1 or ship web-only and add mobile later?

**Recommendation:** Ship web-only for v1. Focus mobile investment when you have 50+ active paying users who are asking for it.

**Confidence:** High — three of five board members reached this recommendation independently.

**Primary dissent (Product Strategist):** "Our target users (small business owners) are phone-first. A web-only product may never feel native enough to retain them, and it may be harder to add mobile later if the data model is designed for desktop interactions."

**Reversibility:** Medium — web-first doesn't lock you out of mobile, but if the Product Strategist is right about the user behavior, you'll have built 6 months of the wrong thing.

**Next action:** Before starting v1 implementation, do 5 user interviews specifically asking about device preference for task management. If 3+ users say mobile-first, revisit this decision before shipping.
