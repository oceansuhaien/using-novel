---
name: novel-system-reference
description: 中文网文技能的共享参考。用于需要小说架构契约、证据等级、跨文档同步策略、回写边界、事实来源优先级时；供大纲、剧情、人物技能引用，不作为默认创作入口。
---

# 小说系统参考

本技能是 `novel-driver` 的共享规则层，不是面向用户的默认创作入口。

当小说任务涉及以下问题时读取本技能或它的参考文件：

- 小说架构资料应该如何组织。
- 什么能写成已确认 canon，什么只能写成推断、待定或建议。
- 一个领域确认后，是否可以同步更新其他目录。
- `summary.md` 与详细子目录之间如何分工。
- 多轮讨论后的关键确认、冲突、覆盖历史应该如何记录。
- 作者级偏好经验与单书级推理规则应该如何区分。
- 已落盘正文返工时，主线与改稿分支应如何区分。
- 大改稿时应如何定义受影响文件包。
- 正文生成后的执行证据应该落在哪里，哪些能进共享日志，哪些不能。

## 按需读取

- 目录与文件位置：`references/directory-contract.md`
- 证据等级与冲突处理：`references/evidence-levels.md`
- 跨文档同步策略：`references/sync-policy.md`
- 上下文决策日志协议：`references/context-log-protocol.md`
- 偏好记忆协议：`references/preference-memory-protocol.md`
- 改稿分支协议：`references/rewrite-branch-protocol.md`
- 受影响文件包协议：`references/affected-file-package-protocol.md`
- 正文执行审计也走 `references/context-log-protocol.md`，不要在入口技能里另抄一份。


不要把完整参考文件粘贴给用户。只应用相关规则，并在需要时说明受影响路径。

## 共享原则

- `summary.md` 只放高层稳定状态，不堆长人物卡、章节摘录或剧情细表。
- 详细资料写入最窄且最匹配的子目录。
- 已确认改动如果清楚影响其他文件，可以在同一轮同步修正。
- 建议、推断和待确认问题必须显式标注，不能伪装成事实。
- 当新确认方向覆盖旧资料时，可以重写旧资料，但要说明依据。
- 正文执行审计属于章节级执行证据，不是 `context.md` 或 `summary.md` 的默认正文。
