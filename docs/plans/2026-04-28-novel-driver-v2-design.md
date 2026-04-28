# Novel Driver v2 — 重构设计

> 日期：2026-04-28  
> 状态：已与作者完成 9 节逐节确认，待进入实现

---

## 0. 决策总览

| # | 分叉 | 选择 |
|---|------|------|
| Q1 | 架构模式 | C — Agentic Workflow（流水线骨架 + 关键节点嵌 agent 推理） |
| Q2 | 草稿粒度 | B — 快照式草稿（工作台 + 版本链目录） |
| Q3 | 角色切片 | B + 轻量 C（场景驱动切片 + 每角色一份 state.md） |
| Q4 | 创作循环 | B — 五步（plan-slice → draft → polish → expand → rewrite → finalize） |
| Q5 | 跨平台 | B — SKILL.md 单一事实源 + 两份平台清单脚本生成 |
| Q6 | 筹备接入 | B — 全仓统一草稿协议 + novel-draft-system 共享技能 |

---

## 1. 核心哲学与铁律

写小说像上帝造世界。作者不直接命令角色"做什么"，而是搭建环境、推演事件、投放人物，让角色按自己的性格、身份、关系、当前状态，在这个环境里做出合理反应。

### 铁律 1：环境是输入，行为是输出；作者强制指令例外但留痕

- 默认模式：AI 严禁接受"让 A 此刻做 B"的命令式输入 → 引导作者改写为"改环境"或"加事件"。
- 强制后门：作者使用 `@force:` 或等价自然语言时，AI 按指令写，但必须：
  1. 草稿 yaml 头记录 `forced: true` + 原始指令。
  2. 草稿末尾附 `## 合理性偏离说明`（3-5 行），列出与哪些设定不一致、建议如何回补。
  3. 不自动回写 `state.md`，等 finalize 时由作者决定是否吸收。

### 铁律 2：一切皆草稿，定稿需拍板

AI 写入的所有小说文件默认落草稿层。只有作者明确 finalize 才转定稿。查询顺序固定：草稿 → 快照 → 定稿。

### 铁律 3：Skill 短、协议集中、事实唯一

每个 SKILL.md ≤100 行，reference ≤150 行。共享协议只住在一个共享 skill 里，其他 skill 引用。SKILL.md frontmatter 是跨平台唯一事实源。

---

## 2. 仓库结构

### 插件仓库（本仓库根）

```
novel-driver/
├── .codex-plugin/plugin.json         # Codex 清单（保留）
├── .claude-plugin/plugin.json        # Claude Code 清单（新增，脚本生成）
├── commands/                          # 斜杠命令适配层（极薄）
├── skills/                            # SKILL.md 唯一事实源
├── scripts/                           # 全部 bash（不保留 .ps1）
│   ├── generate-readme.sh
│   ├── generate-manifests.sh          # 生成两份平台清单
│   ├── quick-validate.sh
│   └── sync-to-codex-skills.sh
├── test/books/<book-id>/
├── AGENTS.md / CLAUDE.md / README.md
```

### 书籍工作区

```
<book-root>/
├── summary.md                         # 定稿：高层稳定结论
├── context.md                         # 定稿：决策/冲突/待确认
├── outline/ plot/ characters/ canon/ chapters/   # 定稿层
├── drafts/                            # 草稿层 ★
│   ├── outline/ plot/ characters/ canon/ chapters/
│   ├── characters/<id>/state.md       # 角色当前状态快照
│   └── chapters/<scene>.drafts/       # 版本链（v001/v002...）
├── inbox/                             # 原始灵感/素材
└── .draft-index.yaml                  # 草稿索引（脚本维护）
```

关键约定：
- 查询顺序：`drafts/<X>.md` → `<X>.drafts/` 最新快照 → 定稿层 `<X>.md`。
- finalize 时：工作台 → 定稿层 + 版本链补 `vNNN-finalized.md` 锚点。
- `.drafts/` 历史快照不进 git（.gitignore 排除），`drafts/` 主工作区进 git。
- `state.md` 住 `drafts/characters/<id>/state.md`（当前状态本身是草稿）。

