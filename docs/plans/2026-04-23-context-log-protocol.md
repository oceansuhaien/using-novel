# Context Log Protocol Implementation Plan

> **For Claude:** REQUIRED SUB-SKILL: Use superpowers:executing-plans to implement this plan task-by-task.

**Goal:** 为 `novel-driver` 增加一套跨小说技能共享的“上下文记录 + 冲突检测 + 二次确认”协议，让大纲、剧情、人物在多轮讨论中能持续记录确认结论，并在冲突时先收束再提问。

**Architecture:** 不新增用户入口 skill。把能力落在共享规则层：由 `novel-system-reference` 定义 `context.md`/决策日志协议，由 `novel-book-scaffold` 负责初始化该文件，由 `novel-outline-coach`、`novel-plot-weaver`、`novel-character-card-coach` 在每轮确认与回写前后遵守统一流程。`using-novel` 只做轻量提醒与路由，不承载具体日志逻辑。

**Tech Stack:** Markdown skill 规范、YAML frontmatter / `agents/openai.yaml` 元数据、Python 脚手架脚本、PowerShell 校验脚本、手工回归用例。

---

### Task 1: 定义共享上下文日志协议

**Files:**
- Create: `skills/novel-system-reference/references/context-log-protocol.md`
- Modify: `skills/novel-system-reference/SKILL.md`
- Modify: `skills/novel-system-reference/references/directory-contract.md`
- Modify: `skills/novel-system-reference/references/evidence-levels.md`
- Modify: `skills/novel-system-reference/references/sync-policy.md`

**Step 1: 新建协议文档骨架**

在 `context-log-protocol.md` 定义以下内容：
- `context.md` 的定位：记录多轮确认后的关键决策、冲突、覆盖依据、未决问题。
- 与 `summary.md` 的边界：`summary.md` 只保留高层稳定状态，`context.md` 保留决策过程与冲突状态。
- 推荐区块：`会话目标`、`当前有效结论`、`最近确认`、`冲突清单`、`待用户确认`、`影响范围`、`覆盖历史`。
- 单条记录格式：日期、触发步骤、结论、证据等级、来源、影响文件、是否覆盖旧结论、是否待确认。

**Step 2: 更新目录契约**

在 `directory-contract.md` 中把 `context.md` 加入默认单本书结构，并补一句：
- `context.md` 是共享决策日志，不替代领域文件。
- 冲突与未决问题先沉淀在这里，再决定是否升格到 `summary.md` 或领域文件。

**Step 3: 升级证据与冲突规则**

在 `evidence-levels.md` 中补充：
- 新结论覆盖旧结论时，必须写明覆盖依据。
- 若 A/B 两步确认冲突且不能由“最新明确指令优先”直接裁定，则必须记入 `context.md` 的冲突清单。
- 冲突解除后，要回写日志状态（已解决 / 已废弃 / 继续待确认）。

**Step 4: 升级联动同步规则**

在 `sync-policy.md` 中补充：
- 同步前先检查 `context.md` 是否已有未解决冲突。
- 若本轮确认足以覆盖旧设定，可直接同步改写并追加一条覆盖记录。
- 若冲突会改变任务意图，只问一个聚焦问题，不展开多轮盘问。

**Step 5: 在共享技能入口暴露引用方式**

更新 `novel-system-reference/SKILL.md` 的“按需读取”列表，增加 `references/context-log-protocol.md`，并明确这是大纲/剧情/人物都要遵守的共享协议。

**Step 6: 自检**

检查这组文档是否做到：
- 不把 `context.md` 误写成第二个 `summary.md`
- 不把所有聊天记录都塞进去
- 只记录“决策、冲突、覆盖、待确认”四类高价值信息

**Step 7: 最小验证**

人工检查以上 5 个文件，确认术语统一使用 `context.md`，不要一会儿叫“上下文日志”，一会儿叫“决策日志”，除非你在协议里明确“`context.md` 是决策日志载体”。

---

### Task 2: 扩展脚手架，默认生成 `context.md`

**Files:**
- Modify: `skills/novel-book-scaffold/scripts/create_book_scaffold.py`
- Modify: `skills/novel-book-scaffold/SKILL.md`
- Modify: `skills/novel-book-scaffold/agents/openai.yaml`

**Step 1: 修改脚手架模板**

在 `render_files()` 返回的模板中新增 `context.md`，初始内容至少包含：
- 文件用途说明
- 最近确认：空模板
- 冲突清单：空模板
- 待用户确认：空模板
- 覆盖历史：空模板

