---
name: novel-draft-system
description: 小说草稿版本系统的共享协议。用于约束所有小说资产（大纲/人物卡/剧情节点/场景正文/角色状态等）的草稿层写入、版本链命名、三层查询顺序、finalize 定稿、rollback 回滚、状态回写流程；供 using-novel、novel-book-scaffold、novel-outline-coach、novel-character-card-coach、novel-plot-weaver 以及 novel-scene-* 系列技能引用，不作为默认创作入口。
---

# 小说草稿版本系统

本技能是 `novel-driver` 的共享协议层，不是面向用户的默认入口。**任何写入小说仓库的文件都应遵守本协议**。

## 核心铁律

1. **一切皆草稿**：AI 写入的所有小说文件默认落草稿层。只有作者明确 finalize 才转定稿。
2. **三层查询**：读任何小说资产固定顺序 — `drafts/<X>.md` → `<X>.drafts/` 最新 vNNN → 定稿层 `<X>.md`。三层都没有 → 明确 miss，不允许猜测。
3. **版本链连续递增**：版本号 vNNN 跨 kind 连续递增；从文件名一眼看到"第几版 + 哪种操作产出"。

## 路径与文件形态

- `drafts/<category>/<asset>.md` — **工作台**，当前活跃版本的副本，可读可写。
- `drafts/<category>/<asset>.drafts/vNNN-<kind>.md` — **版本链**，只读快照。
- `<category>/<asset>.md` — **定稿层**，仅在 finalize 后更新。

## 快照命名与元数据

文件名：`vNNN-<kind>.md`。kind 白名单：`draft | polish | expand | rewrite | manual | finalized | forced | slice`。

每个快照头部必须有 yaml：

```yaml
---
ver: 3
kind: rewrite
from_ver: 2
slice_ref: chapters/ch007.slice.drafts/v001-slice.md
author_note: "重写对峙段，让老周更保守"
timestamp: 2026-04-28T15:30:00Z
forced: false
---
```

## 写入协议（硬协议）

默认：先写 `vNNN-<kind>.md` 到版本链，再同步覆盖工作台。两步原子，由 `scripts/draft-write.sh` 保证，不允许 AI 只写一边。

**rewrite 例外**：rewrite 产物先进版本链快照，**不自动覆盖工作台**，等作者对比 v(N-1) 和 v(N) 确认后再同步。用 `scripts/draft-sync.sh <asset> <ver>` 显式同步。

## finalize 流程

由作者触发 `/finalize <asset>` 或等价自然语言。调用 `scripts/draft-finalize.sh <asset>`：

1. 读当前工作台 `drafts/<asset>.md`。
2. 复制到定稿层 `<asset>.md`。
3. 版本链补写 `vNNN-finalized.md` 锚点。
4. 若 asset 属于 `chapters/` → 触发状态回写（见下）。
5. 更新 `.draft-index.yaml`。

## rollback 流程

触发 `/rollback <asset> <vNNN>` 或等价自然语言。调用 `scripts/draft-rollback.sh`：

- 把 `vNNN-*.md` 内容复制回工作台。
- 不删除后续版本，历史保留。
- 下次新操作从 max(ver)+1 编号。

## 状态回写（角色 state.md 的 diff 协议）

仅在 finalize 场景/章节时触发，**每个在场角色逐一由作者确认**：

1. 脚本读刚定稿正文 + 它的 slice.yaml，提取在场角色列表。
2. 调用 LLM 输出每个在场角色 `state.md` 的 diff 建议（不是整文件重写）。
3. 作者逐角色确认/修改/跳过。
4. 确认后应用 diff，旧 state.md 进 `state.drafts/vNNN-manual.md`。
5. **forced:true 的场景不触发自动回写**，需作者显式 `/rewrite-state <scene>` 触发。

## 强制后门

作者使用 `@force:` 或等价自然语言时，AI 按指令写但必须标记 `forced: true`、附合理性偏离说明、不触发自动状态回写。详见 `references/snapshot-schema.md` 的"强制模式额外要求"。

## .draft-index.yaml

书籍根维护一份索引，由脚本增量维护（**AI 禁止直接编辑**）。forced 占比 >15% 时脚本发 warning。格式详见 `references/path-layout.md`。

## 按需读取

详细规则按需读 `references/`：

- `references/path-layout.md` — 草稿层目录契约、迁移规则。
- `references/snapshot-schema.md` — 快照 yaml 字段全集与示例。
- `references/finalize-flow.md` — finalize / rollback / 状态回写的完整步骤。
- `references/scripts-usage.md` — 所有 bash 脚本的输入输出和退出码。

## 不要做的事

- 不要绕过 `scripts/draft-write.sh` 直接写工作台或版本链。
- 不要在 AI 对话里手动编辑 `.draft-index.yaml`。
- 不要把整张 state.md 重写后交给作者看——永远用 diff 呈现。
- 不要把 forced 占比写进 `context.md`，它只属于索引。
