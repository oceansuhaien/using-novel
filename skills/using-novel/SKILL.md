---
name: using-novel
description: Use when starting a novel-development conversation or when the user wants one entrypoint that auto-routes Chinese webnovel work across outline, plot, and character skills. Trigger phrases include /using-novel, "outline", "plot", "story beats", "volume plan", "character card", "relationship card", "worldbuilding", and mixed requests that combine these domains.
---

<SUBAGENT-STOP>
If you were dispatched as a subagent to execute a bounded slice, skip this skill unless the leader explicitly asked you to route novel work.
</SUBAGENT-STOP>

<IMPORTANT>
If the user's request is about Chinese webnovel planning, plot shaping, worldbuilding canon, or character-card synthesis, route to the correct novel skill before doing domain work yourself.

If more than one novel skill applies, sequence them deliberately. Do not run them in parallel because they commonly read and write the same `.novel-skill/` canon.
</IMPORTANT>

# Using Novel

## Purpose

This is the router entrypoint for the local `novel-driver` plugin.

Use it to decide whether the request belongs to:

- `novel-driver:novel-outline-coach`
- `novel-driver:novel-plot-weaver`
- `novel-driver:novel-character-card-coach`
- `novel-driver:novel-system-reference` for shared directory, evidence, and sync policy

Or whether the request should move through a combination of those skills in a fixed order.

Shared `.novel-skill/` directory, evidence, and cross-document sync policy lives in `novel-driver:novel-system-reference`. Do not duplicate those rules here.

## Routing Priority

Respect these priorities:

1. User explicit request wins.
2. If the user explicitly names one skill, use that skill.
3. If the user invokes `/using-novel`, classify the intent and route automatically.
4. If the user mixes domains, use the combination rules below.

## Skill Registry

### `novel-driver:novel-outline-coach`

Use for:

- premise, hook, selling point, genre, tone
- longform outline, volume plan, ending direction
- worldbuilding canon, setting bible, factions, rules
- high-level story structure that should be written back to `.novel-skill/summary.md`, `outline/`, or `canon/`

### `novel-driver:novel-plot-weaver`

Use for:

- plot mainline, hidden threads, foreshadowing, reversals
- scene-chain logic, beats, phase goals, volume hooks
- progression repair when the story has momentum or payoff problems
- consolidating confirmed plot conclusions into `.novel-skill/plot/`

### `novel-driver:novel-character-card-coach`

Use for:

- character cards, relationship cards, roster sheets
- character motives, identity, dramatic function, arc pressure
- evidence-driven extraction of character facts from existing `.novel-skill/` materials
- organizing confirmed character material into `.novel-skill/characters/`

### `novel-driver:novel-system-reference`

Use as a support reference for:

- `.novel-skill/` directory and file placement policy
- confirmed fact, strong inference, pending decision, and suggestion labels
- cross-document propagation rules shared by outline, plot, and character workflows

Do not route user-facing creative work to this skill by itself unless the user asks about plugin policy or file organization.

## Quick Classification

Map the user's request with the lightest valid interpretation:

| User intent | Route |
| --- | --- |
| "I have a story idea" / "help me shape the premise" / "build the outline" | `novel-outline-coach` |
| "help me fix the plot" / "design beats" / "bury foreshadowing" | `novel-plot-weaver` |
| "make a character card" / "sort relationships" / "refine this character" | `novel-character-card-coach` |
| "build the whole project from idea to roles" | combination flow |
| "write polished prose/chapter text" | closest prep skill first, then explain there is no dedicated prose-writing skill in this plugin yet |

## Combination Rules

When multiple domains are involved, use these orders:

### Idea -> story system

If the request is still high-level and unstable:

1. `novel-outline-coach`
2. `novel-plot-weaver`
3. `novel-character-card-coach`

Reason: premise and canon should stabilize before plot details, and plot pressure should stabilize before character-card formalization.

### Outline + plot

Use:

1. `novel-outline-coach`
2. `novel-plot-weaver`

### Plot + character

Default to:

1. `novel-plot-weaver`
2. `novel-character-card-coach`

Exception:
If the user's real blocker is a character identity or motivation gap, reverse the order and start with `novel-character-card-coach`.

### Outline + character

Default to:

1. `novel-outline-coach`
2. `novel-character-card-coach`

### Existing canon sync after one domain update

If a skill confirms a change and its own workflow allows cross-document propagation, let that skill update related `.novel-skill/` files in the same turn. Do not force a second skill just because the ripple touches another folder.

## Execution Rules

After deciding the route:

1. Briefly announce which skill or skill sequence you are using and why.
2. Invoke the selected skill.
3. Follow that skill exactly.
4. If a later skill in the sequence is still needed after the first one finishes, invoke it next.

Do not front-load a full taxonomy to the user. Route first, then work.

## Ambiguity Gate

Ask the user a clarifying question only when the missing detail changes the route itself or blocks the chosen skill from doing quality work.

Good examples:

- "You want either a character card or a plot twist repair, which one is the real blocker right now?"
- "Are we still fixing the high-level premise, or is the premise locked and only the volume beats are drifting?"

Bad examples:

- asking for every preference up front
- turning a clear plot request into a broad interview
- refusing to route because more context might exist

## Fallback

If the request is not primarily outline, plot, or character work:

- answer normally if no novel skill applies
- or hand off to the nearest novel-prep skill when the user is still doing story development but lacks a dedicated prose or chapter-writing workflow

## Red Flags

Stop and correct course if you notice these thoughts:

- "This touches both plot and character, so I should do everything myself."
- "The request mentions worldbuilding once, so it must be outline work."
- "The user wants chapter prose, so the routing plugin is useless."
- "I can run outline and character in parallel to save time."

The correct response is deliberate routing, not skipping the skills.
