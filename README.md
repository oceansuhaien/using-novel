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
| `/novel-scene` | 直接进入小说正文场景技能，用于按剧情扩写正文、润色去 AI 味、改对白和修过渡。 |
| `/using-novel` | 把小说开发请求分流到建书脚手架、大纲、剧情、人物、正文场景或共享规则技能，并在当前技能完成后继续强制检查书籍目录相关文件是否需要补齐与落盘。用法：/using-novel 先帮我创建一本新书工作区，再整理成可连载大纲。 |
<!-- END:COMMANDS -->

## 技能

<!-- BEGIN:SKILLS -->
| 技能 | 说明 |
| --- | --- |
| `novel-book-scaffold` | 用于创建新的单本书工作区、从零开始一本书、搭建 demo/test 书、补齐缺失的小说目录结构，在 `test/books/<book-id>/` 下创建或修复本地中文网文项目脚手架；也适用于 `novel-driver` 自身的开发、示例或测试夹具准备。 |
| `novel-character-card-coach` | 用于中文网文的人物卡、关系卡、人物总表、人物弧线、秘密、动机、身份与人物资料归档。适用于"做人设卡""梳理人物关系""这个角色立不住""人物动机对不上"等人物向请求；可从小说架构资料的大纲、章节、已有人物和灵感材料中证据驱动地提炼，标注待确认，用户确认后回写人物资料。 |
| `novel-draft-system` | 小说草稿版本系统的共享协议。用于约束所有小说资产（大纲/人物卡/剧情节点/场景正文/角色状态等）的草稿层写入、版本链命名、三层查询顺序、finalize 定稿、rollback 回滚、状态回写流程；供 using-novel、novel-book-scaffold、novel-outline-coach、novel-character-card-coach、novel-plot-weaver 以及 novel-scene-* 系列技能引用，不作为默认创作入口。 |
| `novel-outline-coach` | 用于把零散中文网文灵感整理成可连载的大纲、核心主旨（Theme/母题/中心思想）、题材卖点、故事前提、主线骨架、卷纲、结局方向和世界观 canon。适用于提炼全书贯穿的主旨与价值母题、写大纲、搭设定、做卷计划、整理高层故事状态，并把确认内容回写到 `summary.md`、`outline/`、`canon/` 等小说架构模块。 |
| `novel-plot-weaver` | 用于把中文网文剧情灵感整理成可推进的主线、暗线、伏笔、反转、阶段目标、卷钩子和剧情节点。适用于修剧情、设计桥段、埋伏笔、加强爽点、处理节奏断裂、锁定故事推进，并在用户确认后把稳定剧情结论写回 `plot/` 等小说架构模块。 |
| `novel-scene-writer` | 用于根据用户给出的中文网文剧情梗概、片段、场景目标或半成稿正文，扩写成可读正文，或做去 AI 味润色、改写、续写、压句、对白校正、动作神态补强与过渡修复。适用于“我写了个剧情你帮我扩成正文”“这段太像 AI 写的”“帮我检查对白像不像这个人物会说的话”“把这一段写顺一点并提高张力”等正文向请求；默认先读取 `context.md`、`summary.md`，必要时再读 `plot/` 与 `characters/`，在不擅改主线设定的前提下服务当前场景。 |
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
