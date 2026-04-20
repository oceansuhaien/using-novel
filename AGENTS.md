# Novel Skills Plugin Guidance

- `plugins/novel-skills/` is the maintained source of truth for this plugin.
- `.codex/skills/` mirrors are install or sync artifacts, not a second authoring tree.
- Keep entry files thin. Detailed novel workflow belongs in `skills/*/SKILL.md` and `skills/*/references/`.
- Commands are dispatch adapters only. Do not duplicate skill body logic in command files.
- Shared routing, directory, evidence, and writeback rules must live in one reference source.
- Every user-facing skill must keep `SKILL.md` trigger metadata and `agents/openai.yaml` aligned.
- Add deeper `AGENTS.md` or `CLAUDE.md` files only when a subtree has materially different constraints.
- Do not edit `.novel-skill/` from plugin maintenance tasks unless the user explicitly switches to story/canon work.
