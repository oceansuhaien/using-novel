# 脚本使用指南

本文件是 `novel-draft-system` 的按需读取参考。仅在调用脚本时确认参数格式和退出码。

所有脚本都在 `skills/novel-draft-system/scripts/` 下，bash 实现，Windows 用 Git Bash / WSL 执行。

## 公共约定

- **工作目录**：脚本必须在书籍根 (`<book-root>/`) 下运行，否则退出码 2。
- **退出码**：`0` 成功；`1` 通用错误；`2` 环境/参数错误；`3` asset 状态不一致（例如试图 finalize 一个不存在的工作台）。
- **字符编码**：所有读写 UTF-8 无 BOM。
- **时间戳**：统一 ISO 8601 UTC，格式 `YYYY-MM-DDTHH:MM:SSZ`。

## scripts/draft-write.sh

写一版草稿：版本链 + 工作台同步。

```bash
draft-write.sh <asset> <kind> <content-file> [--from-ver N] [--forced] [--note "..."] [--slice-ref "..."]
```

- `<asset>`：如 `chapters/ch007` 或 `characters/lin_wan/state`。
- `<kind>`：白名单之一（见 snapshot-schema.md）。
- `<content-file>`：正文源文件路径（脚本会读取并插入 yaml 头）。
- `--from-ver N`：基于哪一版，省略时默认 max(ver)。
- `--forced`：标记 forced=true，要求 content-file 末尾已有"合理性偏离说明"章节。
- `--note`：author_note 字段，≤200 字。
- `--slice-ref`：slice 文件相对路径。

默认行为：先写 `vNNN-<kind>.md`，再覆盖工作台。  
**例外：kind=rewrite 时不覆盖工作台**，需显式调 `draft-sync.sh`。

## scripts/draft-sync.sh

把某个版本链快照同步为工作台（用于 rewrite 作者确认后，或手工回退某版为工作台）。

```bash
draft-sync.sh <asset> <ver>
```

复制 `drafts/<asset>.drafts/v<ver>-*.md` 到 `drafts/<asset>.md`，不更新 `.draft-index.yaml` 的 current_ver（current_ver 永远 = 最新写入的版本号，不是"当前工作台来自哪版"）。

## scripts/draft-finalize.sh

finalize 一个资产。

```bash
draft-finalize.sh <asset> [--note "..."]
```

按 finalize-flow.md 的步骤执行。若 asset 属于 chapters/ → 脚本不直接跑状态回写，而是打印一条 `STATE_REWRITE_REQUIRED: <scene>`，由上层 skill 接手调用 `state-rewrite.sh`。

## scripts/draft-rollback.sh

回滚到某版本。

```bash
draft-rollback.sh <asset> <ver>
```

## scripts/state-rewrite.sh

对已 finalize 的场景触发状态回写（或补触发）。

```bash
state-rewrite.sh <scene-asset>
```

- 读 `drafts/<scene-asset>.md` 和 `drafts/<scene-asset>.slice.yaml` 的 on_stage。
- 对每个角色产出 diff 建议（需 LLM 能力，脚本只做文件 I/O 和流程控制；diff 建议由上层 skill 生成后写入 `/tmp/state-diff-<角色>.md`，脚本读这个临时文件作为 diff 源）。
- 交互模式逐个确认，支持 y/n/编辑。
- 应用 diff 到 `state.md`，旧版进 `state.drafts/v<N>-manual.md`。

## scripts/draft-index-update.sh

重新扫描 drafts/ 全目录，重建 `.draft-index.yaml`。用于从旧仓库迁移、或索引漂移时修复。

```bash
draft-index-update.sh [--check]
```

- `--check`：不写回，只检测漂移，漂移退出 1。
- 无参数：扫描 + 重建。

## scripts/draft-query.sh

按三层查询顺序定位一个 asset。

```bash
draft-query.sh <asset>
```

输出：
- 第一行：`LAYER: drafts | snapshot | finalized | miss`
- 第二行及以后：命中文件的内容（miss 时为空）。

AI 读小说资产时应优先调用此脚本而不是手动遍历路径。
