---
name: novel-book-scaffold
description: 用于创建新的单本书工作区、从零开始一本书、搭建 demo/test 书、补齐缺失的小说目录结构，在 `test/books/<book-id>/` 下创建或修复本地中文网文项目脚手架；脚手架包含定稿层目录和草稿层 `drafts/` 以及初始 `.draft-index.yaml`，所有后续写入由 `novel-draft-system` 管理。
---

# 小说项目脚手架

## 作用

在 `test/books/<book-id>/` 下创建或修复单本书工作区。**只负责文件系统脚手架**，故事开发走 `using-novel` 或具体 coach/scene 技能。

脚手架同时初始化**草稿协议**（drafts/ 目录 + .draft-index.yaml），所有后续写入由 `novel-draft-system` 管理。

## 工作流

1. 确定工作区根目录：用户指定优先；否则用当前目录。cwd 是 `novel-driver` 插件仓库时**必须**走 test 模式（在 `test/books/` 下），不写入仓库根。
2. 确定书名和文件夹 id（用户只给书名时脚本自动 sanitize）。
3. 从本技能目录运行 `scripts/create_book_scaffold.py`。
4. 报告创建的根目录、新建文件清单、保留的已有文件。

## 命令

```bash
python skills/novel-book-scaffold/scripts/create_book_scaffold.py "药王" --root /path/to/workspace
```

Windows 下如果没有直接 `python`，可用 `uv run python ...` 或 Git Bash 下的 `python`。

常用参数：

| 参数 | 作用 |
| --- | --- |
| `--root PATH` | 接收 `test/books/` 的工作区根目录，默认当前目录。 |
| `--id NAME` | `test/books/` 下的文件夹名，默认由书名清理生成。 |
| `--allow-existing` | 在已有书籍目录中补齐缺失文件，不覆盖已有内容。 |
| `--dry-run` | 只打印计划路径，不写入文件。 |

## 创建结构

```text
test/books/<book-id>/
  README.md
  summary.md                  # 定稿层（初始模板）
  context.md                  # 定稿层（初始模板）
  outline/ plot/ characters/ canon/ chapters/ inbox/   # 定稿层目录（带初始文件）
  drafts/                     # ★ 草稿层根目录（由 draft-write.sh 生成子目录）
    .gitkeep
  .draft-index.yaml           # ★ 草稿索引（由 draft-index-update.sh 维护）
```

草稿层子目录（`drafts/outline/`、`drafts/characters/<id>/state.md` 等）在**首次写入时**由 `scripts/draft-write.sh` 自动创建，不预建空目录，避免垃圾。

## 补齐已有书籍

对既有书籍目录跑 `--allow-existing`：

- 不覆盖任何已有文件。
- **补建** `drafts/` 目录（如果缺）和 `.draft-index.yaml`（如果缺）。
- 这样可把阶段 C 之前的老书籍安全升级到新结构。

## 创建后

- 后续以书籍根目录为工作目录。
- 高层稳定状态走 `summary.md`（经草稿协议工作台）。
- 多轮确认后的关键上下文、冲突、覆盖依据走 `context.md`（经草稿协议工作台）。
- 大纲 / 剧情 / 人物 / 章节 / canon / inbox 资料走各自子目录，**默认通过 `drafts/` 工作台改**，用户 finalize 才进定稿层。
- 回到 `using-novel` 或 coach 技能后，应优先通过 `draft-query.sh <asset>` 读取资产（三层查询顺序由协议保证）。
- 除非用户明确要求，不要覆盖已有书籍文件。

## 常见错误

| 错误 | 修正 |
| --- | --- |
| 只在仓库根目录创建故事状态 | 在 `test/books/<book-id>/` 下创建单本书根目录。 |
| 把所有故事笔记都放进 `summary.md` | 细节超过高层状态后写入对应子目录。 |
| 手工重建文件树 | 运行脚本，确保目录名与 novel-driver 保持一致。 |
| 误从 `novel-driver/` 内运行 | 用 `--root` 指向故事工作区父目录。 |
| 忘记 `.draft-index.yaml` | 脚本会生成；已有老书籍跑 `--allow-existing` 补上。 |

## 不做的事

- 不做大纲/剧情/人物内容（→ 对应 coach skill）。
- 不做场景正文（→ scene-* 系列）。
- 不擅自覆盖已有文件。
- 不建空的 `drafts/<category>/` 子目录——让 `draft-write.sh` 按需创建。
