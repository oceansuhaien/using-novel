# Cross-Document Sync Policy

When the user confirms a change in one novel domain, update every materially affected `.novel-skill/` file in the same turn if the implication is clear.

## Allowed Propagation

- Outline changes may propagate into plot, character, canon, chapter notes, inbox, and summary files.
- Plot changes may propagate into outline, character, canon, chapter notes, inbox, and summary files.
- Character changes may propagate into plot, outline, canon, chapter notes, inbox, and summary files.

## Boundaries

- Keep the active skill's domain as the entrypoint. Do not turn a plot task into a full character-card task unless the user asks or the blocker requires it.
- Do not invent lore for flavor. Fill gaps only when the confirmed direction clearly requires downstream repair.
- Do not require a separate permission gate for every dependent file when the user has already confirmed the governing change.
- Surface major inferred changes in the response so the user can correct course.
- If a conflict changes the user's task intent or cannot be resolved from the confirmed direction, ask a focused question before writing.

## Writeback Rule

Write stable conclusions to the narrowest durable location. Mirror only concise high-level consequences into `summary.md`.