**Step 2: 更新结构说明**

在 `novel-book-scaffold/SKILL.md` 的“创建结构”和“创建后”部分加入 `context.md` 的说明，明确：
- 它记录多轮确认后的关键上下文
- 它不是剧情细表，也不是人物卡
- 回到 `using-novel` / 领域 skill 后要优先读它

**Step 3: 保持元数据一致**

若 `SKILL.md` 的描述因为引入 `context.md` 有变化，同步检查 `agents/openai.yaml` 的 `short_description` / `default_prompt` 是否也要跟进，避免漂移。

**Step 4: 运行干跑验证**

Run:
```powershell
python .\skills\novel-book-scaffold\scripts\create_book_scaffold.py "测试书" --root d:\code\uncompany\using-novel --id plan-context-demo --dry-run
```

Expected:
- 输出计划文件列表时包含 `test/books/plan-context-demo/context.md`
- 不报越界错误

**Step 5: 运行补齐验证**

Run:
```powershell
python .\skills\novel-book-scaffold\scripts\create_book_scaffold.py "测试书" --root d:\code\uncompany\using-novel --id plan-context-demo --allow-existing
```

Expected:
- 能补出 `context.md`
- 已有文件继续走“保留已有文件”逻辑

---

### Task 3: 轻量更新 `using-novel` 路由层

**Files:**
- Modify: `skills/using-novel/SKILL.md`
- Modify: `skills/using-novel/agents/openai.yaml`

**Step 1: 只加协议提醒，不加业务流程**

在 `using-novel/SKILL.md` 中补一句类似约束：
- 路由到小说子技能后，子技能需遵守共享的 `context.md` 协议。
- 若目标书缺少 `context.md` 且允许补齐，则优先通过脚手架或增量补齐逻辑补上。

**Step 2: 避免入口膨胀**

确认 `using-novel` 不新增以下内容：
- 冲突检测细则
- 记录格式模板
- 多轮确认完整工作流
这些都应留在 `novel-system-reference` 和领域 skill 中。

**Step 3: 校对元数据**

如果 `SKILL.md` 的 frontmatter 描述有调整，同步修改 `skills/using-novel/agents/openai.yaml`。

**Step 4: 手工验收**

阅读 `using-novel/SKILL.md`，确认它仍然是“路由入口”，没有变成“创作协议总汇编”。

---

### Task 4: 为 `novel-outline-coach` 接入协议

**Files:**
- Modify: `skills/novel-outline-coach/SKILL.md`
- Modify: `skills/novel-outline-coach/agents/openai.yaml`
- Modify: `skills/novel-outline-coach/references/summary-schema.md`

**Step 1: 在输入优先级/工作流中显式读 `context.md`**

在 `novel-outline-coach/SKILL.md` 中新增规则：
- 开始前优先检查 `context.md` 中的“当前有效结论”“冲突清单”“待用户确认”。
- 如果本轮只是在延续上次确认，不要重新盘问已经拍板的高层结论。

**Step 2: 定义大纲阶段的日志写入时机**

补充到工作流 / 回写规则：
- 用户拍板主旨、反命题、读者承诺、卷纲方向后，先记入 `context.md` 的“最近确认”。
- 如果该确认覆盖旧的主旨/卷纲方向，写入“覆盖历史”。
- 再同步更新 `summary.md` 与 `outline/` / `canon/`。

**Step 3: 定义冲突提问策略**

补一句硬约束：
- 若 A 步确认的主旨与 B 步确认的卷纲方向互相冲突，先在 `context.md` 里列冲突点，再只问一个决定走向的问题。

**Step 4: 更新 `summary-schema.md` 的说明**

不要把冲突过程写进 `summary.md`；只在 `summary.md` 保留“最近确认变更”的摘要，并引导详细冲突历史进入 `context.md`。

**Step 5: 校对元数据**

如果描述文字有变，同步 `skills/novel-outline-coach/agents/openai.yaml`。

---

### Task 5: 为剧情与人物 skill 接入相同协议

**Files:**
- Modify: `skills/novel-plot-weaver/SKILL.md`
- Modify: `skills/novel-plot-weaver/agents/openai.yaml`
- Modify: `skills/novel-character-card-coach/SKILL.md`
- Modify: `skills/novel-character-card-coach/agents/openai.yaml`

**Step 1: 统一输入优先级**

