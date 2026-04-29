# Novel Driver

`novel-driver` 是一个可安装的 Codex 插件，用于中文网文开发流程。

它把大纲、剧情、人物和共享 canon 规则拆成多个聚焦技能，避免把故事工作区误当成插件仓库的一部分。

## 安装

把仓库克隆到本地插件目录：

```powershell
git clone <repo-url-or-local-path> C:\path\to\plugins\novel-driver
```

在 marketplace 配置里注册为本地插件源：

```json
{
  "plugins": [
    {
      "name": "novel-driver",
      "source": {
        "source": "local",
        "path": "C:/path/to/plugins/novel-driver"
      },
      "policy": {
        "installation": "AVAILABLE",
        "authentication": "ON_INSTALL"
      },
      "category": "Writing"
    }
  ]
}
```

## 命令

<!-- BEGIN:COMMANDS -->
| 命令 | 说明 |
| --- | --- |
| `/novel-character` | 直接进入小说人物技能，用于人物卡、关系卡、人物弧线和人物总表。 |
| `/novel-outline` | 直接进入小说大纲技能，用于题材前提、大纲、卷纲和世界观工作。 |
| `/novel-plot` | 直接进入小说剧情技能，用于剧情节点、悬念、反转、伏笔和推进修复。 |
| `/novel-scene` | 进入小说场景写作循环，由入口集中识别意图（写新场景→plan-slice+draft；改字句→polish；加细节→expand；改事件/结构→rewrite；定稿→finalize；回滚→rollback）。用户自然语言表达即可，不需记命令。 |
| `/using-novel` | 把小说开发请求分流到建书脚手架、大纲、剧情、人物、正文场景或共享规则技能，并在当前技能完成后继续强制检查书籍目录相关文件是否需要补齐与落盘。用法：/using-novel 先帮我创建一本新书工作区，再整理成可连载大纲。 |
<!-- END:COMMANDS -->

## 技能

<!-- BEGIN:SKILLS -->
| 技能 | 说明 |
| --- | --- |
| `novel-book-scaffold` | 用于创建新的单本书工作区、从零开始一本书、搭建 demo/test 书、补齐缺失的小说目录结构，在 `test/books/<book-id>/` 下创建或修复本地中文网文项目脚手架；脚手架包含定稿层目录和草稿层 `drafts/` 以及初始 `.draft-index.yaml`，所有后续写入由 `novel-draft-system` 管理。 |
| `novel-character-card-coach` | 用于中文网文的人物卡、关系卡、人物总表、人物弧线、秘密、动机、身份与人物资料归档，以及维护角色当前状态快照 state.md。适用于"做人设卡""梳理人物关系""这个角色立不住""人物动机对不上"等请求；可从架构资料中证据驱动地提炼，标注待确认；所有写入走草稿协议，用户确认后 finalize 到 `characters/` 定稿层。 |
| `novel-draft-system` | 小说草稿版本系统的共享协议。用于约束所有小说资产（大纲/人物卡/剧情节点/场景正文/角色状态等）的草稿层写入、版本链命名、三层查询顺序、finalize 定稿、rollback 回滚、状态回写流程；供 using-novel、novel-book-scaffold、novel-outline-coach、novel-character-card-coach、novel-plot-weaver 以及 novel-scene-* 系列技能引用，不作为默认创作入口。 |
| `novel-outline-coach` | 用于把零散中文网文灵感整理成可连载的大纲、核心主旨（Theme/母题/中心思想）、题材卖点、故事前提、主线骨架、卷纲、结局方向和世界观 canon。适用于提炼全书贯穿的主旨与价值母题、写大纲、搭设定、做卷计划、整理高层故事状态；所有写入走草稿协议，用户确认后再 finalize 到 `summary.md`、`outline/`、`canon/` 等定稿层。 |
| `novel-plot-weaver` | 用于**筹备期**把中文网文剧情灵感整理成可推进的主线、暗线、伏笔、反转、阶段目标、卷钩子和剧情节点。适用于尚未动笔正文的阶段，做剧情结构规划、埋伏笔、设计卷钩子、梳理推进逻辑、处理节奏断裂；所有写入走草稿协议，用户确认后 finalize 到 `plot/` 等定稿层。**不**用于场景正文阶段——正文由 novel-scene-* 系列基于角色自主推理产出，plot 节点只作为筹备输入。 |
| `novel-scene-draft` | 用于根据已经规划好的场景切片清单 slice.yaml 写场景初稿。适用于"按这个切片写初稿"、"plan-slice 定好了，开始写"、"给这场戏写个 v001"等场景初稿请求。输入只读 slice 里列出的字段，输出 vNNN-draft.md 到版本链 + 同步工作台。不负责润色、扩写、重写。 |
| `novel-scene-expand` | 用于在不改主干事件的前提下给场景草稿加细节、内心戏、环境描写、动作神态补强。适用于"加点她的心理活动"、"这段太仓促展开一下"、"补点环境描写让画面感更强"、"加一些动作承接"这类扩写请求。产出 vNNN-expand.md 到版本链 + 同步工作台。禁止改事件顺序、角色决定、场景结构。 |
| `novel-scene-plan-slice` | 用于在写场景初稿或重写之前，规划要加载哪些角色、哪些字段、哪些环境信息的场景切片清单。适用于"写第 X 章，主角到 YY 地"、"重写这场对峙"、"下一场戏该让谁在场"这类明确要动笔但尚未动笔的场景任务。产出 yaml 形态的切片清单，作为 draft/rewrite 的唯一输入契约。 |
| `novel-scene-polish` | 用于只改语言、节奏、去 AI 味、对白校正的场景草稿润色。适用于"对白再自然点"、"这段太像 AI 了"、"句子太长了压一压"、"这段读起来拖"这类不改主干事件、只改字句的请求。产出 vNNN-polish.md 到版本链 + 同步工作台。禁止改事件顺序、角色决定、场景结构。 |
| `novel-scene-rewrite` | 用于允许改事件顺序、角色决定、场景结构的场景重写。适用于"老周不该这么直接，整个对峙段重写"、"这场戏让他不出现试试"、"换个地点重写"、"让她这里拒绝"这类需要改变场景主干的请求。会重跑切片推理，产出 vNNN-rewrite.md 到版本链；不自动覆盖工作台，等作者对比 v(N-1) 和 v(N) 后显式同步。 |
| `novel-system-reference` | 中文网文技能的共享参考。用于需要小说架构契约、证据等级、跨文档同步策略、回写边界、事实来源优先级时；供大纲、剧情、人物技能引用，不作为默认创作入口。 |
<!-- END:SKILLS -->

