# 小说架构契约

小说架构资料保存单本书的故事开发结论。除非用户明确指定其他结构，默认按下列模块组织；这些模块可以是目录、文档区块或用户指定的其他载体。

## 定稿层（已 finalize 的正式结论）

```text
summary.md
context.md
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
  cards/<id>.md
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

## 草稿层（`drafts/`，由 novel-draft-system 管理）

```text
drafts/
  outline/ plot/ characters/ canon/ chapters/
    <asset>.md                         # 工作台（当前活跃版本副本）
    <asset>.drafts/vNNN-<kind>.md      # 版本链（只读快照）
  characters/<id>/state.md             # 角色当前状态快照（无定稿层）
  characters/<id>/state.drafts/        # state 历史快照
  chapters/<scene>.slice.yaml          # 场景切片清单（plan-slice 产出）
.draft-index.yaml                       # 草稿索引（由脚本维护）
```

查询顺序固定：`drafts/<asset>.md` → `<asset>.drafts/` 最新 vNNN → 定稿层 `<asset>.md`。细节见 `novel-draft-system/references/path-layout.md`。

## 文件分工

- `summary.md`：高层稳定状态、当前结论、开放问题、最近确认的关键变化。
- `context.md`：共享决策日志，记录多轮确认、冲突、覆盖依据与待用户确认问题。
- `outline/`：题材定位、前提、故事骨架、卷纲、长期大纲。
- `plot/`：主线、暗线、伏笔、反转、剧情节点、阶段目标、卷钩子（**仅筹备期**；正文阶段角色行为由 scene-* 系列自主推出，不回落 plot 脚本）。
- `characters/`：人物卡、总表、关系网、弧线、秘密、绑定规则。
- `canon/`：世界规则、势力、地点、时间线、系统机制、稳定背景事实。
- `chapters/`：章节级观察、摘录、临时笔记。
- `inbox/`：原始灵感、备选方案、未拍板问题、尚未确认的材料。

## 存放规则

- 稳定高层结论进 `summary.md`（经草稿协议工作台）。
- 细节进更具体的目录。
- 章节片段不是自动 canon，除非用户确认或多处稳定资料支持。
- 未拍板方案进 `inbox/`，不要写成定稿。
- 一个结论横跨多个目录时，以最窄主目录为主，摘要同步到 `summary.md`。
- **所有 AI 写入默认落草稿层**，finalize 才进定稿层。细节见 `novel-draft-system/SKILL.md`。
