# Why Structure Beats Vibes

The most common way people use Claude Code is to open a session, describe what they want, and see what comes back. This works. Up to a point.

The point where it stops working is somewhere around the third week of a real project. Sessions accumulate. Context drifts. Claude makes a decision in session 7 that contradicts something it decided in session 3, because it has no memory of session 3. A component gets refactored in a way that breaks a convention established two weeks ago. A banned library shows up in a new file because nothing was enforcing the ban.

The failure mode is not that Claude writes bad code. It's that Claude writes locally coherent code that is globally inconsistent. Each individual decision looks reasonable in isolation. The accumulated effect is a codebase that no longer follows any consistent pattern.

Structure is the fix. Not structure as bureaucracy, but structure as constraint — the kind that makes Claude's behavior deterministic and compounding rather than locally consistent but globally incoherent.

---

## The Case for Treating Claude as a Senior Engineer

When you onboard a senior engineer, you don't hand them the codebase and say "figure it out." You give them context: here's how we auth, here's what we don't touch, here's the deployment model, here are the three decisions we made that look weird but had good reasons. You tell them the rules of the road before they start driving.

CLAUDE.md is that onboarding document. The difference between a CLAUDE.md that describes your project and one that constrains Claude's behavior is the difference between a description of traffic laws and an actual speed limit. One is informational. The other produces consistent outcomes.

The senior engineer framing also helps calibrate how much to explain. You don't need to explain every line of code to a senior engineer. You need to explain the non-obvious stuff — the tradeoffs, the gotchas, the places where the obvious solution is wrong. That's what belongs in CLAUDE.md: not "we use React" (Claude can see that) but "we don't use this deprecated hook because it caused a race condition in production and we fixed it by doing X instead."

---

## Advisory vs. Enforcement

There are two ways to make Claude behave consistently: ask it nicely, or enforce it mechanically. Both are necessary. Neither alone is sufficient.

CLAUDE.md and rules files are advisory. They load into context, they prime Claude's behavior, they establish expectations. They work most of the time. When Claude is mid-task with a full context window, navigating a complex refactor, handling a tricky edge case — that's when advisory rules slip. Not because Claude ignores them, but because they get crowded out.

Hooks are enforcement. A hook that blocks `rm -rf /` will block it every time, regardless of context window state. A hook that runs the type checker before every commit enforces type safety without relying on Claude to remember to do it. Hooks don't get tired. They don't get distracted. They don't have context windows.

The right model is: use CLAUDE.md and rules to shape the vast majority of behavior, use hooks to enforce the few things that cannot be left to discretion. The combination produces behavior that is consistent enough for a real project.

---

## Where "Just Asking Nicely" Fails

Three concrete failure modes:

**1. Context crowding.** You wrote "never use the deprecated `getSession()` function" in CLAUDE.md. Three sessions later, Claude is mid-task, the context window is heavy with code, and it reaches for `getSession()` because it's the natural fit for the code it's reading. The rule was there at the start of the session. It got crowded out by 40K tokens of task context. A hook that checks for `getSession()` in any new file would have caught this.

**2. Drift without memory.** You made an architecture decision in session 2: we're using magic links for public users, not OAuth. You noted it in the session, maybe even in the handoff doc. In session 9, you're adding a new public-facing feature. The current context is about that feature; the magic link decision is several sessions in the past. Claude implements OAuth because it's the obvious choice for auth. The session state document — read at the start of every session — is the fix. But you have to actually maintain it.

**3. Scope creep without a WBS.** You ask Claude to add a notification feature. It's larger than expected. Claude starts making decisions about the notification schema, the UI, the email template, the delivery mechanism, all in a single session without explicit checkpoints. Some of those decisions are good. Some create technical debt. Without a task prompt that says "in this session, only implement the DB schema and the send function — do not build the UI yet," there's no natural checkpoint for the human to redirect.

The structure in this repo — CLAUDE.md, session state, WBS task prompts, hooks — is specifically designed to address these three failure modes. None of it is magic. All of it requires discipline to maintain. The payoff is a codebase that stays coherent across 50+ sessions.

---

## What Good Structure Looks Like

Good structure is lean. A CLAUDE.md with 5 hard rules and a clear auth pattern is more effective than one with 40 bullet points. Forty points means Claude is choosing which 10 to actually hold in memory. Five points means Claude holds all five.

Good structure is specific. "Always log mutations to the audit table using `insertAuditEntry()`" is a rule. "Handle errors properly" is not a rule. The test: could a new developer read this rule and know exactly what to do? If yes, it's a rule. If no, it's a guideline, and guidelines are advisory at best.

Good structure is maintained. A session state doc that's two weeks out of date is worse than no session state doc. It poisons the next session with stale context. The end-session ritual — update the state doc, note what was decided, note what's next — takes five minutes and pays back immediately.

Good structure separates concerns. Domain rules live in `rules/security.md`, `rules/frontend.md`, `rules/business-logic.md` — not crammed into one giant CLAUDE.md. This makes each domain's rules easy to find, easy to update, and easy to tell Claude "load `rules/security.md` for context on this task."

---

## The Compounding Effect

None of this pays off in session one. In session one, CLAUDE.md saves you maybe one correction. The worktree saves you one merge conflict. The task prompt saves you one scope-creep detour.

By session twenty, the payoff is qualitatively different. Claude operates with accurate priors. It knows the patterns. It catches its own deviations because the rules are crisp. The session state doc gives it a reliable picture of what happened before. The task prompts keep individual sessions focused. The hooks catch the cases where everything else misses.

The codebase stays coherent. That is the outcome. It sounds modest. In practice, for a solo developer or a small team working with Claude as a primary collaborator, a coherent codebase across 50 sessions is worth more than any individual feature.
