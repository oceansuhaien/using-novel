---
name: novel-system-reference
description: 中文网文技能的共享参考。用于需要小说架构契约、证据等级、跨文档同步策略、回写边界、事实来源优先级时；供大纲、剧情、人物技能引用，不作为默认创作入口。版本历史/草稿/finalize/rollback 等流程协议由 `novel-draft-system` 管理，本技能不重复维护。
---

# 小说系统参考

`novel-driver` 的共享规则层，不是面向用户的默认创作入口。与 `novel-draft-system` 分工：

- **novel-system-reference**（本技能）：架构契约、证据等级、跨文档同步、决策日志、偏好记忆。
- **novel-draft-system**：草稿/工作台/版本链/finalize/rollback/状态回写。

当任务涉及以下问题时读取本技能或它的参考文件：

- 小说架构资料应该如何组织。
- 什么能写成已确认 canon，什么只能写成推断、待定或建议。
- 一个领域确认后是否可以同步更新其他目录。
- `summary.md` 与详细子目录之间如何分工。
- 多轮讨论后的关键确认、冲突、覆盖历史应该如何记录。
- 作者级偏好经验与单书级推理规则应该如何区分。

## 按需读取

- 目录与文件位置：`references/directory-contract.md`
- 证据等级与冲突处理：`references/evidence-levels.md`
- 跨文档同步策略：`references/sync-policy.md`
- 上下文决策日志协议：`references/context-log-protocol.md`
- 偏好记忆协议：`references/preference-memory-protocol.md`

不要把完整参考文件粘贴给用户。只应用相关规则，并在需要时说明受影响路径。

## 共享原则

- `summary.md` 只放高层稳定状态，不堆长人物卡、章节摘录或剧情细表。
- 详细资料写入最窄且最匹配的子目录。
- 已确认改动清楚影响其他文件时可以在同一轮同步修正。
- 建议、推断和待确认问题必须显式标注，不能伪装成事实。
- 新确认方向覆盖旧资料时可以重写，但要说明依据。

## 已被 novel-draft-system 替代的协议

下列旧协议（V1 使用）在 V2 被 `novel-draft-system` 的草稿/版本链机制整体取代，不再单独维护文档：

- **改稿分支协议** → 版本链 + `draft-rollback.sh`：每次改写自然落快照，回滚即分支回退，无需单独的分支目录。
- **受影响文件包协议** → 多个 asset 按草稿协议逐个推进 finalize：每次改写只动相关 asset 的工作台；finalize 逐个确认，整批确认等于"整包合并"。
- **正文执行审计** → 每个快照 yaml 头的 `kind / from_ver / slice_ref / author_note / forced / timestamp`：不再让 AI 手写 `scene-audit-*.md`。

如果看到仍在引用这些旧文件名，说明该处待更新到 V2 约定。
