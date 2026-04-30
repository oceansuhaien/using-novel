---
name: novel-scene-rewrite
description: 用于允许改事件顺序、角色决定、场景结构的场景重写。适用于"老周不该这么直接，整个对峙段重写"、"这场戏让他不出现试试"、"换个地点重写"、"让她这里拒绝"这类需要改变场景主干的请求。会重跑切片推理，产出 vNNN-rewrite.md 到版本链；不自动覆盖工作台，等作者对比 v(N-1) 和 v(N) 后显式同步。
---

# 场景重写

## 作用

当作者需要改**事件顺序 / 角色决定 / 场景结构 / 在场人物**时使用。和 draft 一样走"环境是输入，行为是输出"的推理，但基于作者给出的新意图重做一遍。

## 核心原则（铁律 1 + R5）

- **重跑切片**：rewrite 不能基于旧 slice 硬改，因为角色会按"新意图 + 新环境"做出不同反应。读旧 slice → 按作者新意图改动必要字段 → 产出新 slice 版本 → 用新 slice 写正文。
- **不自动覆盖工作台**（R5 例外）：产物只进版本链快照，让作者对比 v(N-1) 和 v(N) 后用 `draft-sync.sh` 确认同步。这是 rewrite 相对 draft 的额外保险。

## 输入规则

1. 工作台 `drafts/chapters/<scene>.md`（上一版正文，用于对比参考）。
2. 旧 slice：`draft-query.sh chapters/<scene>.slice`。
3. 作者本轮的重写意图（必读，决定改什么）。
4. 按新 slice 的 load 清单读字段（同 draft 的输入规则）。

## 工作流

1. **读作者意图**，判断属于哪类改动：
   - 改角色决定（"让她拒绝"）。
   - 改事件顺序（"先冲突再见面"）。
   - 改场景结构（"换个地点"/"加一个人"）。
   - 改 pov（"换成老周视角看这场"）。
2. **回调 `novel-scene-plan-slice`** 让它产出新 slice（vNNN+1-slice），把意图转成结构化环境变更。
3. **按新 slice 写正文**，走 draft 同样的推理方式。
4. `draft-write.sh chapters/<scene> rewrite <tmp-file> --slice-ref <新 slice 路径> --note "<重写原因>"` → 产物只进版本链，**工作台保留原状**。
5. **向作者呈现对比要点**："本版相对 v(N-1) 的关键改动：<A / B / C>"。提示作者用 `draft-sync.sh chapters/<scene> <新版号>` 确认。

## 硬约束

- 必须先回调 plan-slice 产新 slice（除非作者明确说"只改某一句话"——那该走 polish）。
- 禁止把 rewrite 退化成 polish（改字句不改事件）。如果改动小 → 引导作者转 polish/expand。
- **不设字数硬上限**。长度服务新意图、新节奏、新张力曲线；与原稿差异无上下限，允许大幅偏离（重写本职）。
- 文风与 draft 一致：番茄网文 × 小说大神手感——画面感 / 张力 / 情绪。详见 `../novel-scene-polish/references/prose-style-guide.md`。
- 强制模式（slice.forced=true）的 rewrite 也要附 `## 合理性偏离说明`。

## 与 draft 的区别

| 维度 | draft | rewrite |
|------|-------|---------|
| 触发 | 场景从无到有 | 场景已有但要重做 |
| slice | 全新产出 | 基于旧 slice 改 |
| 工作台同步 | 自动 | **不自动**，作者确认后 sync |
| 长度 | 服务节奏/情绪/张力，不设硬上限 | 服务新意图，不设硬上限，允许大幅偏离原稿 |

## 回报形态

产出 + "本版相对 v(N-1) 的关键改动" + "如接受，请运行：`bash scripts/draft-sync.sh chapters/<scene> <ver>`"。

## 按需读取

- `../novel-scene-polish/references/prose-style-guide.md` — 番茄网文 × 小说大神风格指南（画面感/张力/情绪 × 文笔手感）。
- `../novel-draft-system/references/snapshot-schema.md` — rewrite 快照头与 slice_ref 字段。

## 不做的事

- 不改字句（polish）。
- 不加细节（expand）。
- 不跳过 plan-slice 回调。
- 不自动覆盖工作台。
- 不回写 state.md（finalize 才触发）。

## 自检

- 是否回调 plan-slice 产了新 slice？
- 新版角色行为是否能从"新意图 + 新切片"推出？
- 是否比 polish/expand 确实改动了更本质的东西？
- 产物是否只进了版本链、工作台未被覆盖？
- 对比要点是否说清了相对 v(N-1) 改了什么？