`using-novel` 是插件内部的分流入口，不出现在上表；只在面向用户的斜杠命令 `/using-novel` 中暴露。

## 仓库结构

```text
novel-driver/
|- .codex-plugin/          插件元数据
|- assets/                 图标和展示资源
|- commands/               轻量命令适配层
|- evals/                  手工回归用例
|- scripts/                校验和同步脚本
|- skills/                 技能创作唯一事实来源
|- AGENTS.md               插件维护规则
|- CLAUDE.md               Claude 适配入口
|- README.md               安装和开发说明
```

## 开发

本仓库的脚本基于 PowerShell 7+（`pwsh`），同时保留 Windows 自带 `powershell` 兼容。Linux/macOS 可通过 `brew install powershell` 或 `apt install powershell` 安装。

校验插件结构：

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate.ps1
# Linux / macOS
pwsh -File ./scripts/quick-validate.ps1
```

重新生成 README 中的命令/技能表（新增或修改技能后必跑一次）：

```powershell
pwsh -File ./scripts/generate-readme.ps1
```

只检查 README 是否漂移（不写回，供 CI 使用；`quick-validate.ps1` 也会调用）：

```powershell
pwsh -File ./scripts/generate-readme.ps1 -Check
```

列出手工评测用例：

```powershell
# Windows
powershell -ExecutionPolicy Bypass -File .\scripts\run-evals.ps1
# Linux / macOS
pwsh -File ./scripts/run-evals.ps1
```

预览单向同步到另一个技能目录：

```powershell
pwsh -File ./scripts/sync-to-codex-skills.ps1 -TargetRoot /path/to/skills-mirror
```

确认执行同步：

```powershell
pwsh -File ./scripts/sync-to-codex-skills.ps1 -TargetRoot /path/to/skills-mirror -Apply
```

### 在 CodeBuddy / Claude Code 中调试

本仓库以 Codex 插件形态维护，`.codex-plugin/plugin.json` 仅被 Codex 识别。在 CodeBuddy、Claude Code 等非 Codex 环境里想要复用这些技能，二选一：

1. **镜像到目标环境的 skill 搜索路径**（推荐，可获得原生 skill 体验）。以 CodeBuddy 本地 plugins 目录为例：

   ```powershell
   pwsh -File ./scripts/sync-to-codex-skills.ps1 `
     -TargetRoot "$env:USERPROFILE\.codebuddy\plugins\marketplaces\local\novel-driver\skills" `
     -Apply
   ```

   同步后在 CodeBuddy 会话里就能通过 `use_skill using-novel` 等形式触发。

2. **不镜像，让 AI 直接读仓库里的 `SKILL.md`**。在仓库根启动会话，依托 `AGENTS.md` 的「Skill 回退策略」条款，AI 会把 `./skills/<name>/SKILL.md` 当作技能规约读取并执行。这种模式下 `/using-novel` 被降级为"请按 `skills/using-novel/SKILL.md` 的路由方法论工作"的语义触发。

无论哪种方式，测试小说写作都在 `test/books/<book-id>/` 下进行。`using-novel` 在插件仓库根进入测试模式时，选书优先级为：显式 `book-id` > 配置文件 > `demo-book`。默认配置文件是 `test/current-book.yaml`；如果它不存在，才回退到 `test/books/demo-book/`；如果它存在但无效，则会停下来提示，而不会静默切回 `demo-book`。手测步骤见 `test/books/demo-book/MANUAL-TEST.md`。

单本书工作区默认包含两份高层入口文件：

- `summary.md`：高层稳定结论。
- `context.md`：多轮确认后的关键上下文、冲突状态、覆盖依据与待确认问题。

`context.md` 只记录决策和冲突，不展开完整协议正文；具体规则由 `novel-system-reference` 维护。

## 非目标

- 这不是故事项目仓库。
- 本仓库不保存故事资料或故事状态目录。
- 本仓库不保存 `.omx` 或 `.omc` 运行时状态。
- `.codex/skills/` 镜像是生成产物，不是创作源目录。
