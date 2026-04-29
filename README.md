# Novel Driver

`novel-driver` 是一个中文网文创作插件，同时支持 **Codex** 和 **Claude Code** 两个环境。

它把大纲、剧情筹备、人物、场景写作循环、草稿版本系统等职责拆成多个聚焦技能，每个 `SKILL.md` ≤100 行，由入口 `using-novel` 集中做意图识别与路由。

## 核心特性（V2）

- **草稿版本系统**（`novel-draft-system`）：所有 AI 写入默认落 `drafts/` 草稿层，作者 finalize 才进定稿层。三层查询顺序：工作台 → 版本链快照 → 定稿层。
- **5 步场景写作循环**：plan-slice（切片规划） → draft（初稿） → polish（润色） → expand（扩写） → rewrite（重写） → finalize（定稿）。
- **角色驱动**：场景行为从 "环境切片 + 角色状态" 推出，不接受 "让 A 做 B" 的命令式指令；作者用 `@force:` 开后门时需附合理性偏离说明。
- **意图集中识别**：作者用自然语言表达（polish/expand/rewrite/finalize/rollback），入口路由到对应 skill，不需要记命令。
- **跨平台单一事实源**：`SKILL.md` frontmatter 是 Codex 和 Claude Code 共用的触发元数据，两份平台清单由脚本生成。
- **bash 脚本**（不再使用 PowerShell）：Windows 用 Git Bash 或 WSL 执行；Linux/macOS 原生执行。

## 安装

把仓库克隆到本地插件目录：

```bash
git clone <repo-url-or-local-path> /path/to/plugins/novel-driver
```

在 marketplace 配置里注册为本地插件源（以 Codex 为例）：

```json
{
  "plugins": [
    {
      "name": "novel-driver",
      "source": {
        "source": "local",
        "path": "/path/to/plugins/novel-driver"
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

Claude Code 环境直接读取 `.claude-plugin/plugin.json`（由脚本生成），见下节"开发"。

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
| `novel-system-reference` | 中文网文技能的共享参考。用于需要小说架构契约、证据等级、跨文档同步策略、回写边界、事实来源优先级时；供大纲、剧情、人物技能引用，不作为默认创作入口。版本历史/草稿/finalize/rollback 等流程协议由 `novel-draft-system` 管理，本技能不重复维护。 |
<!-- END:SKILLS -->

`using-novel` 是插件内部的入口分流器，只在斜杠命令 `/using-novel` 中暴露，不出现在上表。

## 仓库结构

```text
novel-driver/
├── .codex-plugin/            Codex 清单（脚本生成）
├── .claude-plugin/           Claude Code 清单（脚本生成，.gitignore）
├── assets/                   图标和展示资源
├── commands/                 斜杠命令适配层（轻量）
├── docs/plans/               设计文档
├── evals/                    手工回归用例
├── scripts/                  bash 校验和同步脚本
├── skills/                   技能创作唯一事实来源
├── test/books/<book-id>/     手测书籍工作区
├── tests/                    Python 单元测试（脚手架脚本等）
├── AGENTS.md                 插件维护规则
├── CLAUDE.md                 Claude 适配入口
├── README.md                 安装和开发说明
```

## 开发

所有脚本使用 bash。Windows 通过 Git Bash 或 WSL 执行；Linux/macOS 原生执行。依赖 Python 3（用于解析 yaml 索引与 markdown 区块）。

### 校验插件结构

```bash
bash scripts/quick-validate.sh
```

检查项：plugin.json 完整性 / SKILL.md frontmatter / skill ≤100 行 / reference ≤150 行 / commands 正确路由 / README 与清单同步 / 无 .ps1 残留。

### 重新生成 README 命令/技能表

```bash
bash scripts/generate-readme.sh          # 写回
bash scripts/generate-readme.sh --check  # 只检测漂移（CI 用）
```

### 生成两份平台清单（Codex + Claude Code）

```bash
bash scripts/generate-manifests.sh          # 写回两份
bash scripts/generate-manifests.sh --check  # 检测漂移
```

### 列出手工评测用例

```bash
bash scripts/run-evals.sh
```

### 镜像 skills/ 到外部目录（老式分发用）

```bash
bash scripts/sync-to-codex-skills.sh --target /path/to/skills-mirror           # 预览
bash scripts/sync-to-codex-skills.sh --target /path/to/skills-mirror --apply   # 真执行
```

Claude Code 原生加载时走 `.claude-plugin/plugin.json` + `.claude-plugin/commands/`（都由 `generate-manifests.sh` 产出），通常不需要此镜像。

### 在 CodeBuddy / Claude Code 中调试

CodeBuddy、Claude Code 等非 Codex 环境的加载路径：

1. **镜像 skills/ 到目标环境的 skill 搜索路径**（得到原生 skill 体验）：

   ```bash
   bash scripts/sync-to-codex-skills.sh \
     --target "$HOME/.codebuddy/plugins/marketplaces/local/novel-driver/skills" \
     --apply
   ```

2. **不镜像，让 AI 直读 `SKILL.md`**：在仓库根启动会话，依托 `AGENTS.md` 的"Skill 回退策略"，AI 会把 `./skills/<name>/SKILL.md` 当作规约读取并执行。

测试小说写作都在 `test/books/<book-id>/` 下进行。`using-novel` 的**测试模式**选书优先级：**显式 `book-id`** > **`test/current-book.yaml` 配置文件** > **默认 `demo-book`**。配置文件存在但无效时会停下提示，不静默回退到 demo-book。手测步骤见 `test/books/demo-book/MANUAL-TEST.md`。

## 单本书工作区

每本书默认包含：

- `summary.md`：高层稳定结论（定稿层）。
- `context.md`：多轮确认后的关键上下文、冲突状态、覆盖依据与待确认问题（定稿层）。
- `outline/ plot/ characters/ canon/ chapters/ inbox/`：分域定稿文件。
- `drafts/`：草稿层工作台 + 版本链（AI 默认写入位置）。
- `.draft-index.yaml`：草稿索引（脚本维护）。

详细协议见 `skills/novel-draft-system/SKILL.md` 和 `skills/novel-system-reference/references/directory-contract.md`。

## 非目标

- 这不是故事项目仓库。
- 本仓库不保存故事资料或故事状态目录（`test/books/` 下的两本测试书是受维护的夹具）。
- 本仓库不保存 `.omx` 或 `.omc` 运行时状态。
- 不做多本书并行工作区，不做云端/数据库/向量检索。
