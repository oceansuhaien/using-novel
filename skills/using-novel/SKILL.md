---
name: using-novel
description: 用于开始中文网文创作对话，或把混合的小说需求自动分流到建书脚手架、大纲、剧情筹备、人物、场景切片/初稿/润色/扩写/重写、草稿协议等技能。入口集中做意图识别（import/draft/polish/expand/rewrite/finalize/rollback），作者用自然语言不需记命令。触发场景包括 /using-novel、创建新书、补齐目录、写大纲、梳理剧情、做人设卡、写场景正文、导入 inbox/ 外部草稿并润色扩写、润色去 AI 味、扩写加细节、重写对峙段、定稿章节、回滚到某版。
---

<SUBAGENT-STOP>
被主代理派出的子任务代理，除非主代理明确要求你做小说技能分流，否则跳过本技能。
</SUBAGENT-STOP>

# 小说技能入口

## 作用

`novel-driver` 的总入口。只做三件事：**开工预检**、**意图识别**、**路由到子技能**。不替子技能做创作，也不重复它们的规则。

共享协议只住在 `novel-system-reference`（目录契约、证据等级、同步策略、偏好记忆）和 `novel-draft-system`（草稿/版本链/finalize/rollback/状态回写），本入口只引用不重复。

## 开工预检（强制）

进入任何子技能前判断 cwd：

1. **书籍根**：`summary.md` + `outline/` + `plot/` + `characters/` 都在 → 正式模式，cwd 就是书籍根。
2. **插件仓库根**：`AGENTS.md` + `skills/using-novel/SKILL.md` 在 → 测试模式，按 `显式 book-id > test/current-book.yaml > demo-book` 顺序选书；配置无效时停下问，不静默回退。
3. **其他**：问作者 `(a)就地新建 (b)切到已有书籍根 (c)取消`。

第一句回答里简述：模式、书籍根绝对路径、将路由的技能序列。

`novel-book-scaffold` 是例外，可在"需要建书"结论下直接调用。

## 意图识别（集中处理）

作者自然语言 → 路由到对应 skill（不要求作者记 `/polish` 这种命令）：

| 作者说法类型 | 意图 | 路由目标 |
|---|---|---|
| "写第 N 章""开始新场景""按这个剧情写" | **draft** | plan-slice → draft |
| "这是我写的草稿""润色我这份""拿这段当 v001""@inbox/..." | **import** | import → 再按二级意图转 polish/expand/rewrite |
| "对白再自然点""去 AI 味""这段太像 AI""压一压" | **polish** | scene-polish |
| "加心理活动""补环境描写""这段太仓促加细节" | **expand** | scene-expand |
| "重写对峙段""换地点重写""让她这里拒绝""让他不出场" | **rewrite** | scene-rewrite（→ 回调 plan-slice） |
| "定稿""这版好""finalize ch00X" | **finalize** | 调 `scripts/draft-finalize.sh` |
| "回滚到 v003""撤回""回到上一版" | **rollback** | 调 `scripts/draft-rollback.sh` |
| "把这版推到工作台""sync""用 v004" | **sync**（rewrite 后确认） | 调 `scripts/draft-sync.sh` |
| "把 chN 的角色状态补一下""rewrite-state" | **状态回写补触发** | 调 `scripts/state-rewrite.sh` |
| **筹备类**：做大纲/设定/人物卡/剧情节点/卷钩子 | — | 对应 coach skill（outline / character / plot-weaver） |
| "强制让 X""不管合理性""@force:" | **forced 后门** | draft/rewrite 加 `--forced`，要求附合理性偏离说明 |

**rewrite vs polish 边界**：改事件顺序/角色决定/场景结构 → rewrite；只改字句节奏对白 → polish。不确定时选更轻的（polish）。

**import 路由**：识别到作者投递的外部草稿（`inbox/<file>.md`、`@` 引用、"帮我润色这份"）时，三步串行：
1. 解析源文件 + 目标 scene_id（未指明问一次）。
2. `scripts/draft-write.sh chapters/<scene> manual <源文件> --source imported --note "imported from <源路径>"`。
3. 按同一句里的二级意图继续 polish / expand / rewrite；若作者未声明 → 一次性问清。

## 组合规则（多个技能按序串行，不并行）

- **从零开始写一本书**：`novel-book-scaffold` → `novel-outline-coach` → 视后续进 `novel-plot-weaver` / `novel-character-card-coach`。
- **写新场景**：（筹备就绪前提下）`novel-scene-plan-slice` → `novel-scene-draft`。
- **改写场景**（已有正文）：按意图识别表路由到 polish / expand / rewrite 之一。
- **导入外部草稿**：按上面 import 路由三步走，不跑 plan-slice（导入稿已是正文）。
- **筹备缺口补齐**：draft 报告"字段不够"时 → 回 `novel-scene-plan-slice`；plan-slice 发现人物未立 → 转 `novel-character-card-coach`；发现剧情节点缺 → 转 `novel-plot-weaver`。

## 草稿协议（所有写入遵守）

所有 AI 写小说资产走 `novel-draft-system`：

- 默认落 `drafts/`，不是定稿层。
- 查询固定顺序：草稿工作台 → 版本链最新快照 → 定稿层。
- finalize 前不上定稿层；rewrite 产物不自动覆盖工作台。
- forced 占比 >15% 脚本 warning。

细节全部在 `novel-draft-system/references/`，不在此复述。

## 串行补全扫描（收尾）

子技能完成后，**仅对明显受影响的相邻目录**做一次最小扫描（非 10+ 条大清单）：

1. 本轮是否形成新稳定结论 → 是则 `context.md` / `summary.md` 同步。
2. 场景 finalize 后 → 必走状态回写（逐角色确认）。
3. 改 plot 节点 → 检查影响哪些伏笔/卷钩子文件。
4. 改人物卡 → 检查影响哪些 plot 节点。

不做的：不在每次对话都列完整检查单；不因为可能还有影响就拒绝结束；不替作者拍板。

## 何时提问

仅当信息缺失会改变路由或阻止子技能产可靠结果时才问。例如：  
- "你是要先搭工作区，还是在现有书里做大纲？"  
- "本场主角要见谁？"（plan-slice 缺在场者）  
- "让她拒绝背后是性格使然，还是被什么情境逼的？"（rewrite 判断走 forced 还是改环境）

不合适：一开始收集所有偏好；把单一请求展开成大访谈。

## 自检

- 是否有意识地路由，而不是跳过技能自己全做？  
- cwd 未预检就写资料？禁止。  
- 改 plot 节点和场景正文混在一起？应分两步。  
- 把协议细节（版本链/快照/finalize）重复到本文件？禁止——全部外链 draft-system。
