# README / 路由清单自动生成设计

- 日期：2026-04-22
- 作者：Novel Driver 维护者
- 状态：Design（尚未实施）
- 相关仓库路径：`README.md`、`skills/using-novel/SKILL.md`、`commands/`、`skills/`、`scripts/`

## 背景

当前 `novel-driver` 仓库在新增技能时需要在多个位置手工同步"路由信息"：

1. `README.md` 的"命令"段列出 4 个面向用户的 `/` 命令及其简介。
2. `skills/using-novel/SKILL.md` 的"作用"段列出 5 个可路由到的小说技能。
3. `skills/using-novel/SKILL.md` 的"快速分类"表列出意图到技能的对应关系。

此外每个子技能的 `SKILL.md` frontmatter 已经包含权威的 `name` / `description`。
同一份信息被复制到 3 处，导致**新增技能必须动 3 个文件的文档段**，并且容易漂移。

## 目标

- 消除上述文档中关于"可路由技能清单"和"命令清单"的手工维护。
- 保持 `using-novel/SKILL.md` 作为跨技能方法论与编排规则的入口，但不再承担"目录索引"。
- 校验体系能在作者遗忘同步时直接报错，而不是静默漂移。
- 支持 Windows、Linux、macOS 任一终端运行（跨平台）。

## 非目标

- 不改变各子技能自身的职责边界。
- 不重构 `commands/` 的斜杠命令到具体技能的映射关系。
- 不引入新的 Markdown/YAML 国际化层。
- 不在本轮中增加 frontmatter 深度校验（现有 `quick-validate.ps1` 的职责不变）。
- 不强制自动化提交（Git hook）；手工触发生成 + 校验失败即可满足需求。

## 设计决策汇总

| 决策点 | 选项 | 采纳 | 理由 |
| --- | --- | --- | --- |
| 整体路由架构 | A 去中心化 / B 保留集中表但单清单生成 / C 只压缩手工点 | **A** | 与参考仓库 `superpowers` 架构一致；frontmatter 本就是权威源 |
| 入口 SKILL 的处理 | A1 保留方法论+组合规则 / A2 完全删除 / A3 用标记块注入 | **A1** | 组合规则是跨技能编排，不属于任何单技能，必须人工集中维护 |
| README 展示粒度 | B1 命令表+技能表 / B2 仅命令表 / B3 仅技能表 | **B1** | 读者分两类：使用者看命令、贡献者看技能；两表数据源天然分开 |
| 脚本运行时机 | C1 人工触发+校验兜底 / C2 Git hook 自动跑 / C3 只提供脚本不校验 | **C1** | 把"漂移"硬化为校验失败；不引入 hook 安装流程 |
| 技能表是否含 `using-novel` | D1 排除 / D2 标注"(入口)" | **D1** | 入口不是可路由目标，不应出现在"可选技能"清单 |
| 跨平台实现 | E1 单份 `.ps1` 用 pwsh / E2 双份 ps1+sh / E3 Python / E4 Node | **E1** | 保持与现有三份脚本同栈；PowerShell 7+ 官方跨平台 |

## 核心思路

- **单一事实来源 = 每个 SKILL.md / 命令文件自身的 frontmatter。**
- **入口 `using-novel/SKILL.md` 不再承担"目录索引"**，只保留方法论 + 跨技能编排 + 兜底 + 自检。
- **`README.md` 的命令/技能清单由脚本生成**，覆盖写入 `<!-- BEGIN:... -->` 与 `<!-- END:... -->` 标记块之间。
- **`quick-validate.ps1` 追加校验**，运行生成脚本的 `-Check` 模式；漂移即失败。

### 数据流

```
skills/*/SKILL.md  ──┐
                     ├──► generate-readme.ps1 ──► README.md（标记块之间）
commands/*.md ───────┘

quick-validate.ps1 ──► 调用 generate-readme.ps1 -Check ──► 若漂移则失败
```

### 职责划分

| 文件/目录 | 改前 | 改后 |
| --- | --- | --- |
| `skills/*/SKILL.md` frontmatter | 描述自己 | **同左（权威源）** |
| `commands/*.md` frontmatter | 描述该命令 | **同左（权威源）** |
| `skills/using-novel/SKILL.md` | 方法论 + 可路由明细 + 快速分类表 + 组合规则 + 兜底 | **只保留**：方法论 + 组合规则 + 兜底 + 自检 |
| `README.md` 命令段 | 手写 4 条 | 标记块，由脚本覆盖 |
| `README.md` 新增技能段 | 不存在 | 标记块，由脚本覆盖 |
| `scripts/generate-readme.ps1` | 不存在 | **新增**：读 frontmatter → 重写标记块；支持 `-Check` |
| `scripts/quick-validate.ps1` | 校验 frontmatter 存在 | **追加**：调用 `generate-readme.ps1 -Check` |

## 脚本规格：`scripts/generate-readme.ps1`

### 签名

