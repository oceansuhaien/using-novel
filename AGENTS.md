# Novel Driver Plugin Guidance

- This repository root is the maintained source of truth for this plugin.
- `skills/` is the authoring source for skill behavior.
- `.codex/skills/` mirrors are install or sync artifacts, not a second authoring tree.
- Keep entry files thin. Detailed novel workflow belongs in `skills/*/SKILL.md` and `skills/*/references/`.
- Commands are dispatch adapters only. Do not duplicate skill body logic in command files.
- Shared routing, directory, evidence, and writeback rules must live in one reference source.
- Every user-facing skill must keep `SKILL.md` trigger metadata and `agents/openai.yaml` aligned.
- Keep README installation-centered. Do not reintroduce workspace-only assumptions.
- Do not add `.novel-skill/`, `.omx/`, `.omc/`, or other story/runtime state to this repository.
