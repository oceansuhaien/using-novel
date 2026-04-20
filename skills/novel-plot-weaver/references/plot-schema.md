# Plot Schema

Use this file when deciding where confirmed plot material should live under `.novel-skill/plot/`.

## Directory Contract

```text
.novel-skill/
  plot/
    mainline.md
    hidden-threads.md
    foreshadowing.md
    beats.md
    volume-hooks.md
```

## File Responsibilities

### `mainline.md`

Store only stable mainline information:

- story-stage objective
- visible conflict
- opposition force
- mainline progression chain
- major irreversible turns

Do not dump every brainstorm branch here.

### `hidden-threads.md`

Store:

- hidden agendas
- delayed reveals
- pressure lines running beneath the visible plot
- how each hidden thread eventually collides with the mainline

For each thread, prefer this shape:

- thread name
- current hidden state
- reveal trigger
- reveal window
- impact on mainline

### `foreshadowing.md`

Store:

- what is being planted
- where it is planted
- what future payoff it prepares
- what conditions must be met before payoff
- whether it is already paid off

Prefer table-like scanability over prose walls.

### `beats.md`

Store:

- major beats
- escalation points
- reversals
- fallout
- beat-to-beat causal links

Use this file when the user is discussing "what happens next" more than "what the story means overall."

### `volume-hooks.md`

Store:

- current volume goal
- end-of-volume explosion
- unresolved question handed to next volume
- hook promise for the next stage

## Routing Rules

- Stable high-level overview still belongs in `.novel-skill/summary.md`.
- Temporary, unconfirmed possibilities belong in `.novel-skill/inbox/`.
- Chapter-specific observations belong in `.novel-skill/chapters/notes/`.
- If a conclusion is still blocked by a character fact not yet confirmed, note the dependency instead of upgrading it into plot canon.
