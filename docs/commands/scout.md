# /scout (Reference Pattern)

A social listening system for Reddit that surfaces relevant discussions in your target communities. Implemented as a bash script using Reddit's public `.json` endpoints — no API key, no Python, no external dependencies.

**This is a reference pattern, not a drop-in system.** You configure your own target subreddits, scoring thresholds, and response strategy. The scripts are starting points. What you do with the output depends entirely on your ICP and your goals.

---

## What It Does

Fetches recent posts from configured subreddits, scores them for relevance and engagement, and displays a dashboard of the highest-signal discussions. A companion command (`/scout-draft`) helps you draft responses.

The full system:
- `/scout` — display the current feed dashboard
- `/scout-draft` — collaborative reply drafting for a specific post
- `/scout-seed` — create authentic discussion questions to plant

---

## The Fetch Script

`scripts/scout/fetch-reddit.sh` uses curl to hit Reddit's public `.json` endpoints:

```bash
#!/bin/bash
SUBREDDIT=$1
LIMIT=${2:-25}
TIMEFRAME=${3:-"week"}

curl -s -A "Mozilla/5.0" \
  "https://www.reddit.com/r/$SUBREDDIT/top.json?limit=$LIMIT&t=$TIMEFRAME" \
  | jq '.data.children[].data | {
      title: .title,
      score: .score,
      num_comments: .num_comments,
      url: .url,
      permalink: .permalink,
      created_utc: .created_utc,
      selftext: .selftext
    }'
```

No Reddit API key needed. The `.json` endpoint is public. Rate limit is generous for personal use — do not abuse it.

**Comment fetcher:** `scripts/scout/fetch-comments.sh` retrieves the top comments for a post URL. Used by `/scout-draft` to get context before drafting a reply.

---

## Configuring for Your ICP

The scripts are generic. The configuration is yours.

**Step 1: Identify your P0 subreddits.** Where does your ideal customer hang out and talk about problems your product solves? Be specific. "Marketing" is not a subreddit. `r/smallbusiness`, `r/freelance`, `r/PPC`, `r/SEO` — these are subreddits with specific communities.

Start with 3-5 subreddits. More than that is noise.

**Step 2: Set a scoring threshold.** The feed filters out posts below a minimum engagement score. The default in these scripts is 20 (upvotes + engagement composite). For very active subreddits (100K+ members), you might raise this to 50 or 100. For niche communities, lower it to 10 or even 5.

**Step 3: Define relevance signals.** The fetch script gets all posts above the score threshold. You still need to decide what's relevant. Update the feed doc format to include a relevance filter: which posts are actually about the problem your product solves?

**Step 4: Configure the feed file.** The feed is stored as a markdown file (`docs/state/scout-feed.md`). Each entry has: post title, subreddit, score, URL, and your assessment of relevance. The format can be whatever's useful to you.

---

## The Response Strategy

The `/scout-draft` command helps draft a reply to a specific post. The drafting rules are yours to define, but based on what works:

**What works:**
- Short (2-4 sentences). Long comments get skimmed or ignored.
- Personal experience framing ("I ran into this same issue when..."). Not advisor/consultant framing.
- Ends with a question. Invites engagement rather than closing the conversation.
- No product mention unless directly relevant and the context clearly invites it.

**What doesn't work:**
- "As a [founder/product person/expert], here's my advice..." (announces status, feels inauthentic)
- Directly pitching your product in the reply (gets flagged as spam, damages credibility)
- Generic advice that could have been written by anyone

**The test:** Would you be comfortable if someone replied "are you just promoting your product?" If yes, the reply is authentic enough to post. If no, rewrite it.

---

## The Seed Pattern

`/scout-seed` creates genuine discussion questions to plant in subreddits. The goal is to surface real conversations about problems you care about — not to promote anything.

Rules for responsible seeding:
- Maximum 2 seeds per week across all subreddits
- Maximum 1 seed per subreddit per week
- Never seed the same subreddit twice in a row
- Never mention any product or company in the seed
- The question must be genuinely interesting — one you'd want to read the answers to

The seed is not a lead generation tool. It's a way to start conversations that produce insight about your market.

---

## Scheduling

The fetch scripts can be scheduled to run automatically. A cron job or a Claude Code scheduled task that runs every 4-8 hours and appends to the feed file is a reasonable setup.

The feed file grows over time. Archive old entries (older than 2 weeks) to a separate file. The active feed should be scannable in one sitting.

---

## Adapting for Other Platforms

The Reddit `.json` pattern works specifically for Reddit. If your ICP is on Hacker News, LinkedIn, Twitter/X, or specific forums, the pattern is the same but the implementation differs:

- **Hacker News:** Algolia's HN search API (`hn.algolia.com/api/v1/search`) is public and doesn't require a key. Same pattern as Reddit `.json`.
- **LinkedIn/Twitter:** Require API access. The free tiers have significant limitations. Budget time for API setup.
- **Forums/communities:** Many Discourse-based forums have public `.json` endpoints (append `.json` to most Discourse URLs). Worth checking before building a scraper.

The scout pattern is platform-agnostic at the strategy level. The bash scripts are Reddit-specific and would need adaptation for other platforms.