---

## 3. Skill 拓扑

9 个 skill，三层。

### 入口层（1）

| Skill | 行数目标 | 说明 |
|-------|---------|------|
| `using-novel` | ≤80 | 路由 + 意图识别 + 开工预检。不再复述任何共享规则。 |

### 共享协议层（2）

| Skill | 行数目标 | 说明 |
|-------|---------|------|
| `novel-system-reference` | ≤80 | 目录契约、证据等级、同步策略、决策日志、偏好记忆。保留瘦身。 |
| `novel-draft-system` ★ | ≤80 | 草稿/定稿/版本链/快照命名/查询顺序/finalize/rollback/状态回写。 |

### 筹备层（3，保留瘦身）

| Skill | 行数目标 | 说明 |
|-------|---------|------|
| `novel-book-scaffold` | ≤80 | 建书、补目录。适配新 drafts/ 结构。 |
| `novel-outline-coach` | ≤80 | 大纲、主旨、卷纲、世界观。走草稿协议。 |
| `novel-character-card-coach` | ≤80 | 人物卡、关系卡、人物索引。走草稿协议。 |

### 执行层（5 步循环 + 收窄后的 plot-weaver）

| Skill | 行数目标 | 说明 |
|-------|---------|------|
| `novel-scene-plan-slice` ★ | ≤50 | 场景切片规划。输出 yaml 加载清单。 |
| `novel-scene-draft` ★ | ≤80 | 按切片 + 环境写初稿。替代原 novel-scene-writer。 |
| `novel-scene-polish` ★ | ≤60 | 只改语言/节奏/去 AI 味/对白校正。禁改主干事件。 |
| `novel-scene-expand` ★ | ≤60 | 加细节/内心戏/环境描写。禁改主干事件。 |
| `novel-scene-rewrite` ★ | ≤60 | 允许改事件/角色反应/结构。重跑切片推理。产物先进快照，作者对比后再同步工作台。 |
| `novel-plot-weaver` | ≤80 | 职责收窄到筹备期的剧情节点/伏笔/卷钩子设计。 |

★ = 新增。原 `novel-scene-writer` 删除。

finalize 不是 skill，是 `novel-draft-system` 里的共享流程。

---

## 4. 草稿系统协议（novel-draft-system）

### 路径与文件形态

- `drafts/<category>/<asset>.md` — 工作台（当前活跃版本副本，可读写）
- `drafts/<category>/<asset>.drafts/vNNN-<kind>.md` — 版本链（只读快照）
- `<category>/<asset>.md` — 定稿层（finalize 后更新）

### 快照命名

`vNNN-<kind>.md`。kind 白名单：`draft | polish | expand | rewrite | manual | finalized | forced | slice`。

版本号跨 kind 连续递增（v001-draft → v002-polish → v003-rewrite → ...）。

每个快照头部 yaml：

```yaml
ver: 3
kind: rewrite
from_ver: 2
slice_ref: chapters/ch007.slice.drafts/v001-slice.md
author_note: "重写对峙段，让老周更保守"
timestamp: 2026-04-28T15:30:00
forced: false
```

### 查询顺序（硬协议）

① `drafts/<category>/<asset>.md` 存在 → 读它  
② 否则 `<asset>.drafts/` 里最大 vNNN  
③ 否则定稿层 `<category>/<asset>.md`  
三层都没有 → 明确 miss

### 写入协议

先写 `vNNN-<kind>.md` 到版本链，再同步覆盖工作台。原子执行。  
例外：rewrite 产物先进快照，**不自动覆盖工作台**，作者对比后再同步。

### finalize 流程

1. 读当前工作台  
2. 复制到定稿层同名路径  
3. 版本链补 `vNNN-finalized.md` 锚点  
4. 若是场景/章节 → 触发状态回写（见第 5 节）  
5. 更新 `.draft-index.yaml`

### rollback 流程

复制 `vNNN-*.md` 内容到工作台。不删后续版本。下次新操作从最新 N+1 编号。

### .draft-index.yaml

```yaml
assets:
  chapters/ch007:
    current_ver: 4
    last_kind: rewrite
    forced: false
    finalized: true
    finalized_at: 2026-04-28T16:00:00
```