在两个 skill 中都补充：
- `context.md` 是进入领域文件前的共享状态入口。
- 若 `context.md` 已记录本轮相关确认，优先沿用，不重复回到开放式脑暴。

**Step 2: 统一冲突策略**

在两个 skill 中都补充：
- 若新剧情结论 / 新人物结论与 `context.md` 或 `summary.md` 冲突，先判断能否由“最新明确指令优先”直接覆盖。
- 能覆盖则记覆盖历史并同步改写。
- 不能覆盖则先把冲突写进 `context.md`，再问一个最小必要问题。

**Step 3: 统一回写顺序**

在两个 skill 中都补充“先日志、后领域、再摘要”的顺序：
1. 追加 `context.md`
2. 更新 `plot/` 或 `characters/`
3. 必要时摘要同步到 `summary.md`

**Step 4: 校对元数据**

如果 frontmatter 描述有变化，同步更新 `agents/openai.yaml`。

---

### Task 6: 更新文档与手测/回归用例

**Files:**
- Modify: `README.md`
- Modify: `test/books/demo-book/MANUAL-TEST.md`
- Modify: `evals/router-cases.md`
- Modify: `evals/outline-cases.md`
- Modify: `evals/plot-cases.md`
- Modify: `evals/character-cases.md`

**Step 1: README 只补最小必要说明**

如果 README 需要更新，只加两类信息：
- 单本书工作区新增 `context.md`
- 其用途是记录确认结论与冲突处理，不展开完整协议正文

**Step 2: 扩充手测清单**

在 `MANUAL-TEST.md` 增加一个“冲突与二次确认”章节，至少覆盖：
- 先确认主旨 A，再确认卷纲 B，故意制造冲突
- 预期行为：先指出冲突，再问一个聚焦问题，而不是直接覆盖
- 冲突解决后，`context.md` 有覆盖记录，`summary.md` 只有最终高层结果

**Step 3: 扩充 eval 提示词**

给四个 eval 文档分别新增 1 条用例，覆盖：
- 路由场景下自动继承既有确认上下文
- 大纲场景下主旨/卷纲冲突
- 剧情场景下新剧情覆盖旧推进链
- 人物场景下新动机与旧关系定位冲突

**Step 4: 重新生成 README（如技能说明有变）**

Run:
```powershell
pwsh -File .\scripts\generate-readme.ps1
```

Expected:
- README 中技能表与当前 frontmatter 一致
- 不出现新增 skill，只是现有 skill 的说明微调

**Step 5: 运行结构与回归校验**

Run:
```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\run-evals.ps1
```

Expected:
- 结构校验通过
- eval 文档没有明显失配

---

### Task 7: 手工走完整回归链路

**Files:**
- Use existing fixture: `test/books/demo-book/`
- Inspect: `test/books/demo-book/context.md`
- Inspect: `test/books/demo-book/summary.md`
- Inspect: `test/books/demo-book/outline/`
- Inspect: `test/books/demo-book/plot/`
- Inspect: `test/books/demo-book/characters/`

**Step 1: 在仓库根启动测试模式**

Run:
```powershell
Set-Location d:\code\uncompany\using-novel
```

然后在实际会话中测试 `/using-novel` 或等价语义触发。

**Step 2: 走一条大纲确认链**

目标：确认一个主旨与一版卷纲，并检查：
- `context.md` 出现“最近确认”记录
- `summary.md` 只保留高层结论

**Step 3: 人工制造冲突**

再给出一个与前述主旨不兼容的新卷纲或人物动机，检查：
- 不会直接覆盖
- 会先指出冲突
- 只追问一个最小必要问题

**Step 4: 解决冲突后检查落盘**

检查：
- `context.md` 有“冲突 -> 解决 -> 覆盖历史”完整链条
- 领域文件只保留最新结论
- `summary.md` 没有堆叠讨论过程

**Step 5: 边界检查**

确认以下错误没有出现：
- 把整段聊天记录写进 `context.md`
- 把未确认建议写成事实
- 因冲突而把 `using-novel` 变成重度访谈入口

---

## Done Criteria

当以下条件全部满足时，认为本功能完成：
- 新书脚手架默认包含 `context.md`
- 三个领域 skill 都会读写同一份上下文协议
- 冲突出现时先记录、再最小提问、后覆盖回写
- `summary.md` 仍保持高层摘要定位
- 不新增任何新的用户入口 skill
- `README`、手测清单、eval 提示词与技能文案保持一致
