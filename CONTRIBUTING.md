# Contributing

Contributions welcome. The bar is low — if it's useful, it belongs here.

---

## The fastest path to a merged PR

1. Fork the repo
2. Add your command to `community/` (use `community/command-template.md` as your scaffold)
3. Test it in at least one real Claude Code session
4. Open a PR with a one-sentence description of what the command does

That's it. No CLA, no lengthy review process.

---

## Command format requirements

Every command file must include:

```
# [Command Name]

[One-sentence description of what this command does.]

## What it does

[2-4 sentences explaining the behavior, what Claude will do, and what output to expect.]

## Token cost

[Low / Med / High]

## Usage

[Example: /my-command [optional-argument]]
```

Use `community/command-template.md` as the starting point — it has all the placeholder sections pre-filled.

---

## Style guidelines

**No product-specific references.** Commands in this repo should work for any project. If your command references your database schema, your API, or your company name, generalize it before submitting. Placeholder variables like `[YOUR_API_ENDPOINT]` are fine.

**No hardcoded credentials or tokens.** Even example values. Use placeholder strings like `YOUR_API_KEY_HERE`.

**One command, one file.** Don't bundle multiple commands into one file.

**Keep instructions tight.** Claude reads every word. Every sentence in a command file consumes tokens. Write the minimum needed to get the behavior right.

**Test it first.** Commands that describe behavior Claude doesn't actually perform in practice don't help anyone. Run it, verify the output matches the description, then submit.

---

## What belongs in community/ vs .claude/commands/

`community/` is for commands shared by contributors. `.claude/commands/` contains the core commands I maintain and use daily. If your command gets enough use and you're willing to maintain it, I'll consider moving it into core — but that's a separate conversation.

---

## Other contributions

Bug fixes to existing commands, corrections to WAR-STORIES.md, additions to the patterns docs — all welcome. Open an issue first if you're unsure whether something fits.

---

## Questions

Open an issue. I'm responsive.
