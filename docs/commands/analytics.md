# /analytics

Routes analytics questions to the appropriate platform and returns structured data. Supports PostHog, Google Analytics 4, and Microsoft Clarity. Requires MCP (Model Context Protocol) connections to each platform.

---

## What It Does

Takes a natural-language analytics question and routes it to the right tool:

- **Product behavior** (funnels, feature usage, retention, cohorts) → PostHog
- **Traffic and acquisition** (sessions, sources, landing pages, conversions) → GA4
- **Session quality** (rage clicks, dead clicks, scroll depth, heatmaps) → Clarity

Returns the data in a format suitable for decision-making — not a raw data dump, but an interpreted answer with the supporting numbers.

---

## Usage

```
/analytics How many users completed onboarding this week?
/analytics What's the drop-off point in the signup funnel?
/analytics Which landing page has the highest bounce rate this month?
/analytics Are users rage-clicking anywhere on the dashboard?
```

The routing is automatic. You don't need to specify which platform — the command determines which tool has the right data for the question.

---

## Setting Up the MCPs

Each platform requires an MCP connection. MCPs are configured in your Claude Code settings.

### PostHog MCP

PostHog has an official MCP. Add it to `.claude/settings.json`:

```json
{
  "mcpServers": {
    "posthog": {
      "command": "npx",
      "args": ["-y", "@posthog/mcp-server"],
      "env": {
        "POSTHOG_API_KEY": "[your personal API key]",
        "POSTHOG_PROJECT_ID": "[your project ID]"
      }
    }
  }
}
```

Get your API key from PostHog → Settings → Personal API Keys.

### GA4 MCP

GA4 uses Google's application default credentials. Setup:

1. Install the Google Cloud CLI
2. Run: `gcloud auth application-default login`
3. Configure the MCP with your GA4 property ID

```json
{
  "mcpServers": {
    "ga4": {
      "command": "npx",
      "args": ["-y", "@google-analytics/mcp-server"],
      "env": {
        "GA4_PROPERTY_ID": "[your property ID]"
      }
    }
  }
}
```

**Note:** GA4 authentication expires periodically. If you get "reauthentication required" errors, run `gcloud auth application-default login` again.

### Clarity MCP

Microsoft Clarity has an MCP for session insights:

```json
{
  "mcpServers": {
    "clarity": {
      "command": "npx",
      "args": ["-y", "@microsoft/clarity-mcp"],
      "env": {
        "CLARITY_PROJECT_ID": "[your project ID]",
        "CLARITY_API_TOKEN": "[your API token]"
      }
    }
  }
}
```

---

## How Questions Get Routed

The routing logic is based on question type:

| Question type | Routes to |
|--------------|-----------|
| User behavior, funnels, feature adoption | PostHog |
| Traffic, acquisition, SEO, conversions | GA4 |
| Session recordings, heatmaps, click frustration | Clarity |
| Cross-platform comparison | All three (synthesized) |

For ambiguous questions, the command will query the most likely platform and tell you which one it used. If that's not the right platform, specify it explicitly:

```
/analytics [PostHog] What's the 30-day retention for users who completed onboarding?
```

---

## Interpreting the Output

The command returns data with interpretation, not just numbers. For example:

**Question:** "What's the drop-off in the signup funnel?"

**Output (not just numbers):**

```
Signup funnel this week (n=847 sessions):

  Landing → Email entry:  847 → 612  (72% continuation)
  Email entry → Password: 612 → 498  (81% continuation)
  Password → Confirm:     498 → 203  (41% continuation)  ← large drop
  Confirm → Dashboard:    203 → 189  (93% continuation)

The large drop at password → confirm is unusual. Most signup funnels see
the largest drop at email entry. This pattern suggests the confirmation
step (email verification or CAPTCHA) is adding friction. Worth A/B testing
removing or simplifying that step.
```

The interpretation is based on the data plus general product analytics knowledge. It's a starting point, not a conclusion — you know your product and your users better than the data alone does.

---

## Privacy Considerations

Analytics data contains user behavior information. A few things to be aware of:

- PostHog can be configured for anonymous tracking or identified tracking. The level of personally identifiable information in the data depends on your setup.
- GA4 is session-based and does not identify individual users (in the MCP's query interface).
- Clarity session recordings may contain PII if users enter it into your product. Clarity has masking options for sensitive inputs — configure these before enabling session recording.
- Do not paste raw user IDs or email addresses from analytics into shared contexts.

---

## When Analytics MCPs Are Unavailable

If you haven't set up MCPs yet, you can still use the `/analytics` command to help formulate queries:

```
/analytics --query-only What's the drop-off in the signup funnel?
```

With `--query-only`, the command returns the PostHog/GA4/Clarity query you'd run to answer the question, rather than running it. You can then run that query manually in the platform's UI.
