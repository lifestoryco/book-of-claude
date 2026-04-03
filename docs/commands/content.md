# /content

Generates SEO-optimized content for your product. Supports blog posts, landing pages, feature pages, case study templates, and changelog entries. Includes a human review gate before any content is finalized.

---

## What It Does

Takes a content brief and produces a draft in your configured voice and tone. The command is not a "generate and publish" button — it's a drafting collaborator. Every piece of content goes through a HUMAN GATE before it's considered final.

---

## Usage

```
/content blog: [topic]
/content landing-page: [feature or use case]
/content feature-page: [feature name]
/content changelog: [version or date]
/content case-study-template: [customer segment]
```

---

## Content Types Supported

### Blog Post

Generates a long-form post (800-2000 words) targeting a specific keyword or topic.

Output includes:
- SEO title (under 60 characters)
- Meta description (under 160 characters)
- H1 and H2 structure
- Full draft with inline notes for any sections needing your specific input (customer quotes, data, internal examples)
- Suggested internal links
- Suggested CTA

The command targets a specific keyword if you provide one. If you don't, it suggests keywords based on the topic and your ICP.

### Landing Page

Generates copy for a full landing page: hero section, features section, social proof section, FAQ, CTA.

The hero copy is the hardest thing to get right. The command produces 3 variants of the hero headline and subheadline. You choose or combine.

### Feature Page

A shorter format focused on a single feature. Includes: what it does, who it's for, how it works (3-step), a comparison angle if there's a natural one.

### Changelog Entry

Generates a structured changelog entry. Format: version/date, headline, description, technical details (optional, for developer-facing products), upgrade notes if applicable.

Changelog entries benefit from a consistent voice. If you have prior changelog entries, point the command to them: `/content changelog --style-guide path/to/prior-changelog.md`.

### Case Study Template

Produces a structured template for a customer case study with placeholder prompts for the information you'll need to gather:
- Customer situation before
- Specific problem or trigger
- How they implemented your product
- Specific results (requires real numbers)
- Quote from customer

The template is not a draft — it's an interview guide and structure. The actual case study requires real customer input.

---

## Voice Configuration

The command uses a default voice: clear, direct, non-hypey, professional without being stiff. If your product has a different voice, configure it in `.claude/rules/content.md`:

```markdown
# Content Voice

## Brand voice
Direct and confident, but not cold. We talk like a knowledgeable colleague
who has seen the problem before, not like a company brochure.

## What we avoid
- Hyperbolic claims ("revolutionary," "game-changing," "world-class")
- Passive voice when active is available
- Jargon our users don't use themselves
- Starting sentences with "Leveraging"

## Tone by context
- Blog posts: casual, first-person perspective, story-forward
- Landing pages: outcome-focused, specific, benefit-led not feature-led
- Changelogs: matter-of-fact, specific, brief

## Our users' language
- They say "handoff" not "knowledge transfer"
- They say "team member" not "employee" or "resource"
- They say "onboarding" specifically for new hire ramp-up
```

The command loads this file before generating any content.

---

## The HUMAN GATE Review Flow

Every piece of content goes through this flow:

1. **Brief collection.** The command asks for the topic, target audience, primary keyword (if SEO-targeted), and any specific angles or data points to include.

2. **Outline review.** Claude presents an outline — section structure, angle, primary CTA. This is the HUMAN GATE. You approve, redirect, or modify the outline before any draft is written. This is the cheapest place to catch wrong directions.

3. **Draft generation.** With the approved outline, Claude writes the full draft.

4. **Draft review.** Another HUMAN GATE. You read the draft and provide feedback. Claude revises.

5. **Final output.** The approved draft, formatted for your publishing destination.

The outline review gate is the most important. Redirecting an outline takes 30 seconds. Redirecting a 1500-word draft takes much longer.

---

## SEO Considerations

The command applies basic SEO hygiene but is not a replacement for SEO strategy:

**What it does:**
- Target keyword in title, H1, first 100 words, and 2-3 H2s
- Appropriate keyword density (not stuffed)
- Title under 60 characters for clean SERP display
- Meta description under 160 characters
- H2 structure that aligns with what "people also ask" for the target topic

**What it doesn't do:**
- Competitor keyword analysis (do this yourself with Ahrefs, Semrush, or similar)
- Backlink strategy
- Internal linking beyond basic suggestions
- Technical SEO (site speed, Core Web Vitals, schema markup)

If you have a keyword research document or a content calendar, share it with the command as context. The more context it has about your SEO strategy, the more targeted the output.

---

## Publishing

The command generates copy as markdown. Paste it into your CMS, blog platform, or wherever you publish. The command does not publish automatically — that's intentional. Final review before publishing is your responsibility.
