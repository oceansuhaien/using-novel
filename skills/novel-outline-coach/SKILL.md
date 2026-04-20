---
name: novel-outline-coach
description: Help turn scattered Chinese webnovel ideas into a workable longform outline, premise, hook, plot spine, volume plan, and worldbuilding canon. It writes confirmed high-level outline and canon into `.novel-skill/summary.md`, and places detailed longform material into the appropriate `.novel-skill/` subdirectories instead of stuffing everything into the summary.
---

# Novel Outline Coach

## Shared Reference Layer

Use `novel-skills:novel-system-reference` for shared `.novel-skill/` directory, evidence-level, and cross-document sync policy. This skill owns outline-specific workflow and output decisions only.

## Shared Cross-Document Sync Contract

This skill follows `.omx/specs/deep-interview-cross-doc-sync-policy.md`.
If any older wording in this file conflicts with the policy below, this section wins.

- After one user confirmation of an outline or canon change, you may update every materially affected file under `.novel-skill/` in the same turn, not only `outline/`, `canon/`, or `summary.md`.
- You may infer downstream ripple effects into `plot/`, `characters/`, `chapters/`, and `inbox/` when the confirmed outline or canon change logically implies them.
- Keep outline and canon work as the primary entry point, but do not stop just because the ripple now touches plot or character files.
- You may update deep canon when the confirmed outline direction implies it, including core personality framing, core identity positioning, world rules, faction logic, and long-range story direction.
- Maintain a collaborative loop by surfacing major inferred changes and inviting refinement, but do not require a separate permission gate for each dependent file.
- Older conservative wording in this file about keeping contradictions visible or routing detail away from other domains should not be read as a ban on cross-document propagation. Use the storage split, but keep the story bible synchronized.
- Do not treat prior conflicts as automatic stop points. You may rewrite conflicting material when the new confirmed direction supersedes it.
- Do not treat evidence-like files as write-protected if synchronized downstream updates require changes there.
- Do not invent random lore for flavor alone, but you may fill implied gaps when the confirmed outline direction clearly requires downstream canon repair.

## Primary Domain Rule

Your main job is still high-level outline shaping, premise work, volume planning, and worldbuilding canon.
That means you should lead from `summary.md`, `outline/`, and `canon/` first, then propagate to dependent files as needed, instead of turning every session into full character-card or full scene-planning work.

Turn fragments into an outline that can actually support serialization.

Write like a pragmatic webnovel development editor: clarify the high-concept hook, identify the reader promise, define the main conflict, and convert loose inspiration into structured material that can keep generating chapters.

## `.novel-skill/` 信息架构约定

本技能默认遵守以下项目结构。除非用户明确指定别的路径，否则按此理解和归档：

```text
.novel-skill/
  README.md
  summary.md
  outline/
    premise.md
    volumes.md
    worldbuilding.md
  characters/
    index.md
    cards/
      角色名称.md
    relationships/
      main-relationships.md
  chapters/
    notes/
    extracts/
  canon/
    timeline.md
    factions.md
    locations.md
  inbox/
    raw-ideas.md
    unresolved-questions.md
```

大纲技能重点使用这些位置：

- `summary.md`：项目高层稳定信息与当前阶段结论
- `outline/`：展开后的 premise、卷纲、剧情骨架
- `canon/`：较稳定但不宜全堆进 `summary.md` 的规则、势力、地点、时间线
- `inbox/`：尚未定稿的灵感、分支方案、待筛选方向

大纲技能默认**不把**单角色深度卡、关系网细节、章节摘录明细长段直接塞进 `summary.md`。这些内容仍应优先写入对应子目录；但若本轮确认的大纲或 canon 变化已经明确影响到相关子目录，你可以一并同步更新。

## Workflow

Follow this order unless the user explicitly asks for only one part.

1. Extract the raw idea.
2. Identify the core selling promise.
3. Decide whether the material is premise-level, outline-level, or canon-level.
4. Fill the smallest missing structure that unlocks the next writing step.
5. Write confirmed high-level outline and worldbuilding facts into `.novel-skill/summary.md`.
6. When detail exceeds summary scope, place it into the matching `.novel-skill/` subdirectory.

Do not over-design everything up front. Preserve flexibility where the story still needs discovery.

## Decision Rule

Use these buckets while organizing material:

- Premise: concept, hook, genre, target reader fantasy, emotional promise, tone.
- Outline: protagonist line, major turning points, volume goals, escalation path, ending direction.
- Canon: world rules, factions, geography, power system, timeline, fixed backstory, fixed character facts.

If the user says "just brainstorm", keep output light and avoid prematurely freezing canon.

