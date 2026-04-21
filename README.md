# Novel Driver

`novel-driver` is an installable Codex plugin for Chinese webnovel development workflows.

It routes outline, plot, character, and shared canon-policy work through focused skills without treating a story workspace as part of the plugin itself.

## Install

Clone the repository into a directory where you keep local plugins:

```powershell
git clone <repo-url-or-local-path> C:\path\to\plugins\novel-driver
```

Register it as a local plugin source in your marketplace configuration:

```json
{
  "plugins": [
    {
      "name": "novel-driver",
      "source": {
        "source": "local",
        "path": "C:/path/to/plugins/novel-driver"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Writing"
    }
  ]
}
```

## Commands

- `/using-novel`: route a mixed or unclear novel-development request
- `/novel-outline`: work directly on premise, outline, volume plan, and canon structure
- `/novel-plot`: work directly on beats, suspense, reversals, and hidden threads
- `/novel-character`: work directly on character cards, relationships, arcs, and rosters

## Repository Layout

```text
novel-driver/
|- .codex-plugin/          plugin metadata
|- assets/                 icons and display assets
|- commands/               thin command adapters
|- evals/                  manual regression cases
|- scripts/                validation and sync helpers
|- skills/                 skill source of truth
|- AGENTS.md               plugin maintenance rules
|- CLAUDE.md               Claude-facing adapter
|- README.md               installation and development guide
```

## Development

Validate plugin structure:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate.ps1
```

List manual eval cases:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\run-evals.ps1
```

Preview a one-way mirror into another skill directory:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-to-codex-skills.ps1 -TargetRoot C:\path\to\skills-mirror
```

Apply the mirror intentionally:

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-to-codex-skills.ps1 -TargetRoot C:\path\to\skills-mirror -Apply
```

## Non-goals

- This is not a story project repository.
- This repository does not own `.novel-skill/` story data.
- This repository does not carry `.omx` or `.omc` runtime state.
- `.codex/skills/` mirrors are generated artifacts, not the authoring source.
