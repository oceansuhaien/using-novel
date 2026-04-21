# Demo Book 手测清单

本清单用于在开发 `novel-driver` 插件时，基于 `test/books/demo-book/` 做可重复的本地手测。

## 0. 准备

先在插件仓库根目录运行结构校验：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate.ps1
```

如果你的实际测试环境读取的是外部 skills mirror，而不是当前仓库源码，先同步一次：

```powershell
powershell -ExecutionPolicy Bypass -File .\scripts\sync-to-codex-skills.ps1 -TargetRoot C:\path\to\skills-mirror -Apply
```

## 1. 进入测试书籍根目录

```powershell
Set-Location C:\person\code\novel-driver\test\books\demo-book
```

要求：

- 当前工作目录必须是书籍根目录。
- 后续所有小说技能都从这里发起。
- 回写目标应落在当前目录下，而不是插件仓库根目录。

## 2. 路由测试

在书籍根目录启动你的 Codex 会话后，分别测试下面几类请求。

### 2.1 `/using-novel` 综合路由

示例提示词：

```text
/using-novel 我想写一本都市异能爽文。主角能看见别人寿命余额，但每次修改命运都会反噬自己。先帮我整理成可连载的大纲，并指出最该先定的剧情风险。
```

通过标准：

- 能把请求路由到合适的小说技能，而不是泛泛聊天。
- 先解决高层结构，再推进下游细化。
- 不会在没有必要时一次性索取过多偏好。

### 2.2 `/novel-outline` 大纲回写

示例提示词：

```text
/novel-outline 基于当前项目，补出题材定位、核心卖点、故事前提，并给出三卷卷纲草案。
```

重点检查：

- `summary.md` 只保留高层稳定结论。
- 详细大纲应落到 `outline/premise.md`、`outline/volumes.md`、`outline/worldbuilding.md`。
- 不要把人物卡或剧情细表错误写进大纲文件。

### 2.3 `/novel-plot` 剧情回写

示例提示词：

```text
/novel-plot 基于当前项目，设计主线推进、两条暗线、三个伏笔和第一卷结尾钩子。
```

重点检查：

- 主线内容进入 `plot/mainline.md`。
- 暗线、伏笔、节点、卷钩子分别进入对应 `plot/` 文件。
- 未确认推断要显式标注，不要伪装成既定事实。

### 2.4 `/novel-character` 人物回写

示例提示词：

```text
/novel-character 基于当前项目，为主角做一张单角色深度人物卡，并补一份主要人物关系草图。
```

重点检查：

- 角色总览写入 `characters/index.md`。
- 单角色深度卡应写入 `characters/cards/`。
- 关系内容写入 `characters/relationships/main-relationships.md` 或同级关系文件。
- 高层结论可以同步到 `summary.md`，但不要把整张人物卡塞进去。

## 3. 增量更新测试

先手工补一点已有内容，例如给 [premise.md](C:/person/code/novel-driver/test/books/demo-book/outline/premise.md) 和 [summary.md](C:/person/code/novel-driver/test/books/demo-book/summary.md) 写两三行设定，再重复执行一次相关技能。

通过标准：

- 已有内容应被读取和继承，而不是被整段重写。
- 新结论只更新受影响文件。
- 如果新结论覆盖旧结论，回答里要能说清依据。

## 4. 边界测试

分别测试下面几类容易跑偏的请求：

```text
/novel-plot 先别定稿，只给我 3 个可选反转方案，并标清各自代价。
```

```text
/novel-character 现有材料不足以确定女主真实立场时，不要替我拍板，先指出最关键的确认问题。
```

```text
/using-novel 我想直接写第一章正文。
```

通过标准：

- 区分“建议”和“已确认结论”。
- 证据不足时会停下来，不会强行补设定。
- 面对正文写作请求时，能说明当前插件更偏结构化开发，而不是假装具备不存在的专门正文技能。

## 5. 回归检查

手测结束后回到插件仓库根目录，运行：

```powershell
Set-Location C:\person\code\novel-driver
powershell -ExecutionPolicy Bypass -File .\scripts\quick-validate.ps1
powershell -ExecutionPolicy Bypass -File .\scripts\run-evals.ps1
```

检查点：

- 校验脚本通过。
- evals 没有因为技能入口或路由文本变化而明显失效。
- `test/books/demo-book/` 之外没有意外生成故事文件。

## 6. 建议的长期用法

- 把 `demo-book` 保留为空白基线夹具。
- 另建一到两本测试书，分别覆盖“只有 premise 的新书”和“已有 outline/plot 的增量项目”。
- 每次改动技能回写规则、路由规则或目录契约后，至少重跑一次本清单。
