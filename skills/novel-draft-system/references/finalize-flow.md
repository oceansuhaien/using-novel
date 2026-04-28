# finalize / rollback / 状态回写的完整流程

本文件是 `novel-draft-system` 的按需读取参考。仅在执行 finalize / rollback / 状态回写时读取。

## finalize 完整步骤

前置条件：`drafts/<asset>.md` 存在；作者已明确触发 finalize。

1. **读取**当前工作台 `drafts/<asset>.md` 全文与 yaml 头。
2. **复制**到定稿层同名路径 `<asset>.md`（覆盖旧定稿，旧定稿已被 git history 保留）。
3. **版本链补锚**：在 `drafts/<asset>.drafts/` 下写 `v<current_ver>-finalized.md`，内容 = 工作台副本，yaml 头 kind 改为 `finalized`、timestamp 更新、author_note 填作者 finalize 时的备注（可空）。
4. **状态回写**（仅当 asset 属于 `chapters/` 类别）：
   - 读对应 slice.yaml（`drafts/<asset>.slice.yaml`）取 on_stage 列表。
   - 对每个在场角色调用 LLM 产出 state.md 的 diff 建议。
   - 作者逐个确认。
   - 确认后应用：旧 state.md 进 `state.drafts/v<N>-manual.md`，新 state.md 覆盖工作台。
   - forced=true 的场景跳过此步，提示"已跳过自动状态回写，如需请手动触发"。
5. **更新** `.draft-index.yaml`：
   - `assets.<asset>.finalized = true`
   - `assets.<asset>.finalized_at = now`
   - 刷新 stats（total_assets、forced_count、forced_ratio）。
6. **回报**：向作者输出 "finalize 完成：<asset> v<N>，定稿已更新，status: finalized"。

## rollback 完整步骤

前置条件：`drafts/<asset>.drafts/v<N>-*.md` 存在。

1. **读取** `v<N>-*.md` 内容。
2. **覆盖**工作台 `drafts/<asset>.md` 为该版本内容。
3. **不删除**后续 v(N+1)、v(N+2) 等快照。
4. **yaml 头标记**：给工作台头部补一行 `rolled_back_to: v<N>`（下次新写入时被新 yaml 覆盖）。
5. **更新** `.draft-index.yaml`：`assets.<asset>.current_ver` 保持不变（下次新操作仍从 max+1 编号），但 `last_kind = rollback-to-v<N>`。
6. **回报**："已回滚到 v<N>。后续版本 v(N+1)...v(max) 保留。下次新操作将编号为 v<max+1>。"

## 状态回写的 diff 呈现约定

LLM 产出 diff 建议时，每个角色输出如下结构（Markdown）：

```markdown
### 林婉 · state.md 变更建议

**变更 1**：当前情绪新增一条
- 新增：`- 警觉：刚发现老周识破身份`

**变更 2**：最近关系变化新增一条
- 新增：`- 老周：发现他知道真实身份（ch007）`

**变更 3**：最近经历末尾新增一条
- 新增：`- ch007：茶棚对峙，老周暗中示警`

确认？ [y / n / 修改]
```

作者答 `y` 则应用，答 `n` 则跳过这个角色，答其他则作者自己编辑 diff 后再 y。

## 每次都确认（不要 batch）

作者在第 5 节选择的是"每次都确认"。脚本实现必须一个角色一个角色来，不允许"给 3 个角色的 diff，作者一次性 ok all"。

## 状态回写的补救触发

如果作者已经 finalize 但当时 forced=true 跳过了回写，后续想补回写：

- 触发 `/rewrite-state <scene>`（或等价自然语言："帮我把 ch007 的角色状态补一下"）。
- 调用 `scripts/state-rewrite.sh <scene>`，流程同上述状态回写但跳过 forced 检查。
