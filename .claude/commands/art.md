# ART — Creative Lab

Parse `$ARGUMENTS` to determine mode:

- **No args** → Mode A (Dashboard)
- **`brainstorm`** → Mode B (Ideation)
- **`build [name]`** → Mode C (Build Session)
- **`prototype [description]`** → Mode D (Quick Experiment)

---

## Mode A: Dashboard

Scan `docs/lab/briefs/` for project briefs. Scan your app's lab directory for live projects.

```
╔══════════════════════════════════════════════╗
║  THE LAB                                     ║
╠══════════════════════════════════════════════╣
║  LIVE: [project list with dates]             ║
║  IN BRIEF: [briefs not yet built]            ║
║  Run /art brainstorm, build, or prototype    ║
╚══════════════════════════════════════════════╝
```

---

## Mode B: Brainstorm

Present 5 concepts from the idea bank below. For each: name, one-sentence vision, core technique, viral potential (1-3 fire).

**Tier 1 (Highest viral potential):**
| Concept | Vision | Technique |
|---------|--------|-----------|
| Fluid Simulation | Touch injects velocity into a fluid field. The screen becomes liquid light. | Navier-Stokes solver. Mouse/touch = force injection. |
| Reaction-Diffusion | Biological patterns emerge from chemistry. Spots, stripes, labyrinths. | Gray-Scott model. Tunable via URL params. |
| Fourier Drawing Machine | Draw any shape. Watch it decomposed into orbiting circles. | DFT decomposition into epicycles. Animated reconstruction. |
| Particle Life | Colored particles attract and repel by simple rules. Ecosystems emerge. | N-body simulation with configurable attraction matrix. |
| Boid Murmuration | A thousand birds move as one mind. No leader. Just three rules. | Reynolds flocking with predator avoidance. |

**Tier 2:**
| Terrain Flyover | Infinite procedural landscape. Never repeats. | Perlin noise heightmap with camera dolly. |
| Automata Zoo | Unknown cellular automata. Brian's Brain, Langton's Ant, Wireworld. | Multiple CA rulesets on shared grid. |
| Wave Interference | Drop stones into a pool. Watch ripples collide. | 2D wave equation solver. Click to add sources. |

**Tier 3:**
| Lorenz Butterfly | The shape chaos makes. 3D attractor in ASCII light. | Lorenz system with RK4 integration. |
| L-System Garden | Recursive botanical structures grow from seeds. | Lindenmayer system with turtle graphics. |
| Strange Attractor Museum | Curated collection of beautiful strange attractors. | Multiple ODE systems as point clouds. |

Ask the user to pick one or describe their own vision. Develop a brief collaboratively, save to `docs/lab/briefs/[name].md`.

---

## Mode C: Build

Load brief from `docs/lab/briefs/[name].md`. Scaffold the project in your app:
- Route entry (page.tsx)
- Main component with the simulation engine
- Gallery registration

**Technical standards:**
- Canvas 2D with device pixel ratio scaling
- requestAnimationFrame with throttling (40ms default)
- Touch gesture support (mobile-first)
- Pause/resume capability
- Dark background (#080808)
- No external canvas/WebGL libraries unless genuinely needed

Preview, iterate with user, verify, commit.

---

## Mode D: Prototype

Everything after `prototype` is the description. Build a quick standalone component. Preview immediately. Ask: save as brief, tweak, or scrap.

## Rules
- Dark, immersive aesthetic. No nav bars. Standalone pages.
- Touch-first interaction design
- Each project self-contained in its own folder
- Canvas 2D by default, WebGL only if genuinely needed
