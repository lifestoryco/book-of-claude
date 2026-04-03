# Analytics Insights

Conversational analytics interface across PostHog, GA4, and Microsoft Clarity.

**Input:** `$ARGUMENTS` — a natural language question about your product analytics.

---

## Step 1 — Parse the Question

Determine which platform(s) can answer the question:

| Question Type | Primary Platform | Secondary |
|---------------|-----------------|-----------|
| User behavior, funnels, retention | PostHog | GA4 |
| Traffic sources, acquisition, SEO | GA4 | PostHog |
| Session recordings, heatmaps, rage clicks | Clarity | — |
| Feature usage, A/B test results | PostHog | — |
| Page performance, Core Web Vitals | GA4 | Clarity |
| Cross-platform patterns | All three | — |

---

## Step 2 — Query

Query the relevant platform(s) using their MCP tools. If multiple platforms, query in parallel.

For each query, extract:
- Raw data / metrics
- Time period
- Segment breakdowns (if relevant)

---

## Step 3 — Cross-Reference

If data from multiple platforms is available:
- Look for confirming patterns (same story from different angles)
- Flag contradictions (different platforms disagree)
- Note coverage gaps (what one platform sees that others don't)

---

## Step 4 — Report

```
═══════════════════════════════════════════════
  Analytics Insight
═══════════════════════════════════════════════

Question: {user's question}

Answer: {direct answer in 2-3 sentences}

Data:
  {key metrics with source attribution}

Sources:
  {which platforms provided data}

Unexpected:
  {any surprising patterns or contradictions}

Recommendation:
  {actionable next step based on the data}
═══════════════════════════════════════════════
```

## Rules
- Always cite which platform provided which data point
- If a platform isn't configured (no MCP), skip it gracefully
- Don't speculate beyond what the data shows
- Flag low sample sizes or short time periods
