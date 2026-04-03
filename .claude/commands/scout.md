# SCOUT — Social Listening Dashboard

Surface high-intent Reddit posts matching your ideal customer profile.

**Setup required:** Configure your subreddits and scoring keywords in `scripts/scout/fetch-reddit.sh` before first use. See `docs/commands/scout.md` for setup guide.

---

## Step 1 — Smart scan

Read `docs/state/social-feed.md` header for `_Last scan time:_`. Compute hours since then (cap at 24).

```bash
bash scripts/scout/fetch-reddit.sh {hours_back} --scored 20
```

This returns scored posts from your configured subreddits. Each has `total_score`, matched categories, and metadata.

---

## Step 2 — Process results

For each returned post not already in the feed (check existing IDs):
- **Claude judgment:** Adjust score by -10 to +20 (genuine signal? spam? helpful?)
- Drop if final score < 20
- **Thread type:** Crisis/Recovery, Process, Tool Search, Prevention, Pain Point
- **Codename:** 2 punchy keywords, UPPERCASE-HYPHENATED, unique in feed

Update `docs/state/social-feed.md` — new posts (status: `new`), prune expired.

---

## Step 3 — Display dashboard

```
═══════════════════════════════════════════════
  Scout | {new_count} new / {total} total
  Last scan: {time_ago}
═══════════════════════════════════════════════
```

For each post:
```
#1 {CODENAME} [{score}/100] r/{subreddit} • {time_ago}
   "{title}"
   → {url}
   Type: {thread_type} | u/{author} | {num_comments} comments
```

---

## Step 4 — Actions

```
What would you like to do?
• "draft 1" or "draft CODENAME"  → Draft a response
• "open 2"     → Print URL
• "skip 3"     → Mark rejected
• "refresh"    → Scan again
```

## Rules
- NEVER auto-post to Reddit. Read-only.
- Feed file `docs/state/social-feed.md` is single source of truth.
- Codenames must be unique within active feed.