由 bash 脚本维护，AI 不直接编辑。

---

## 5. 场景切片与状态回写

### 切片规划产出物

`drafts/chapters/<scene-id>.slice.yaml`：

```yaml
scene_id: ch007
env:
  time: "入冬第三日清晨"
  place: "清河镇西口茶棚"
  on_stage: [lin_wan, old_zhou, unknown_rider]
  trigger: "马蹄声从北面官道传来"
  ambient: ["雪停未化", "人流稀", "柴火湿"]
load:
  lin_wan:
    identity: [card_head, current_disguise]
    personality: [key_traits_for_tension]
    state: full
    relations_with: [old_zhou]
    recent_events: 3
  old_zhou:
    identity: [card_head]
    state: full
    relations_with: [lin_wan]
    recent_events: 2
  unknown_rider:
    identity: minimal
intent:
  goal: "让林婉第一次意识到老周知道她的真实身份"
  pov: lin_wan
  length_hint: 1800
forced: false
```

- draft/rewrite 的唯一输入契约。
- draft 发现字段不够时可回调 plan-slice 补充一次。
- polish/expand 不重跑 slice，直接基于上一版正文。

### 角色状态快照（state.md）

位置：`drafts/characters/<id>/state.md`，目标 ≤40 行。

```markdown
# 林婉 · 当前状态

## 当前处境
- 伪装身份：药商家女
- 所在地：清河镇西口茶棚

## 当前目标
- 短期：找到失踪的信使
- 长期：查明父亲死因

## 当前情绪/身体状态
- 警觉：刚发现有人跟踪

## 最近关系变化
- 老周：发现他知道真实身份（ch007）

## 最近经历
- ch006：在镇外树林遇伏
- ch005：收到匿名信
```

旧状态自动进 `state.drafts/vNNN-*.md`。当前 state.md 永远保持短。

### finalize 时的状态回写

1. 读定稿正文 + slice.yaml
2. LLM 输出每个在场角色 state.md 的 diff 建议
3. **每个角色逐一由作者确认**
4. 确认后应用 diff，旧 state.md 进 state.drafts/
5. 强制模式（forced=true）不触发自动回写，需作者显式触发

### 关系网懒加载

- 静态关系定义：`characters/<id>/relations.md`（定稿层，不常变）
- 动态关系变化：各角色 `state.md` 里"最近关系变化"（≤5 条）
- plan-slice 按 `relations_with: [在场者]` 过滤，只读本场两两关系
- 单场上下文关系加载量 ∝ 同场人数²，非全书人数²

---

## 6. 五步循环数据流

典型对话（ch007 从 0 到定稿）：

| 步骤 | 作者动作 | 系统行为 | 产物 |
|------|---------|---------|------|
| T1 | "写第 7 章，主角到茶棚..." | using-novel → plan-slice | slice.yaml v001 |
| T2 | "可以，继续" | → draft | v001-draft.md + 工作台 |
| T3 | "对白再自然点" | → polish | v002-polish.md + 工作台 |
| T4 | "加心理活动" | → expand | v003-expand.md + 工作台 |
| T5 | "老周不该这么直接，重写" | → rewrite（重跑 slice） | v004-rewrite.md（快照，不覆盖工作台） |
| T5.5 | "这版好" | 同步 v004 到工作台 | 工作台更新 |
| T6 | "定稿" | finalize + 状态回写 + 补全扫描 | 定稿层 + state diff + index |

意图识别由 `using-novel` 入口集中处理，作者用自然语言不需要记命令。

---

## 7. 跨平台适配

- `SKILL.md` frontmatter（name + description）是唯一事实源，Codex 和 Claude Code 都认。
- `scripts/generate-manifests.sh` 从 frontmatter 生成 `.codex-plugin/plugin.json` 和 `.claude-plugin/plugin.json`。
- `commands/*.md` 维护一份，脚本为 Claude Code 生成 `.claude-plugin/commands/*.md` 镜像。
- 非 Codex/非 Claude Code 环境走 `AGENTS.md` 的"直读 SKILL.md"回退路径。
- 所有脚本 bash，Windows 用 Git Bash / WSL 执行。
- `quick-validate.sh` 检测清单漂移 + SKILL.md 行数超标 + 零 .ps1 残留。

