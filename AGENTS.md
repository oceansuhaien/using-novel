# Novel Driver 插件说明

- 该仓库根目录是此插件受维护的唯一事实来源。
- `skills/` 是技能行为的创作源目录。
- `.codex/skills/` 中的镜像是安装或同步产物，不是第二套创作目录。
- 保持入口文件精简。每个 `SKILL.md` 目标 ≤100 行；详细规则放 `skills/*/references/`。
- `commands` 仅作为分发适配层。不要在命令文件中重复技能主体逻辑。
- 共享协议只住在 `novel-system-reference` 和 `novel-draft-system`，其他 skill 通过引用调用。
- `SKILL.md` frontmatter（name + description）是跨平台（Codex / Claude Code）唯一事实源。
- `agents/openai.yaml` 仅作为 Codex 加载器的元数据副本，不承载独立逻辑。
- 后续编写 skill 时，说明、注释与面向用户的解释应尽可能使用中文；仅在保留命令、路径、协议字段名或行业通用专有名词时使用英文。
- README 应以安装说明为中心。不要重新引入仅适用于当前工作区的假设。
- 不要向此仓库加入故事资料目录、`.omx/`、`.omc/` 或其他运行时状态目录。
- 所有脚本使用 bash（不保留 PowerShell），Windows 用 Git Bash / WSL 执行。
- 每次进行 skill 的开发后，都需要比对一下 using-novel skill，判断是否需要新增或者修改 skill 路由。

## 草稿版本系统

所有 AI 写入小说仓库的文件默认落草稿层（`drafts/`）。查询顺序固定：草稿工作台 → 版本链最新快照 → 定稿层。只有作者明确 finalize 才转定稿。详见 `skills/novel-draft-system/SKILL.md`。

## 跨平台适配

- `.codex-plugin/plugin.json`：Codex 清单。
- `.claude-plugin/plugin.json`：Claude Code 清单（由 `scripts/generate-manifests.sh` 生成）。
- 两份清单都从 `SKILL.md` frontmatter 自动生成。CI 用 `scripts/quick-validate.sh` 检测漂移。

## Skill 回退策略（非 Codex 环境）

当前仓库是 Codex 插件。当 AI 运行在非 Codex 环境（例如 Claude Code、CodeBuddy、其他未注册本插件的 IDE）、无法通过原生 skill 加载器识别 `using-novel`、`novel-outline-coach`、`novel-plot-weaver`、`novel-character-card-coach`、`novel-book-scaffold`、`novel-system-reference`、`novel-draft-system` 时：

- 不要拒绝任务，也不要用通用常识硬答。
- 直接把 `./skills/<skill-name>/SKILL.md` 当作技能规约文件读取，并按其描述的预检、路由、回写规则工作。
- 用户显式敲 `/using-novel` 或语义上触发它时，等价于读取 `./skills/using-novel/SKILL.md` 并执行其「开工前预检 + 组合规则」。
- 跨技能编排（如"先建书再大纲"）必须按 `skills/using-novel/SKILL.md` 的组合规则顺序执行，不要并行。
- 回写边界不变：插件仓库根属于测试模式，故事资料只能落在 `test/books/<book-id>/`，禁止写入仓库根或 `skills/`、`commands/` 等插件目录。
