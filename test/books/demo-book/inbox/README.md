# inbox/ — 作者投递区

本目录用于作者手动投递**外部草稿、原始灵感、未解决问题**。它不是定稿层，也不是草稿工作台；它是进入草稿系统**之前**的中转站。

## 常见用法

### 1. 外部草稿导入（最常见）

作者把自己手打的章节正文放到 `inbox/<任意文件名>.md`，然后对 AI 说：

> 帮我把 `@inbox/第七章草稿.md` 导入为 ch007，去 AI 味、稍微加点环境描写。

AI（通过 `using-novel` 的 import 路由）会：

1. 调 `bash scripts/draft-write.sh chapters/ch007 manual inbox/第七章草稿.md --source imported --note "imported from inbox/第七章草稿.md"`。
   - 版本链：`drafts/chapters/ch007.drafts/v001-manual.md`
   - 工作台：`drafts/chapters/ch007.md`
   - 头部自动带 `source: imported` 标记。
2. 按作者同一句里的二级意图继续路由到 `scene-polish` / `scene-expand` / `scene-rewrite`。

**关键保证**：`scene-polish` / `scene-expand` 的硬红线决定了导入稿不会被 AI 擅自改事件、改角色决定、加新场景。只有在作者明确说"重写"时才走 `scene-rewrite`。

### 2. 原始灵感池

随手记的设定碎片、人物闪念、剧情点子，走 `raw-ideas.md`。后续由 outline / plot / character coach 按需消化。

### 3. 未解决问题

卡点、待决策清单，走 `unresolved-questions.md`。

## 不做的事

- 不直接写进 `chapters/` 定稿层（那由 finalize 触发）。
- 不直接写进 `drafts/` 工作台（那由 `draft-write.sh` 管）。
- 不把这里的文件当"备份"——它们随时可能被作者重写或删除。
