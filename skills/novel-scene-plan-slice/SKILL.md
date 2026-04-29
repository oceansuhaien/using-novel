---
name: novel-scene-plan-slice
description: 用于在写场景初稿或重写之前，规划要加载哪些角色、哪些字段、哪些环境信息的场景切片清单。适用于"写第 X 章，主角到 YY 地"、"重写这场对峙"、"下一场戏该让谁在场"这类明确要动笔但尚未动笔的场景任务。产出 yaml 形态的切片清单，作为 draft/rewrite 的唯一输入契约。
---

# 场景切片规划

## 作用

在写场景初稿（draft）或重写（rewrite）**之前**，先规划"本场要读谁的什么字段、哪几条关系、哪几条最近状态"。产出 `drafts/chapters/<scene>.slice.yaml`，作为 draft/rewrite 的输入契约。

polish / expand 不需要本技能（它们基于上一版正文工作）。

## 核心原则

**关系网永不整张加载**。每次切片按"本场在场者"过滤，只带两两关系。

## 切片 schema（必须产出）

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
    identity: [card_head, current_disguise]       # characters/<id>.md 的 section 名
    personality: [key_traits_for_tension]         # 只选本场最相关
    state: full                                    # drafts/characters/<id>/state.md
    relations_with: [old_zhou]                    # 只列在场者
    recent_events: 3                               # state.md 最近 N 条
  old_zhou:
    identity: [card_head]
    state: full
    relations_with: [lin_wan]
    recent_events: 2
  unknown_rider:
    identity: minimal                             # 非主视点，最小锚点
intent:
  goal: "让林婉第一次意识到老周知道她的真实身份"
  pov: lin_wan
  length_hint: 1800
forced: false
```

## 字段约束（硬上限）

- `env.on_stage`：本场角色 id 数组，至少 1 个。
- `load.<id>.state`：默认 `full`，读 `drafts/characters/<id>/state.md` 全文。
- `load.<id>.recent_events`：上限 5，越多越浪费上下文；默认 3。
- `load.<id>.relations_with`：**只**能填 `on_stage` 列表内的其他 id。禁止列非在场者以避免关系网爆炸。
- `load.<id>.identity`：推荐 1-3 个 section；只需识别锚点时用 `minimal`。
- `intent.length_hint`：期望字数，draft 按此写。

## 工作流

1. **读请求**，判断是新场景 draft 还是既有场景 rewrite：
   - 新场景 → 需要作者指定 `env.place` / `env.trigger` / `intent.goal`，不足时**一次一个问**关键缺口。
   - 既有场景 rewrite → 读当前 slice.yaml（走 `draft-query.sh chapters/<scene>.slice`）作为起点，改动必要字段。
2. **确定 on_stage**：从 `intent.goal` 反推哪几个角色必须在场；优先读 `summary.md`、`plot/` 最新节点判断。
3. **按 on_stage 确定 load 清单**：每个角色挑本场最相关字段，不贪多。
4. **产出 yaml**，走 `draft-write.sh chapters/<scene>.slice slice <tmp-file>` 落盘版本链 + 工作台。
5. **让作者过一眼**："这是本场我准备加载的环境和角色字段，要调整吗？"—— **停下来等作者确认**，不自动进入 draft。

## 缺口规则

不要凭空编造：

- `env.place` 不明 → 问作者或读相邻章节 `chapters/notes/` 推断。
- `intent.goal` 不明 → 问作者"这一场的压力/推进是什么"。
- 新角色首次出场 → 要求作者补 `characters/<id>/state.md` 最小版（或路由到 `novel-character-card-coach`）。

## 回调约定

draft/rewrite 执行中发现字段不够时，可回调本技能补充一次。被回调时：

- 读现有 slice + draft 的缺口描述。
- 最小补充需要的字段，产出新 slice 版本（kind=slice，vNNN+1）。
- 不重写整张 slice，只改相关字段。

## 不做的事

- 不直接写正文（那是 `novel-scene-draft` / `novel-scene-rewrite` 的职责）。
- 不改 `characters/<id>.md` 定稿层（那是 `novel-character-card-coach`）。
- 不改 plot 节点（那是 `novel-plot-weaver`，且只在筹备期）。
- 不把非在场者加进 relations_with。