If the user asks for story outline, worldbuilding, setting bible, or says "记一下/收录进去", update `.novel-skill/summary.md` and, when needed, the relevant file under `outline/` or `canon/`.

## Core Method

Favor webnovel viability over literary abstraction.

For every idea, pressure-test these questions:

- Why will a reader click this instead of a similar book?
- What is the protagonist's repeatable engine for generating scenes?
- What creates immediate forward momentum in the first 3 to 10 chapters?
- What escalating reward loop keeps the serial from going flat?
- What hidden costs, restraints, or reversals prevent the setup from becoming trivial?

If the answer is vague, repair the structure before expanding prose.

## Output Shapes

Choose the lightest structure that solves the user's need.

### Fast Sorting

Use for messy inspiration. Return:

- One-sentence premise
- One-sentence reader promise
- Three to five usable conflict directions
- What should be fixed now vs postponed

### Standard Outline

Use for early project shaping. Return:

- Title direction
- Genre and tone
- Premise
- Protagonist
- Core hook
- Main conflict
- Upgrade or escalation path
- Volume 1 objective
- Mid-term arc direction
- Ending direction
- Risks or weak spots

### Worldbuilding Pack

Use when setting complexity matters. Return only the modules the story needs:

- Era and environment
- Factions and interests
- Geography and movement constraints
- Power system or rule system
- Resource economy
- Social order and taboo
- Hidden truth or deep history

Every worldbuilding module must create story pressure, not just flavor text.

### Character Pack

For major characters, define:

- Public identity
- Private wound or obsession
- Immediate objective
- Long-term desire
- Leverage over others
- Fear, flaw, or blind spot
- Relationship to protagonist
- What scenes they naturally generate

If the user wants detailed character cards, switch to the character-card skill instead of bloating summary-level outline notes.

## Serialization Heuristics

Prefer engines over ornaments.

- Build around a repeatable progression loop, investigation loop, court-conflict loop, survival loop, romance push-pull loop, management loop, or conquest loop.
- Make every major arc answer one promise and open the next.
- Keep each volume centered on one visible question, one target, one main obstacle line.
- Put reversals where success creates a bigger problem instead of ending the story.
- Keep side branches tied back to the protagonist's main gain, loss, or status change.

For inexperienced projects, prefer a clean mainline over large ensemble complexity.

## Summary File Contract

When adding material to `.novel-skill/summary.md`, follow these rules:

- Treat the file as the current high-level canon and planning ledger.
- Add only confirmed information, not every brainstorm branch.
- Preserve user wording when it carries tone or naming intent.
- Mark uncertain items as `待定` instead of pretending they are fixed.
- Keep your reasoning visible when rewriting major canon. If a newly confirmed direction supersedes older canon, you may overwrite the old material and explain the basis for the rewrite.
- Update the most relevant section instead of appending random notes.
- Keep `summary.md` at the level of stable overview; detailed scene evidence, long role notes, and relationship micro-analysis should live in subdirectories.

## Recommended Sections For `.novel-skill/summary.md`

Use or maintain these sections when relevant:

- Project Snapshot
- Core Promise
- Story Outline
- Volume Plan
- Worldbuilding Canon
- Character Roster
- Open Questions
- Recently Confirmed Changes

`summary.md` 的定位是“高层稳定信息页”，不是详细资料堆栈。详细内容按类型下沉：

- 展开后的 premise / 卷纲 / 大纲骨架：写入 `outline/`
- 时间线、势力、地点、规则等较稳定资料：写入 `canon/`
- 单角色深度卡和关系网：交给 `characters/`
- 章节级观察、摘录、证据：写入 `chapters/`
- 尚未锁定的备选方向：写入 `inbox/`

## Method Notes

Read these references only when useful:

- `references/webnovel-method.md`: distilled outline and serialization heuristics from recent 番茄写作分享、起点作者说 and webnovel craft notes.
- `references/summary-schema.md`: the expected high-level structure for `.novel-skill/summary.md`.

If the project has user-specified sample links recorded in `references/webnovel-method.md`, treat them as preferred style references when extracting outline habits or structuring heuristics.

## Quality Bar

Before finishing, check:

- Is the premise specific enough to pitch in one breath?
- Does the protagonist have a strong action engine?
- Does Volume 1 have a concrete target and payoff?
- Does the setting generate conflict instead of just decoration?
- Has confirmed high-level outline/worldbuilding material been written back to `.novel-skill/summary.md`?
- Has any detail that exceeds summary scope been routed into the correct `.novel-skill/` subdirectory instead of being stuffed into `summary.md`?
