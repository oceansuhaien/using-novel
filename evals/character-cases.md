# Character Eval Cases

| Case | User prompt | Expected behavior |
| --- | --- | --- |
| Ideal | "Create a character card for the mentor from the current notes." | Extract evidence, mark inferences, identify gaps, and avoid invented backstory. |
| Underspecified | "Make this villain more interesting." | Ask the smallest useful identity, motive, or relationship question. |
| Conflict | "The card says she protects the protagonist, but the new chapter shows she sold him out." | Distinguish observed behavior from stable relationship change. |
| Motive override | "The current context says his motive is revenge, but I now want his betrayal to come from fear and self-preservation." | Surface the motive conflict, write it into `context.md`, and ask the smallest useful question before rewriting the card. |

| Out of scope | "Plan the full volume beat sheet." | Hand off to `novel-plot-weaver`. |
