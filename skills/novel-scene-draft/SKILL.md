---
name: novel-scene-draft
description: 用于根据已经规划好的场景切片清单 slice.yaml 写场景初稿。适用于"按这个切片写初稿"、"plan-slice 定好了，开始写"、"给这场戏写个 v001"等场景初稿请求。输入只读 slice 里列出的字段，输出 vNNN-draft.md 到版本链 + 同步工作台。不负责润色、扩写、重写。
---

# 场景初稿写手

## 作用

基于 `novel-scene-plan-slice` 产出的 `drafts/chapters/<scene>.slice.yaml`，写本场 v001-draft。**唯一输入契约是 slice**，不额外读其他文件。

## 核心原则（铁律 1）

环境是输入，行为是输出。写每个角色时，让 ta 按"自己的性格 + 当前状态 + 与在场者的关系 + 当前环境"做出**合理反应**，不替作者替角色拍板。

## 输入规则

**仅读以下内容**（严格按 slice 字段）：

1. `drafts/chapters/<scene>.slice.yaml` — 本次主输入。
2. 对每个 `load.<id>`：
   - `identity` 列出的 section → 读 `characters/<id>.md`（定稿层）或 `drafts/characters/<id>.md`（草稿层，优先）的对应 section。
   - `state: full` → 走 `draft-query.sh characters/<id>/state` 取最新。
   - `relations_with: [其他 id]` → 读对应 `relations.md` 两两条目。
   - `recent_events: N` → 从 state.md 取"最近经历"段最后 N 条。
3. 不读整张 `plot/`、整张 `outline/`、非在场角色的人物卡。

发现 slice 字段不够 → **回调 `novel-scene-plan-slice`**（产 vNNN+1-slice），不硬编补。

## 工作流

1. `draft-query.sh chapters/<scene>.slice` 拿到切片。
2. 按切片 load 清单读字段。
3. 按 `intent.pov`、`intent.goal`、`intent.length_hint` 写正文。
4. **按角色视角写每个人的反应**，不说"他很紧张"，写"他手指发僵、茶杯磕了桌沿"。
5. 首次出场角色用一句内两个识别锚点（关系/身份 + 外在/气质/状态）。
6. 写完自查：人物是否像人、段落是否推进、张力是否比 slice.intent 预期的更强。
7. 走 `draft-write.sh chapters/<scene> draft <tmp-file> --slice-ref <slice-path>` 落盘。

## 写作硬约束

- 默认 2000-3000 字，浮动 ±500。`intent.length_hint` 明确时以它为准。
- 叙述句默认压在 15 字以内（非硬规）；单句不超过 80 字（不卡对白）。
- 去 AI 味：不用"气氛一下子变得微妙""他内心掀起波澜"这类空泛总结句。
- 白描要有落点（动作/视线/声音/环境压迫），不是干瘪"他走了她笑了"。
- 对白必须满足其一：推进剧情 / 增张力 / 完过渡 / 暴露关系 / 暴露当下状态。
- 能一笔写透，不用三笔。
- 不写散文腔、作者腔评语、华丽修辞连发。

## 强制模式

如果 slice 的 `forced: true`：

- 按 `intent` 原样写，即使与性格/关系/状态矛盾。
- 正文末尾**必须**附 `## 合理性偏离说明`，3-5 条，列出冲突项与建议回补方案。少于 3 条 → 这不算真正偏离；多于 5 条 → 应改走 rewrite 循环而非 forced。
- 落盘走 `draft-write.sh chapters/<scene> forced <tmp-file> --forced --forced-directive "<原始指令>"`。

## 按需读取

- `../novel-draft-system/references/snapshot-schema.md` — 快照 yaml 字段与强制模式要求。
- `../novel-scene-polish/references/tomato-style-checklist.md` — 番茄文气味检查清单（初稿交稿前自查也可用）。

## 不做的事

- 不润色自己写的初稿（那是 `novel-scene-polish`）。
- 不扩写（那是 `novel-scene-expand`）。
- 不重写结构（那是 `novel-scene-rewrite`）。
- 不改 slice（回调 plan-slice 让它改）。
- 不回写 `characters/<id>/state.md`（定稿后由 draft-finalize 触发）。
- 不擅自读 slice 之外的字段（token 会爆）。

## 自检

- 每个角色的行为是否能从 "性格 + 状态 + 关系 + 环境" 推出来？
- 对白是否每句都"只有这个人在这个情境才会说"？
- 首次需要识别的角色是否一句内给了两个锚点？
- 去 AI 味是否到位，没有总结腔？
- 字数是否在目标区间？
- 是否只用了 slice 列出的字段？