```powershell
param(
    [string]$PluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$Check
)
```

### 行为

1. 扫描 `commands/*.md`：
   - 跳过无 frontmatter 的文件。
   - 从文件名推导命令名：`using-novel.md` → `/using-novel`。
   - 抽取 frontmatter 的 `description`。
   - 按文件名字母序排序，渲染为 Markdown 表格。

2. 扫描 `skills/*/SKILL.md`：
   - 抽取 frontmatter 的 `name` 与 `description`。
   - **排除 `name: using-novel`**。
   - 按 `name` 字母序排序，渲染为 Markdown 表格。

3. 读取 `README.md`，定位两对标记块，用新内容覆盖之间：
   - `<!-- BEGIN:COMMANDS -->` ... `<!-- END:COMMANDS -->`
   - `<!-- BEGIN:SKILLS -->` ... `<!-- END:SKILLS -->`
   - 若标记块缺失则报错退出，强制作者先埋点。

4. `-Check` 模式：
   - 不写回磁盘。把内存中新 README 与磁盘现有 README 按字符串比较。
   - 一致则静默 `exit 0`；不一致则打印漂移的块名 `exit 1`。
   - 默认模式直接写回；内容变化时打印 `Updated README.md`。

### 约定

- 表格列固定两列：`命令 | 说明` 与 `技能 | 说明`。
- `description` 中的 `|` 转义为 `\|`，换行折叠为空格。
- frontmatter 解析用正则抓 `^---` 到下一个 `^---`，再按行抓 `^(name|description):\s*(.*)$`，支持可选引号。不引入外部 YAML 依赖。
- 所有 IO 使用 UTF-8，不带 BOM，与现有 PowerShell 脚本一致。

### 示例输出

```markdown
<!-- BEGIN:COMMANDS -->
| 命令 | 说明 |
| --- | --- |
| `/novel-character` | 直接进入小说人物技能，用于人物卡、关系卡、人物弧线和人物总表。 |
| `/novel-outline`   | 直接进入小说大纲技能，用于题材前提、大纲、卷纲和世界观工作。 |
| `/novel-plot`      | 直接进入小说剧情技能，用于剧情节点、悬念、反转、伏笔和推进修复。 |
| `/using-novel`     | 把小说开发请求分流到建书脚手架、大纲、剧情、人物或共享规则技能。... |
<!-- END:COMMANDS -->
```

## 跨平台策略（E1）

- 统一采用 PowerShell 7+（`pwsh`）。
- Windows 同时保留 `powershell` 兼容（现有脚本已是 `.ps1`）。
- `quick-validate.ps1` 追加的 README 漂移校验用动态探测：

```powershell
$pwshExe = if (Get-Command pwsh -ErrorAction SilentlyContinue) { "pwsh" }
           elseif (Get-Command powershell -ErrorAction SilentlyContinue) { "powershell" }
           else { $null }

if ($pwshExe -and (Test-Path $genScript)) {
    & $pwshExe -NoProfile -File $genScript -PluginRoot $PluginRoot -Check
    if ($LASTEXITCODE -ne 0) {
        Add-Error "README.md is out of sync with commands/ or skills/. Run scripts/generate-readme.ps1 to regenerate."
    }
}
```

- README 的"开发"段同时给出 Windows 与 Linux/macOS 两种调用示例：
  - `powershell -ExecutionPolicy Bypass -File .\scripts\...`
  - `pwsh -File ./scripts/...`

## 文档瘦身：`skills/using-novel/SKILL.md`

**保留**：
- `description` frontmatter（不动）。
- `<SUBAGENT-STOP>` 与 `<IMPORTANT>` 标签段。
- `## 作用`（补充一句：技能清单由脚本生成，不在此处维护）。
- `## 路由方法论`（基于现有"路由优先级"改写）。
- `## 组合规则`（完整保留 5 个小节，跨技能编排知识唯一集中地）。
- `## 执行要求` / `## 何时提问` / `## 兜底` / `## 自检`。

**删除**：
- `## 作用` 下的"可路由到：" 5 条技能明细。
- `## 快速分类` 整张表。

改后预计约 70 行（原 130 行）。

## 文档改造：`README.md`

新骨架关键点：

- `## 命令` 下放 `<!-- BEGIN:COMMANDS -->` / `<!-- END:COMMANDS -->`。
- 新增 `## 技能`，内含 `<!-- BEGIN:SKILLS -->` / `<!-- END:SKILLS -->`。
- `## 开发` 段每条命令补一份 `pwsh` 调用示例；新增"重新生成 README"和"仅校验 README"两条说明。
- 其余段落不动。

## 子技能 description 补强（G1，前置步骤）

评估现有 5 个子技能 frontmatter 的 `description` 后，发现两条在去中心化路由下触发词偏弱——
它们依赖 `using-novel/SKILL.md` "快速分类"表里的口语化词汇，删除该表后可能导致错误路由。
实施第 0 步必须先补强这两条，使其能独立承担路由职责。

