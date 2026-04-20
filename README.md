# Novel Skills

`novel-skills` is a workspace-local Codex plugin focused on Chinese webnovel development workflows.

It packages a small set of specialized skills and thin command entrypoints so a writing-oriented workspace can route requests into the right lane without duplicating rules across prompt files.

## What This Plugin Does

The plugin currently covers four main authoring lanes plus one shared reference layer:

- `using-novel`: broad router for mixed or unclear novel-development requests
- `novel-outline-coach`: premise, hook, outline, volume plan, and canon consolidation
- `novel-plot-weaver`: plot beats, hidden threads, reversals, foreshadowing, and progression repair
- `novel-character-card-coach`: character cards, relationship cards, arcs, rosters, and character-bound rules
- `novel-system-reference`: shared directory contracts, evidence standards, and sync/writeback policy

## Design Principles

- `plugins/novel-skills/` is the only maintained source of truth for the plugin
- `.codex/skills/` mirrors are install or sync artifacts, not a second authoring tree
- command files stay thin and only dispatch into skills
- skill-specific workflow detail lives in `skills/*/SKILL.md` and `skills/*/references/`
- shared policy belongs in one reference source instead of being copied into multiple skills

## Who This Is For

Use this plugin when the workspace needs structured help with:

- turning fragments into longform webnovel outlines
- tightening arcs, hooks, suspense, and reversals
- extracting character cards from existing story notes
- keeping story-canon handling consistent across outline, plot, and character work

This is not a generic fiction generator. The plugin is optimized for evidence-driven Chinese webnovel development inside a local Codex workspace.

## Entry Points

Use `/using-novel` when the request spans multiple domains or the right lane is still unclear:

- `/using-novel help me turn this fragment into a longform outline`
- `/using-novel fix the volume 1 beats and hide a later betrayal`
- `/using-novel make a character card for this antagonist`
- `/using-novel I need premise, plot spine, and main cast positioning`

Use a direct command when the lane is already obvious:

- `/novel-outline`
- `/novel-plot`
- `/novel-character`

## Project Layout

```text
plugins/novel-skills/
|- .codex-plugin/          plugin metadata
|- assets/                 icons and display assets
|- commands/               thin command adapters
|- evals/                  manual regression cases
|- scripts/                validation and sync helpers
|- skills/                 skill source of truth
|- AGENTS.md               plugin-local maintenance rules
|- CLAUDE.md               Claude-facing adapter
|- README.md               plugin overview and maintenance guide
```

## Key Files

- `.codex-plugin/plugin.json`: plugin metadata, interface text, icon wiring, and skill root declaration
- `commands/*.md`: command adapters that dispatch into the plugin skills
- `skills/*/SKILL.md`: primary workflow instructions for each skill
- `skills/*/references/`: shared schemas, methods, and policy references
- `skills/*/agents/openai.yaml`: user-facing skill metadata that must stay aligned with the skill trigger contract
- `evals/*.md`: regression prompts and expected routing/behavior checks
- `scripts/quick-validate.ps1`: structural validation for plugin metadata and skill files
- `scripts/run-evals.ps1`: lists manual evaluation cases
- `scripts/sync-to-codex-skills.ps1`: one-way sync helper for `.codex/skills/` mirrors

## Local Development

This plugin is maintained directly from `plugins/novel-skills/`.

When editing it:

- update source files here first
- do not treat `.codex/skills/` as a manual authoring location
- keep `SKILL.md` frontmatter and `agents/openai.yaml` aligned for user-facing skills
- avoid writing story data into `.novel-skill/` during plugin maintenance unless the task explicitly switches to story or canon work

## Validation

Validate plugin structure:

```powershell
powershell -ExecutionPolicy Bypass -File plugins\novel-skills\scripts\quick-validate.ps1
```

List manual eval cases:

```powershell
powershell -ExecutionPolicy Bypass -File plugins\novel-skills\scripts\run-evals.ps1
```

Preview sync into `.codex/skills/`:

```powershell
powershell -ExecutionPolicy Bypass -File plugins\novel-skills\scripts\sync-to-codex-skills.ps1
```

Apply sync only when intentionally refreshing local mirrors:

```powershell
powershell -ExecutionPolicy Bypass -File plugins\novel-skills\scripts\sync-to-codex-skills.ps1 -Apply
```

## Maintenance Notes

- keep the README focused on plugin usage and maintenance, not on duplicating full skill bodies
- prefer adding shared rules to reference files instead of copying them into multiple command or skill entry files
- keep diffs small and reversible because this plugin is primarily prompt-and-policy infrastructure
