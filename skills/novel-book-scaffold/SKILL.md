---
name: novel-book-scaffold
description: 用于创建新的单本书工作区、从零开始一本书、搭建 demo/test 书、补齐缺失的小说目录结构，在 `test/books/<book-id>/` 下创建或修复本地中文网文项目脚手架；也适用于 `novel-driver` 自身的开发、示例或测试夹具准备。
---

# 小说项目脚手架

## 作用

在 `test/books/<book-id>/` 下创建一个单本书工作区，并初始化 `novel-driver` 技能使用的小说架构模块。

本技能只负责文件系统脚手架。脚手架创建后，具体故事开发应回到 `novel-driver:using-novel`，或直接使用大纲、剧情、人物技能。

## 工作流

1. 确定工作区根目录。用户指定时按用户路径；否则使用当前目录。如果当前目录是 `novel-driver` 插件仓库，优先选择它的父级故事工作区，避免把故事状态写进插件仓库。
2. 确定书名和文件夹 id。用户只给书名时，让脚本自动生成安全文件夹名。
3. 从本技能目录运行 `scripts/create_book_scaffold.py`。
4. 报告创建的书籍根目录，以及哪些已有文件被保留。

除非用户明确要求创建插件测试夹具，否则不要在 `novel-driver` 插件仓库内创建故事状态。

## 命令

使用脚本，不要手工重建目录树：

```bash
python scripts/create_book_scaffold.py "药王" --root /path/to/workspace
```

Windows 上如果没有直接可用的 `python`，可使用项目运行器：

```bash
uv run python scripts/create_book_scaffold.py "药王" --root C:\person\code\小说项目
```

常用参数：

| 参数 | 作用 |
| --- | --- |
| `--root PATH` | 接收 `test/books/` 的工作区根目录，默认当前目录。 |
| `--id NAME` | `test/books/` 下的文件夹名，默认由书名清理生成。 |
| `--allow-existing` | 在已有书籍目录中补齐缺失文件，不覆盖已有内容。 |
| `--dry-run` | 只打印计划路径，不写入文件。 |

## 创建结构

脚本创建：

```text
test/books/<book-id>/
  README.md
  summary.md
  outline/
    premise.md
    volumes.md
    worldbuilding.md
  plot/
    mainline.md
    hidden-threads.md
    foreshadowing.md
    beats.md
    volume-hooks.md
  characters/
    index.md
    cards/.gitkeep
    relationships/main-relationships.md
  chapters/
    notes/.gitkeep
    extracts/.gitkeep
  canon/
    timeline.md
    factions.md
    locations.md
  inbox/
    raw-ideas.md
    unresolved-questions.md
```

## 创建后

- 后续小说工作应以书籍根目录为工作目录。
- 高层稳定状态写入 `summary.md`。
- 大纲、剧情、人物、章节、canon、inbox 资料写入对应子目录。
- 不要覆盖已有书籍文件，除非用户明确要求。

## 常见错误

| 错误 | 修正 |
| --- | --- |
| 只在仓库根目录创建故事状态 | 在 `test/books/<book-id>/` 下创建单本书根目录。 |
| 把所有故事笔记都放进 `summary.md` | 细节超过高层状态后写入对应子目录。 |
| 手工重建文件树 | 运行脚本，确保目录名与 novel-driver 保持一致。 |
| 误从 `novel-driver/` 内运行 | 用 `--root` 指向故事工作区父目录。 |
