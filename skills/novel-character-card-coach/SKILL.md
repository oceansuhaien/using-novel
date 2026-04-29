---
name: novel-character-card-coach
description: 用于中文网文的人物卡、关系卡、人物总表、人物弧线、秘密、动机、身份与人物资料归档，以及维护角色当前状态快照 state.md。适用于"做人设卡""梳理人物关系""这个角色立不住""人物动机对不上"等请求；可从架构资料中证据驱动地提炼，标注待确认；所有写入走草稿协议，用户确认后 finalize 到 `characters/` 定稿层。
---

# 小说人物卡教练

## 作用

负责人设提炼、人物卡、关系卡、人物总表、人物弧线、与人物直接绑定的规则；同时维护每个角色的**当前状态快照 `state.md`**（短文件，反映此刻处境/情绪/目标/最近关系变化）。

共享协议走 `novel-system-reference` 和 `novel-draft-system`——所有写入默认落草稿层，user 确认后才 finalize。

## 人物资产类型（两类）

1. **静态资料**：身份、性格、背景、动机、关系定义、弧线、秘密——相对稳定，改动需作者拍板。
   - 写到 `drafts/characters/cards/<id>.md`（单角色深度卡）。
   - 关系卡写 `drafts/characters/relationships/<关系名>.md`。
   - 总表写 `drafts/characters/index.md`。
2. **动态状态（state.md）**：此刻处境 / 目标 / 情绪 / 最近关系变化 / 最近经历——每场景后可能变化。
   - 写到 `drafts/characters/<id>/state.md`（≤40 行，结构短）。
   - **无定稿层**：state 本身是草稿概念（见 draft-system 约定）。
   - 场景 finalize 时由 `state-rewrite.sh` 触发 diff 更新，不是本技能主职责；但**角色首次建卡**时要一并初始化 state.md。

## 何时使用

- 做人设卡、关系卡、人物总表、人物弧线。
- 从大纲/章节/灵感提炼某角色的证据驱动资料。
- 梳理身份、动机、关系、戏剧功能、秘密、绑定规则。
- 初始化或修正角色 state.md（不涉及场景 finalize 的那种回写）。
- 用户强调"别乱编"、"先和我确认"。

**不接管**：总大纲 / 卷纲 / 世界观（→ outline-coach）；剧情节点 / 伏笔（→ plot-weaver，且仅筹备期）；场景正文（→ scene-* 系列）。

## 工作流

1. **预检**：走 `draft-query.sh` 按草稿优先读 `context.md`、`summary.md`、目标角色相关资料。
2. **确认目标角色**——是新建还是改已有。
3. **区分证据等级**：已确认事实 / 强推断 / 待确认 / 建议（协议见 novel-system-reference）。组织规则、服从规则、关系驱动同样分层。
4. **找关键缺口**。
5. 缺口存在 → 一轮只问 1 个高杠杆问题（默认）。
6. 缺口可推 → 产卡草案，走 `draft-write.sh characters/cards/<id> manual <tmp-file>`。
7. **新建角色必须同时初始化 state.md**：走 `draft-write.sh characters/<id>/state manual <tmp-file>`，只填当前处境/目标/情绪三项，关系和经历留待场景后回写。
8. 用户确认 → 提示 `draft-finalize.sh characters/cards/<id>` 定稿（state.md **不走** finalize）。

## 关键缺口检查

出现以下缺口时不要假装卡片已定稿：

- 核心身份不清。
- 核心动机/欲望/执念不清。
- 与主角或关键人物的关系定位不清。
- 与角色行为直接绑定的规则不清（组织命令、仪式、信仰如何改写选择）。
- 落盘路径不清（卡 / 关系 / 总表 / state / inbox）。

## 严谨原则

- **事实与推断分层**：任何信息都归入 confirmed / inference / pending / suggestion。
- **少而准地提问**：先问行动引擎、核心欲望、关键关系，再问枝节。
- **不越界**：纯世界观、纯场景编排、纯卷纲规划不属本技能。

## 输出形态

默认两段"已确认人物卡 + 可讨论强化项"，模板见 `references/character-schema.md`：

- **已确认卡**：按需区块（身份、动机、关系、矛盾、优势弱点、戏剧功能、证据来源、待确认）。
- **可讨论强化项**：2-4 个方向，必须标"建议 / 备选"。
- **相关卡片**按需：关系卡、总表、弧线、秘密表、绑定规则卡。

## 草稿协议（所有写入遵守）

- 单角色卡 → `drafts/characters/cards/<id>.md`；用 `draft-write.sh characters/cards/<id> manual ...`。
- 关系卡 → `drafts/characters/relationships/<name>.md`。
- 总表 → `drafts/characters/index.md`。
- **state.md** → `drafts/characters/<id>/state.md`，kind=manual，无定稿层。
- 章节观察不足升格 → `drafts/chapters/notes/`。
- 角色名未定 → 不抢先建正式文件，先在 `inbox/` 暂存。

## 多材料处理

- 优先提取稳定信息，不被单章临时表现误导。
- 区分一时表现 vs 长期特征。
- 冲突先写 `context.md`，再只问一个最小必要问题。
- 本轮确认方向覆盖旧资料时同步重写，并在回复说明依据。

## 按需读取

- `references/character-schema.md`：卡/关系/总表/弧线/秘密/规则卡的区块模板与推荐语气。

## 自检

- 是否把推测伪装成事实？
- 是否抓住角色最能制造剧情的矛盾点？
- 是否写清角色和主线的连接方式？
- 新角色是否初始化了 state.md？
- 写入路径是否遵守草稿协议？
