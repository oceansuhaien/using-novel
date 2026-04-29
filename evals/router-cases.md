# Router Eval Cases

用于验证 `novel-driver:using-novel` 的意图识别与路由。

| Case | 作者输入 | 预期路由 | 预期首动作 |
| --- | --- | --- | --- |
| 筹备只一点 | "我有个废土学院的点子，帮我捋一捋。" | `novel-outline-coach` | 提炼 premise / 读者承诺 / 第一个结构缺口。 |
| 剧情筹备 | "第一卷中段太平，帮我重新排推进节奏。" | `novel-plot-weaver` | 识别阶段目标、冲突、节奏链缺口（**只在筹备期**）。 |
| 人物卡 | "按我的笔记给反派出个人物卡。" | `novel-character-card-coach` | 按证据等级分 confirmed / inference / pending。 |
| 筹备串行 | "先把 premise 立住，再出第一卷钩链。" | `novel-outline-coach` → `novel-plot-weaver` | premise 稳了才进剧情。 |
| **写新场景** | "写第 7 章，主角到清河镇茶棚对峙老周。" | `novel-scene-plan-slice` → 停下让作者过切片 → `novel-scene-draft` | plan-slice 产 slice.yaml，确认后才写。 |
| **polish 意图** | "对白太像 AI 了，再自然点。" | `novel-scene-polish` | 只读工作台正文 + identity/personality 字段。 |
| **expand 意图** | "这段太仓促，加点她的心理活动。" | `novel-scene-expand` | 读工作台 + state 的情绪/目标段。 |
| **rewrite 意图** | "老周不该这么直接，整个对峙段重写。" | `novel-scene-rewrite` → 回调 `novel-scene-plan-slice` | 产新 slice，产物只进版本链不覆盖工作台。 |
| **finalize** | "这版好，定稿 ch007。" | `novel-draft-system/scripts/draft-finalize.sh chapters/ch007` | 复制到定稿层 + 版本链补锚 + 触发状态回写。 |
| **状态回写逐个确认** | （finalize 场景后脚本打印 STATE_REWRITE_REQUIRED） | 对每个 on_stage 角色产 diff，**逐一确认**（不 batch） | 每角色 y/n/edit。 |
| **rollback** | "回滚到 v003。" | `draft-rollback.sh <asset> 3` | 工作台换成 v003 内容，v04+ 保留。 |
| **forced 后门** | "强制让她这里拔剑，不管合理性。" | scene-draft with `--forced` | 正文末尾附合理性偏离说明 3-5 条；state 不自动回写。 |
| **rewrite vs polish 边界** | "她这里改成犹豫。" | 追问"只改这一句，还是改她本段的决定？"；若是决定 → rewrite；若是表达 → polish | 不猜，问清。 |
| **草稿优先查询** | "读 ch007 给我看。" | `draft-query.sh chapters/ch007` → 命中工作台 → 返回 drafts 层 | 三层固定：drafts → snapshot → finalized。 |
| **证据纪律** | "不要编事实，只整理文件里已有的。" | 路由对应 coach，加严 evidence level | 明确标注 confirmed / inference / pending。 |
| **context 延续** | "从上次确认的方向继续，不要重开已决事项。" | 对应 coach via using-novel | 先读 `context.md` 的有效结论。 |
| **测试模式选书** | 在仓库根说"帮我建新章" | 检查 `test/current-book.yaml` → 进入该书 | 若配置无效 → 停下问，不静默回退 demo-book。 |
