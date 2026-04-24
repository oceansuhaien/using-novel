# 小说架构契约

小说架构资料保存单本书的故事开发结论。除非用户明确指定其他结构，默认按下列模块组织；这些模块可以是目录、文档区块或用户指定的其他载体，不再绑定到固定隐藏目录。

```text
summary.md
outline/
  premise.md
  volumes.md
  worldbuilding.md
plot/
  mainline.md
  hidden-threads.md
  foreshadowing.md
  beats.md
  volume-hooks.md
characters/
  index.md
  cards/
  relationships/
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

## 文件分工

- `summary.md`：高层稳定状态、当前结论、开放问题、最近确认的关键变化。
- `context.md`：共享决策日志，记录多轮确认、冲突、覆盖依据与待用户确认问题，不替代领域文件。
- `outline/`：题材定位、前提、故事骨架、卷纲、长期大纲。
- `plot/`：主线、暗线、伏笔、反转、剧情节点、阶段目标、卷钩子。

- `characters/`：人物卡、人物总表、关系网、人物弧线、秘密、人物绑定规则。
- `canon/`：世界规则、势力、地点、时间线、系统机制、稳定背景事实。
- `chapters/`：章节级观察、摘录、证据、临时笔记。
- `inbox/`：原始灵感、备选方案、未拍板问题、尚未确认的材料。

## 存放规则

- 稳定高层结论进 `summary.md`。
- 细节进更具体的目录，不要污染 `summary.md`。
- 章节片段不是自动 canon，除非用户确认或多处稳定资料支持。
- 未拍板方案进 `inbox/`，不要写成定稿。
- 一个结论横跨多个目录时，以最窄主目录为主，只把摘要同步到 `summary.md`。