---

## 8. 迁移策略

四阶段，每阶段独立 commit + 标签，可回滚。

### 阶段 A · 骨架（无破坏）

- 新增 `novel-draft-system` skill + bash 脚本 + `.draft-index.yaml` 模板
- 新增 `.claude-plugin/` 生成脚本
- 现有 test books 不动
- 验收：`quick-validate.sh` 通过 + 两份清单生成
- 标签：`phase-a-skeleton`

### 阶段 B · 执行层重写（破坏性）

- 拆 `novel-scene-writer` → 5 个新 skill
- `novel-plot-weaver` description 改写（收窄到筹备）
- `using-novel` 瘦身到 ≤80 行
- 重写 evals
- 验收：demo-book T1→T6 跑通
- 标签：`phase-b-exec-rewrite`

### 阶段 C · 筹备层接入草稿协议（中度破坏）

- outline-coach / character-card-coach / book-scaffold 接入 draft-system
- 引入 state.md，从现有人物卡迁出当前状态
- demo-book 和 back-to-2008 **都走新流程**
- 验收：两本书各跑一次筹备修改走草稿 → finalize
- 标签：`phase-c-prep-draft`

### 阶段 D · 清理（无破坏）

- 删除所有 `.ps1`（硬需求，不保留备份）
- 评估 `rewrite-branch-protocol.md` 是否被 draft-system 取代 → 合并或删除
- README 重写、AGENTS.md 更新
- 验收：`quick-validate.sh` 全绿 + README 表 fresh + 零 .ps1
- 标签：`phase-d-cleanup`

向后兼容：定稿层路径不改。增量走新路径，存量留旧位，不做一次性大搬家。

---

## 9. 成功标准与风险

### 成功标准

| ID | 标准 |
|----|------|
| S1 | 任意 AI 生成草稿头部 yaml 含 `slice_ref`；任意写入不在定稿路径除非经 finalize |
| S2 | 所有 SKILL.md ≤100 行，reference ≤150 行 |
| S3 | demo-book 和 back-to-2008 各跑完整 T1→T6 + rollback |
| S4 | 单次 draft/polish/expand/rewrite 上下文输入可控 |
| S5 | 两份平台清单脚本生成、无手工痕迹、无漂移 |
| S6 | 仓库零 .ps1 残留 |
| S7 | 草稿/快照/定稿三层查询顺序被遵守 |

### 评测用例

| ID | 场景 |
|----|------|
| E1 | 从 0 写新场景走完 T1-T6 |
| E2 | 定稿后 rollback 人物 state |
| E3 | 强制后门写失真正文 → 验证偏离说明 + state 未自动回写 |
| E4 | 旧 demo-book 素材在新系统能读能增量创作 |
| E5 | 触发 draft 回调 plan-slice 补字段 |
| E6 | Codex + Claude Code 两环境都能触发 /using-novel |

### 风险

| ID | 风险 | 缓解 |
|----|------|------|
| R1 | 五步拆分让作者更累 | 入口集中识别意图，自然语言无需记命令 |
| R2 | 状态回写确认仪式过重 | 所有角色 diff 一并展示，降低疲劳 |
| R3 | 长篇后期切片超 token | state.md ≤40 行、recent_events ≤5、relations_with 只限在场者 + 脚本告警 |
| R4 | 迁移中旧数据丢失 | 迁移器只读旧文件写新 drafts/，不触碰旧定稿；idempotent |
| R5 | rewrite 跑偏 | rewrite 产物先进快照不覆盖工作台，作者对比后再同步 |
| R6 | 强制后门滥用 | `.draft-index.yaml` 统计 forced 占比 >15% 时 warning |

### 显式 YAGNI

- 不做角色 sub-agent 对话模拟
- 不做句级 diff 修订
- 不做自动推进小说（作者不点头永远不 draft）
- 不做多本书并行工作区
- 不做云端/数据库/向量检索
