# /art

Opens a creative lab session for generative art, visual experiments, and creative exploration. Separate from the main product; no rules about design systems or business logic apply here.

---

## What It Does

Spins up a creative context with different defaults than the main project context. The design system constraints, business logic rules, and architectural patterns from CLAUDE.md do not apply inside the art lab. This is intentional — the art lab is for exploration, not production code.

Output varies by mode. Some modes produce code (Canvas API, SVG, CSS animations). Some produce text (poetic descriptions, generative narrative). Some produce structured concepts (briefs, idea sketches).

---

## The Four Modes

### 1. Canvas

Generates JavaScript that runs on an HTML5 Canvas element. Good for:
- Particle systems
- Geometric animations
- Procedural drawing
- Interactive visual pieces

Output is a self-contained HTML file you can open in a browser. No dependencies.

### 2. Concept

Generates a creative brief — a structured description of a visual or interactive idea. Good for:
- Exploring directions before committing to code
- Articulating an aesthetic intention
- Generating multiple variations of a concept quickly

Output is a markdown brief with: core idea, visual description, interaction model, technical approach.

### 3. Narrative

Generates text in a creative/poetic register. Good for:
- Generative writing experiments
- Companion text for visual pieces
- Exploring voice and tone outside the product context

### 4. System

Generates a complete generative system — a set of rules and parameters that produce infinite variations of a defined aesthetic. Good for:
- Visual identity systems
- Procedural texture generators
- Animation systems with randomized parameters

Output includes the rule set (described) and a reference implementation.

---

## The Idea Bank

The art lab can reference an idea bank — a file of concepts, references, and half-formed ideas you've accumulated. If you maintain one (e.g., `docs/art/idea-bank.md`), tell Claude about it at the start of an art session:

```
/art
Read docs/art/idea-bank.md first. I want to explore the third concept there.
```

The idea bank is unstructured by design. It can be a list, a set of images, a collection of links, fragments of description — whatever you actually accumulate when you're thinking about creative work.

---

## Adding Your Own Concepts

The art lab works best when you give it specific aesthetic constraints rather than open-ended prompts. Compare:

**Vague:** "Make something interesting with particles."

**Specific:** "Particles that behave like iron filings around a moving magnetic field. Monochrome. The field should follow the mouse but with 300ms lag. Particles should have slight weight — they should fall gently when not magnetized."

The more specific the constraint, the more interesting the output. The art lab is not a "generate random art" button — it's a collaborator that responds to your aesthetic intentions.

---

## Technical Standards

The art lab produces code that runs in a modern browser with no build step required. Constraints:

- Canvas mode: vanilla JS only, no external libraries unless explicitly requested
- SVG mode: inline SVG, CSS animations, no build tools
- All outputs: self-contained in a single file, openable directly in a browser

If you want Three.js, p5.js, or another creative coding library, ask for it explicitly. The default is minimal dependencies.

---

## The Brief Format

When the art lab produces a concept brief, it follows this structure:

**Title:** [Short evocative title]

**Core idea:** [One sentence — what is this, at its essence?]

**Visual description:** [What does it look and feel like? Reference real-world phenomena, artists, or aesthetics.]

**Interaction model:** [How does the user's presence or action affect it, if at all?]

**Technical approach:** [What rendering technique, what data structure, what algorithm?]

**Parameters to explore:** [2-4 variables that could be tuned to change the aesthetic character]

**What could go wrong:** [What's the likely failure mode of this idea?]

---

## Relationship to the Main Project

The art lab is exempt from all project-level constraints. It has no design system. It has no CLAUDE.md rules. It does not need to pass `npx tsc --noEmit`. It does not commit to main.

If you build something in the art lab that you want to bring into the main product, that's a separate task — treat it like any other feature, with a proper task prompt and verification step.

The exemption exists because creative exploration requires a different cognitive mode than production code. Constraints that make production code good (type safety, design system consistency, accessibility compliance) make creative experimentation worse. Keep them separate.
