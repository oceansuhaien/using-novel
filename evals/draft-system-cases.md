# Draft System Eval Cases

用于验证 `novel-draft-system` 的草稿版本系统协议。

## 路径与查询

| Case | 输入 | 预期结果 |
| --- | --- | --- |
| 工作台优先 | 有 `drafts/chapters/ch007.md` 和 `chapters/ch007.md` | `draft-query.sh` 返回 `LAYER: drafts` |
| 降级快照 | 只有 `drafts/chapters/ch007.drafts/v003-rewrite.md` | 返回 `LAYER: snapshot` 的 v003 内容 |
| 降级定稿 | 只有 `chapters/ch007.md` | 返回 `LAYER: finalized` |
| 三层 miss | 都没有 | 返回 `LAYER: miss`，不猜测拼接 |

## 写入与版本链

| Case | 操作 | 预期 |
| --- | --- | --- |
| draft 自动同步工作台 | `draft-write.sh chapters/ch007 draft f.md` | 产 v001-draft.md 且工作台同步 |
| polish 事件主干不变 | `draft-write.sh ... polish f.md` | 事件结果/角色决定/场景结构不变；长度不做 ±N% 校验 |
| **rewrite 不覆盖工作台** | `draft-write.sh ... rewrite f.md` | 只产 vNNN-rewrite.md 快照；工作台保留上一版；打印 HINT 提示 `draft-sync.sh` |
| draft-sync 显式同步 | `draft-sync.sh chapters/ch007 4` | 工作台更新为 v004 内容 |
| 版本号跨 kind 连续 | 依次 draft→polish→rewrite | 文件名为 v001/v002/v003 连续递增 |

## forced 后门

| Case | 操作 | 预期 |
| --- | --- | --- |
| 缺偏离说明拒绝 | `--forced` 但正文无 `## 合理性偏离说明` | 脚本 exit 3，不写入 |
| 带偏离说明成功 | 正文末尾 3-5 条偏离说明 | 产 vNNN-forced.md，yaml 头 `forced: true` |
| 比例预警 | 全书 forced 比 >15% | `draft-index-update.sh` stderr 输出 `WARN: forced ratio X% exceeds 15% threshold` |

## finalize 与状态回写

| Case | 操作 | 预期 |
| --- | --- | --- |
| 场景 finalize | `draft-finalize.sh chapters/ch007` | 复制到 `chapters/ch007.md` + 补 v00N-finalized 锚点 + 打印 `STATE_REWRITE_REQUIRED` |
| state 资产不能 finalize | `draft-finalize.sh characters/lin_wan/state` | exit 3，拒绝 |
| slice 资产不能 finalize | `draft-finalize.sh chapters/ch007.slice` | exit 3，拒绝 |
| forced 场景跳过自动回写 | finalize 一个 forced=true 的场景 | 打印 `SKIP_STATE_REWRITE`，不自动触发 |
| 状态回写逐个确认 | `state-rewrite.sh list` 列出 on_stage 角色 | 每个角色独立输出 diff，作者逐一 y/n/edit |
| 状态回写补触发 | `state-rewrite.sh apply chapters/ch007 lin_wan` | 读 /tmp/state-diff-lin_wan.md 应用，旧 state 进 state.drafts/ |

## rollback

| Case | 操作 | 预期 |
| --- | --- | --- |
| 回滚保留后续 | `draft-rollback.sh chapters/ch007 1`（当前最大 v004） | 工作台 = v001 内容；v002/v003/v004 不删除 |
| 下次新写编号 | rollback 后 `draft-write.sh ... draft` | 产 v005-draft.md（继续从 max+1） |
| finalize 后 rollback | finalize 后再 rollback | 定稿层不变；索引 finalized 保持 true（由 reindex 从文件系统真相重建） |

## 索引一致性

| Case | 操作 | 预期 |
| --- | --- | --- |
| 索引漂移检测 | 手改 `.draft-index.yaml` 后跑 `draft-index-update.sh --check` | 漂移 → exit 1 + stderr `INDEX_DRIFT` |
| 全量重扫 | `draft-index-update.sh` | 索引与 drafts/ 文件系统完全一致 |
| 跨时间戳忽略 | 重扫前后仅 `updated_at` 不同 | --check 仍然通过（比较时忽略 updated_at） |
