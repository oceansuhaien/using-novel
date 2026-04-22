# Novel Driver 插件说明

- 该仓库根目录是此插件受维护的唯一事实来源。
- `skills/` 是技能行为的创作源目录。
- `.codex/skills/` 中的镜像是安装或同步产物，不是第二套创作目录。
- 保持入口文件精简。详细的小说工作流应放在 `skills/*/SKILL.md` 和 `skills/*/references/` 中。
- `commands` 仅作为分发适配层。不要在命令文件中重复技能主体逻辑。
- 共享的路由、目录、证据与回写规则必须集中在单一参考来源中。
- 每个面向用户的技能都必须保持 `SKILL.md` 的触发元数据与 `agents/openai.yaml` 一致。
- 后续编写 skill 时，说明、注释与面向用户的解释应尽可能使用中文；仅在保留命令、路径、协议字段名或行业通用专有名词时使用英文。
- README 应以安装说明为中心。不要重新引入仅适用于当前工作区的假设。
- 不要向此仓库加入故事资料目录、`.omx/`、`.omc/` 或其他运行时状态目录。
- 每次进行skill的开发后，都需要比对一下using-novel skill，判断是否需要新增或者修改skill路由

## Skill 回退策略（非 Codex 环境）

当前仓库是 Codex 插件。当 AI 运行在非 Codex 环境（例如 Claude Code、CodeBuddy、其他未注册本插件的 IDE）、无法通过原生 skill 加载器识别 `using-novel`、`novel-outline-coach`、`novel-plot-weaver`、`novel-character-card-coach`、`novel-book-scaffold`、`novel-system-reference` 时：

- 不要拒绝任务，也不要用通用常识硬答。
- 直接把 `./skills/<skill-name>/SKILL.md` 当作技能规约文件读取，并按其描述的预检、路由、回写规则工作。
- 用户显式敲 `/using-novel` 或语义上触发它时，等价于读取 `./skills/using-novel/SKILL.md` 并执行其「开工前预检 + 组合规则」。
- 跨技能编排（如"先建书再大纲"）必须按 `skills/using-novel/SKILL.md` 的组合规则顺序执行，不要并行。
- 回写边界不变：插件仓库根属于测试模式，故事资料只能落在 `test/books/<book-id>/`，禁止写入仓库根或 `skills/`、`commands/` 等插件目录。