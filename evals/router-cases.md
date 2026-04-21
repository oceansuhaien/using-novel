# Router Eval Cases

Use these cases to check `novel-driver:using-novel`.

| Case | User prompt | Expected route | Expected first move |
| --- | --- | --- | --- |
| Idea only | "I have a premise about a cursed academy. Help me shape it." | `novel-outline-coach` | Extract premise, reader promise, and first structural gap. |
| Plot repair | "The middle of volume 1 has no momentum. Help me fix the beats." | `novel-plot-weaver` | Identify phase goal, conflict, and beat-chain gap. |
| Character extraction | "Make a character card for the antagonist from my notes." | `novel-character-card-coach` | Gather evidence and separate confirmed facts from pending decisions. |
| Outline plus plot | "Build the premise and then give me the first volume hook chain." | `novel-outline-coach` then `novel-plot-weaver` | Stabilize premise before beat design. |
| Plot plus character | "This betrayal beat depends on whether the mentor really cares about the protagonist." | `novel-plot-weaver`, or `novel-character-card-coach` first if motivation is the blocker | Decide whether plot causality or character motive is the active blocker. |
| Prose request | "Write the polished chapter scene." | Nearest prep skill only if planning is needed | Explain that prose drafting is not a dedicated plugin lane yet. |
| Evidence-sensitive | "Do not invent facts. Sort only what is already in the files." | Relevant domain skill with evidence discipline | Use confirmed fact / inference / pending labels. |
