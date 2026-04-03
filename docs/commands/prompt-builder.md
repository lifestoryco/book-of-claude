# /prompt-builder

Generates self-contained task prompts for the WBS system. Takes a task description and produces a fully-specified prompt file that Claude can execute in a future session without additional context.

---

## What It Does

A task prompt is not a description of what you want — it's a complete specification that a fresh Claude instance can execute reliably. Writing good task prompts is a skill. The prompt builder applies a structured methodology to produce prompts that:

- Provide sufficient context without loading unnecessary background
- Break the task into steps small enough to verify
- Include human gates at decision points
- Specify verification criteria precisely
- Cover rollback in case something goes wrong

---

## Usage

```
/prompt-builder TASK-2.5
/prompt-builder "Add email notifications for task assignment"
/prompt-builder --refine path/to/existing-prompt.md
```

With a task ID, looks up the task in your flight plan and builds a prompt for it. With a description, builds a prompt from scratch. With `--refine`, takes an existing prompt and improves it.

---

## The PhD-Level Methodology

The prompt builder doesn't just fill in a template. It follows a structured process:

### Phase 1: Research

Before writing a word of the prompt, the builder reads:
- The relevant section of CLAUDE.md (what invariants apply to this task?)
- Existing code in the area the task will touch (what's already there? what conventions exist?)
- Any prior session notes about this feature area (were there decisions made earlier that constrain this task?)
- Dependencies: what does this task depend on, and what does that tell us about current state?

This research phase prevents the most common prompt failure: writing steps that contradict existing code or ignore prior decisions.

### Phase 2: Scope Definition Gates

Before writing steps, the builder defines and gates the scope:

**Inclusion boundary:** What is explicitly in scope for this task? Write it as a list of observable deliverables.

**Exclusion boundary:** What is explicitly out of scope? Be specific: "do not implement the UI for this feature — that's TASK-2.6." Without explicit exclusions, Claude will naturally extend scope to adjacent problems.

**Decision inventory:** What decisions does this task require? For each decision, is it pre-decided (and if so, what's the answer), or does it require a human gate?

You review the scope definition before the prompt is written. If the scope is wrong, correct it here rather than after the steps are written.

### Phase 3: Step Decomposition

Each step is sized to be verifiable and reversible:
- Small enough that you can inspect the output after each step and know if it's right
- Reversible enough that a bad step can be rolled back without cascading consequences
- Specific enough that there's only one reasonable interpretation of what "done" means

The builder places human gates at:
- After steps that produce output requiring human judgment
- Before steps that are difficult to reverse
- After any step where the correct path forward depends on what the previous step produced

### Phase 4: Assembly

The builder assembles the final prompt from the research, scope definition, and decomposed steps. It adds:
- Context section (2-3 sentences distilling the research into what Claude needs to know)
- Verification section (exact commands to run, exact expected output)
- Definition of Done (checkbox list, 5-8 items)
- Rollback instructions

---

## The Research Phase in Detail

The research phase is what makes the prompt builder different from just filling in `templates/task-prompt.md.template`. It reads actual code.

For a task like "Add email notifications for task assignment":

1. Read `lib/notifications/` if it exists — what notification infrastructure is already there?
2. Read the task assignment route — where does assignment happen? What data is available at that point?
3. Read CLAUDE.md — what email provider is in use? Any rules about async operations?
4. Read `docs/state/project-state.md` — was there any prior work on notifications that was deferred?
5. Read any prior task prompts in the same area — what patterns were established?

This research produces a prompt that says "create `lib/notifications/email.ts` using the existing Resend client in `lib/email/client.ts`" rather than "create an email notification function" — which would leave Claude to discover the existing infrastructure on its own.

---

## Reviewing the Output

After the builder produces a prompt, you review it before it goes into the `pending/` directory. The review checklist:

- [ ] Scope is right — neither too narrow (missing important pieces) nor too broad (doing more than necessary)
- [ ] Steps reference real files and real function names (no placeholders like "in the notifications module")
- [ ] Human gates are at the right places
- [ ] Verification commands are exact — not "check that it works" but "run X and verify output Y"
- [ ] Rollback instructions are realistic

If the prompt is off, tell the builder what's wrong and it revises. The revision loop is faster than starting over.

---

## Prompt Quality Signals

**Strong prompt:**
- Steps name specific files and function signatures
- Each step produces a single verifiable artifact
- Human gates before irreversible operations
- Verification section lists commands with expected output
- Rollback covers both the code change and any data changes (migrations)

**Weak prompt:**
- Steps describe behavior, not artifacts ("implement the notification system")
- No human gates — Claude makes all decisions
- Verification says "test manually"
- No rollback instructions
- Context section describes the project rather than the task

The template in `templates/task-prompt.md.template` is the starting structure. The prompt builder's value is filling it with real specifics rather than generic placeholders.

---

## Output Location

Generated prompts go into `pending/` by default:

```
pending/TASK-2-5_guest-read-only-view.md
```

When you execute the task with `/run-task TASK-2.5`, Claude reads from this path. After execution, the prompt file stays in `pending/` as a record of what was specified. Optionally move completed task prompts to `done/` for archiving.
