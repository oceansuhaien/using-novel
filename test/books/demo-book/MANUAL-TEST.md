# Demo Book 手测清单（V2）

本清单用于在开发 `novel-driver` 插件时，基于 `test/books/demo-book/` 做可重复的本地手测。V2 架构已引入草稿版本系统和 5 步场景写作循环。

## 0. 准备

在插件仓库根运行结构校验：

```bash
bash scripts/quick-validate.sh
```

如果测试环境读取的是外部 skills mirror，先同步：

```bash
bash scripts/sync-to-codex-skills.sh \
  --target "$HOME/.codebuddy/plugins/marketplaces/local/novel-driver/skills" \
  --apply
```

## 1. 选择测试入口目录

两种等价方式任选其一：

**方式 A：在插件仓库根启动（推荐，用于开发插件时）**

```bash
cd d:/code/uncompany/using-novel
```

`using-novel` 的开工预检会识别 cwd 为插件仓库根（`AGENTS.md` + `skills/using-novel/SKILL.md` 同时存在），进入**测试模式**。没有显式 book-id 时先读 `test/current-book.yaml`；配置文件不存在时才回退到 `test/books/demo-book/`；**配置文件存在但无效时应停下来提示**，不静默改走 demo-book。

要求：

- 回答首句应声明类似"检测到插件仓库根，进入测试模式，目标书籍根 `test/books/demo-book/`"。
- 想临时换书就在请求里显式指明 book-id（优先级高于配置文件）。
- 任何回写必须落在 `test/books/<book-id>/` 内，不得落到仓库根或 `skills/`、`commands/` 等插件目录。

**方式 B：直接进入书籍根（正式模式）**

```bash
cd d:/code/uncompany/using-novel/test/books/demo-book
```

要求：

- 预检识别为书籍根，进入**正式模式**。
- 所有小说技能从这里发起。
- 回写目标必须落在当前目录下。

## 2. 意图识别与路由测试

所有测试都在书籍根目录发起会话。

### 2.1 `/using-novel` 综合路由

```text
/using-novel 我想写一本都市异能爽文。主角能看见别人寿命余额，但每次修改命运都会反噬自己。先帮我整理成可连载的大纲，并指出最该先定的剧情风险。
```

通过标准：能路由到合适的筹备技能（先 outline），不泛泛聊天。

### 2.2 `/novel-outline` 大纲回写（走草稿协议）

```text
/novel-outline 基于当前项目，补出题材定位、核心卖点、故事前提，并给出三卷卷纲草案。
```

重点检查：

- 产出落**草稿层**：`drafts/outline/premise.md`、`drafts/outline/volumes.md` 等，而非直接写定稿层。
- `.draft-index.yaml` 更新对应 asset 的 current_ver。
- 未经作者 finalize 之前，`outline/` 定稿层不变。
- 作者说"定稿" → 触发 `draft-finalize.sh`，此时才复制到定稿层。

### 2.3 `/novel-plot` 筹备期剧情规划

```text
/novel-plot 基于当前项目，设计主线推进、两条暗线、三个伏笔和第一卷结尾钩子。
```

重点检查：

- 产出落 `drafts/plot/*.md`。
- 未确认推断显式标注为 `建议` / `备选` / `待确认`。
- `novel-plot-weaver` **不越界**进入正文阶段（V2 收窄到筹备期）。

### 2.4 `/novel-character` 人物卡 + state.md

```text
/novel-character 基于当前项目，为主角做一张单角色深度人物卡，并补一份主要人物关系草图。
```

重点检查：

- 单角色卡 → `drafts/characters/cards/<id>.md`。
- 关系卡 → `drafts/characters/relationships/`。
- **新建角色时必须同时初始化 state.md**：`drafts/characters/<id>/state.md`（当前处境 / 目标 / 情绪三项）。
- state.md **无定稿层**，试图 finalize 它会被拒绝。

### 2.5 `/novel-scene` 场景写作 5 步循环

按顺序走完 T1→T6：

**T1 plan-slice**：
```text
/novel-scene 写第 3 章，主角第一次在桌上遇到竞争对手老周，时间是清晨茶棚，马蹄声从北面传来。
```

期望：产 `drafts/chapters/ch003.slice.yaml` + 版本链。**停下等作者确认切片**，不自动写正文。

**T2 draft（作者确认后）**：
```text
可以，继续
```

期望：产 v001-draft.md + 同步工作台。

**T3 polish**：
```text
对白再自然点，去 AI 味
```

期望：产 v002-polish.md；事件主干/角色决定/场景结构不变；画面感/张力/情绪较上一版不退步；长度随改动自然起伏，**不做 ±N% 字数校验**。

**T4 expand**：
```text
加点主角的心理活动
```

期望：产 v003-expand.md；事件不变；新增内心戏落到念头/身体反应/外部反应上，不堆空形容词；**不设字数硬上限**，除非必须改事件才能继续加料（此时应停下提示转 rewrite）。

**T5 rewrite**：
```text
老周不该这么直接，整段重写
```

期望：先回调 plan-slice 产新切片 → 写新正文。**产物只进版本链快照，工作台保留上一版**，提示作者对比后运行 `draft-sync.sh`。

**T6 finalize**：
```text
这版好，定稿 ch003
```

期望：
- 复制工作台到 `chapters/ch003.md` 定稿层。
- 版本链补 v00N-finalized.md 锚点。
- 触发状态回写：脚本打印 `STATE_REWRITE_REQUIRED`，**逐个角色** diff 确认（不 batch）。
- 作者确认每个角色的 diff → 应用到 `drafts/characters/<id>/state.md`。
- 强制模式（forced=true）的场景跳过自动回写，提示 `SKIP_STATE_REWRITE`。

## 3. 回滚测试

```text
回滚 ch003 到 v002
```

期望：工作台恢复为 v002 内容；**后续 v003/v004 不删除**；下次新写编号为 max+1。

## 4. 强制后门

```text
@force 让主角这里直接拔刀砍人，不管合理性
```

期望：
- 正文末尾附 **合理性偏离说明**（3-5 条）。
- 快照 yaml 头 `forced: true`。
- 不自动触发状态回写。
- 全书 forced 占比 >15% 时 `.draft-index.yaml` 相关脚本发 warning。

## 5. 冲突与二次确认

先确认一个方向，再给相反指令：

```text
/novel-outline 把这本书的主旨定成"底层求生者为了保住尊严，宁可失去力量也不接受被收编"。
```

```text
/novel-outline 现在我把第一卷改成轻松校园日常，主线先不要碰生存压力。
```

通过标准：
- 指出冲突，不直接覆盖。
- 追问一个最小必要问题。
- 冲突信息写入 `context.md` 工作台。
- 确认方向后同步更新相关 asset 的草稿。

## 6. 回归检查

手测结束后回仓库根：

```bash
cd d:/code/uncompany/using-novel
bash scripts/quick-validate.sh
bash scripts/run-evals.sh
python -m unittest tests.test_create_book_scaffold
```

检查点：

- 校验脚本全绿。
- Python 单元测试通过。
- `test/books/demo-book/` 之外没有意外生成故事文件。
- 索引 `.draft-index.yaml` 与 `drafts/` 真实文件系统一致（`bash skills/novel-draft-system/scripts/draft-index-update.sh --check`）。

## 7. 长期用法建议

- 把 `demo-book` 保留为空白基线夹具。
- `back-to-2008` 保留作为"已有一些筹备内容"的夹具。
- 每次改动技能回写规则、路由或目录契约后，至少重跑本清单中"意图识别与路由测试"部分。