### 需要改写

**`skills/novel-book-scaffold/SKILL.md`** 的 `description`
- 现：聚焦"脚手架/工作区"术语。
- 新：加入用户口语化触发词——"创建新的单本书工作区""从零开始一本书""搭建 demo/test 书""补齐缺失的小说目录结构"。

**`skills/novel-character-card-coach/SKILL.md`** 的 `description`
- 现：开头"从大纲、章节、人物和灵感材料中提炼"造成"必须有已有材料才适用"的误导。
- 新：先列适用对象（人物卡、关系卡、人物总表、人物弧线、动机、身份、归档），加入口语化触发词"做人设卡""梳理人物关系""这个角色立不住""人物动机对不上"，再说明证据驱动与回写流程。

### 不改写

`novel-outline-coach`、`novel-plot-weaver`、`novel-system-reference` 触发词已足够密集，保持原样。
`novel-system-reference` 的"不作为默认创作入口"是有价值的负向信号，保留。

## 实施步骤

0. **补强子技能 description**（前置）：按上一节改写 `novel-book-scaffold` 与 `novel-character-card-coach` 的 frontmatter `description`。
1. **编写 `scripts/generate-readme.ps1`**：实现 frontmatter 抽取、标记块覆盖、`-Check` 模式、UTF-8 无 BOM 输出。
2. **在 `README.md` 埋标记**：插入两对 `BEGIN/END` 标记，新增 `## 技能` 段，`## 开发` 段补 pwsh 示例。
3. **首次生成**：运行 `pwsh -File scripts/generate-readme.ps1`，人工 diff 确认结果。
4. **瘦身 `skills/using-novel/SKILL.md`**：按前述"保留/删除"清单处理，并在 `## 作用` 补说明。
5. **`scripts/quick-validate.ps1` 追加**：加入 README 漂移校验段，复用现有 `$errors` 汇总。

每一步完成后跑 `pwsh -File scripts/quick-validate.ps1` 确认未破坏其他校验。

## 验收标准

- [ ] 新建临时 `skills/novel-demo/SKILL.md`（仅 frontmatter），**不**改 README、**不**改 `using-novel/SKILL.md`。
- [ ] `pwsh -File scripts/quick-validate.ps1` 报错：`README.md is out of sync ...`。
- [ ] `pwsh -File scripts/generate-readme.ps1` 成功，README 的 `## 技能` 表多出一行。
- [ ] 再次运行 `quick-validate.ps1` 通过。
- [ ] 删除临时技能后再跑生成，表格回到原样。
- [ ] `using-novel/SKILL.md` 不再出现 `novel-book-scaffold` / `novel-outline-coach` / `novel-plot-weaver` / `novel-character-card-coach` / `novel-system-reference` 作为"技能清单"用途（组合规则段落中的引用保留）。
- [ ] 首次生成后的 README 与人工版本除排序差异外信息一致。

**反向验收**（本次修改应消除的手工动作）：

- 改前：新增技能需改 3 处文档清单。
- 改后：只改 1 处（新技能自身 `SKILL.md` 与可选的 `commands/*.md`），再运行 `generate-readme.ps1`。
- 例外：新技能改变"跨技能编排顺序"时，仍需手工更新 `using-novel/SKILL.md` 的组合规则。

## 风险与缓解

| 风险 | 缓解 |
| --- | --- |
| PowerShell 正则在多行 `description` 或嵌套引号下解析错误 | 约定：`description` 单行、引号可选；必要时升级到 PowerShell 7 内置 `ConvertFrom-Yaml` |
| Linux/macOS 作者未安装 `pwsh` | README 给出一次性安装指引（`brew install powershell` / `apt install powershell`）|
| CI 漂移校验阻塞提交 | 一条命令即可修复：`pwsh -File scripts/generate-readme.ps1` |
| 首次生成把现有手写顺序改为字母序 | 首次 diff 人工确认；未来若确需自定义顺序，再为 frontmatter 增加可选 `order:` 字段（YAGNI） |

## 后续可选增强（本轮不做）

- `commands/` 命令表增加"映射到哪个技能"一列，数据源改为命令文件内容解析。
- `generate-readme.ps1` 同时校验每个 `SKILL.md` 的 frontmatter 字段完整性（目前由 `quick-validate.ps1` 负责）。
- 为 frontmatter 增加 `order` / `hidden` 字段以支持手动排序或隐藏内部技能。
- 把同样机制套用于 `CLAUDE.md`（若存在等价清单）。

## 参考

- 参考仓库 `D:\code\uncompany\learn\superpowers` 的架构：`using-superpowers` 入口只讲方法论，不维护技能清单；README 手写展示，无自动化生成（此处我们做得更严格一点）。
- 本仓库 `AGENTS.md` 要求："每个面向用户的技能都必须保持 `SKILL.md` 的触发元数据与 `agents/openai.yaml` 一致。"——该要求与本设计"frontmatter 即权威源"原则一致。
