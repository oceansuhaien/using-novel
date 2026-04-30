#!/usr/bin/env python3
"""在 test/books 下创建 novel-driver 单本书工作区。"""

from __future__ import annotations

import argparse
import re
import sys
from pathlib import Path


INVALID_PATH_CHARS = r'<>:"/\|?*'
RESERVED_WINDOWS_NAMES = {
    "CON",
    "PRN",
    "AUX",
    "NUL",
    *(f"COM{i}" for i in range(1, 10)),
    *(f"LPT{i}" for i in range(1, 10)),
}


def sanitize_folder_name(value: str) -> str:
    cleaned = value.strip()
    cleaned = "".join("-" if ch in INVALID_PATH_CHARS else ch for ch in cleaned)
    cleaned = re.sub(r"\s+", "-", cleaned)
    cleaned = re.sub(r"-{2,}", "-", cleaned).strip(" .-")
    if not cleaned:
        cleaned = "untitled-book"
    if cleaned.upper() in RESERVED_WINDOWS_NAMES:
        cleaned = f"{cleaned}-book"
    return cleaned


def is_relative_to(path: Path, parent: Path) -> bool:
    try:
        path.relative_to(parent)
    except ValueError:
        return False
    return True


def render_files(title: str, book_id: str) -> dict[str, str]:
    return {
        "README.md": f"""# {title}

这是一个 novel-driver 单本书工作区。

- 故事状态保存在当前目录的小说架构模块中。
- 开发大纲、剧情、人物和 canon 时，请从本书根目录使用 novel-driver 技能。
""",
        "summary.md": f"""# {title} 项目摘要

## 项目快照

状态：脚手架草稿

## 核心主旨

贯穿全书的思想与价值母题（Theme，作者价值观层）。与"核心承诺"分栏维护。

- 主旨一句话：待定
- 反命题：待定
- 结局如何回应：兑现 / 反证 / 留白（待定）
- 承载主旨的主要剧情压力：待定
- 状态：草稿

## 核心承诺

读者市场/情绪层的承诺。与"核心主旨"区分开。

待定。

## 故事大纲

待定。

## 卷纲

待定。

## 世界观 Canon

待定。

## 人物总览

待定。

## 开放问题

- 核心主旨是否已有一句话，并写出了反命题？
- 核心读者承诺是什么？
""",
        "context.md": """# 项目上下文

本文件用于记录多轮讨论后的关键确认、冲突、覆盖依据和待用户确认问题。

它不是完整聊天记录，也不是第二份 summary.md；稳定高层结论仍以 summary.md 和各领域文件为准。

## 会话目标

待定。

## 当前有效结论

待补充。

## 最近确认

- 暂无。

## 冲突清单

- 暂无。

## 待用户确认

- 暂无。

## 影响范围

待补充。

## 覆盖历史

- 暂无。
""",
        "outline/premise.md": "# 故事前提\n\n## 核心主旨\n\n贯穿全书的思想与价值母题。summary.md 只放一句话与反命题，本文件用于展开主旨的长论述、与主线的咬合点、结局回应方式等。\n\n待定。\n\n## 故事前提\n\n待定。\n",

        "outline/volumes.md": "# 卷纲\n\n待定。\n",
        "outline/worldbuilding.md": "# 世界观大纲\n\n待定。\n",
        "plot/mainline.md": "# 剧情主线\n\n待定。\n",
        "plot/hidden-threads.md": "# 暗线\n\n待定。\n",
        "plot/foreshadowing.md": "# 伏笔\n\n待定。\n",
        "plot/beats.md": "# 剧情节点\n\n待定。\n",
        "plot/volume-hooks.md": "# 卷钩子\n\n待定。\n",
        "characters/index.md": "# 人物索引\n\n待定。\n",
        "characters/relationships/main-relationships.md": "# 主要人物关系\n\n待定。\n",
        "chapters/notes/.gitkeep": "",
        "chapters/extracts/.gitkeep": "",
        "characters/cards/.gitkeep": "",
        "canon/timeline.md": "# 时间线\n\n待定。\n",
        "canon/factions.md": "# 势力\n\n待定。\n",
        "canon/locations.md": "# 地点\n\n待定。\n",
        "inbox/README.md": """# inbox/ — 作者投递区

本目录用于作者手动投递**外部草稿、原始灵感、未解决问题**。它不是定稿层，也不是草稿工作台；它是进入草稿系统**之前**的中转站。

## 常见用法

### 1. 外部草稿导入（最常见）

作者把自己手打的章节正文放到 `inbox/<任意文件名>.md`，然后对 AI 说：

> 帮我把 `@inbox/第七章草稿.md` 导入为 ch007，去 AI 味、稍微加点环境描写。

AI（通过 `using-novel` 的 import 路由）会：

1. 调 `bash scripts/draft-write.sh chapters/ch007 manual inbox/第七章草稿.md --source imported --note "imported from inbox/第七章草稿.md"`。
   - 版本链：`drafts/chapters/ch007.drafts/v001-manual.md`
   - 工作台：`drafts/chapters/ch007.md`
   - 头部自动带 `source: imported` 标记。
2. 按作者同一句里的二级意图继续路由到 `scene-polish` / `scene-expand` / `scene-rewrite`。

**关键保证**：`scene-polish` / `scene-expand` 的硬红线决定了导入稿不会被 AI 擅自改事件、改角色决定、加新场景。只有在作者明确说"重写"时才走 `scene-rewrite`。

### 2. 原始灵感池

随手记的设定碎片、人物闪念、剧情点子，走 `raw-ideas.md`。后续由 outline / plot / character coach 按需消化。

### 3. 未解决问题

卡点、待决策清单，走 `unresolved-questions.md`。

## 不做的事

- 不直接写进 `chapters/` 定稿层（那由 finalize 触发）。
- 不直接写进 `drafts/` 工作台（那由 `draft-write.sh` 管）。
- 不把这里的文件当"备份"——它们随时可能被作者重写或删除。
""",
        "inbox/raw-ideas.md": """# 原始灵感

随手记的设定碎片、人物闪念、剧情点子放这里。后续由 outline / plot / character coach 按需消化。

待定。
""",
        "inbox/unresolved-questions.md": """# 未解决问题

卡点、待决策清单放这里。解决后再迁入 `context.md` 或 `plot/` / `canon/`。

待定。
""",
        # 草稿版本系统（novel-draft-system）
        "drafts/.gitkeep": "",
        ".draft-index.yaml": f"""book_id: {book_id}
updated_at: 1970-01-01T00:00:00Z
assets: {{}}
stats:
  total_assets: 0
  forced_count: 0
  forced_ratio: 0.0
""",
    }


def create_scaffold(
    *,
    title: str,
    root: Path,
    folder_id: str | None,
    allow_existing: bool,
    dry_run: bool,
) -> tuple[Path, list[Path], list[Path]]:
    resolved_root = root.resolve()
    books_dir = resolved_root / "test" / "books"
    book_id = sanitize_folder_name(folder_id or title)
    target = (books_dir / book_id).resolve()

    if not is_relative_to(target, books_dir.resolve()):
        raise ValueError(f"拒绝在 test/books 之外创建目录: {target}")

    if target.exists() and not allow_existing:
        raise FileExistsError(
            f"{target} 已存在。使用 --allow-existing 可只补齐缺失脚手架文件。"
        )

    planned_files = render_files(title, book_id)
    created: list[Path] = []
    skipped: list[Path] = []

    if dry_run:
        return target, [target / relative for relative in planned_files], skipped

    for relative, content in planned_files.items():
        path = target / relative
        path.parent.mkdir(parents=True, exist_ok=True)
        if path.exists():
            skipped.append(path)
            continue
        path.write_text(content, encoding="utf-8", newline="\n")
        created.append(path)

    return target, created, skipped


def parse_args(argv: list[str]) -> argparse.Namespace:
    parser = argparse.ArgumentParser(
        description="在 test/books 下创建 novel-driver 单本书脚手架。"
    )
    parser.add_argument("title", help="写入初始 Markdown 文件的书名。")
    parser.add_argument(
        "--root",
        default=".",
        type=Path,
        help="接收 test/books 的工作区根目录，默认当前目录。",
    )
    parser.add_argument(
        "--id",
        dest="folder_id",
        help="test/books 下的文件夹名，默认由书名清理生成。",
    )
    parser.add_argument(
        "--allow-existing",
        action="store_true",
        help="补齐缺失脚手架文件，不覆盖已有文件。",
    )
    parser.add_argument(
        "--dry-run",
        action="store_true",
        help="只打印计划创建的文件，不写入。",
    )
    return parser.parse_args(argv)


def main(argv: list[str]) -> int:
    args = parse_args(argv)
    try:
        target, created, skipped = create_scaffold(
            title=args.title,
            root=args.root,
            folder_id=args.folder_id,
            allow_existing=args.allow_existing,
            dry_run=args.dry_run,
        )
    except (OSError, ValueError) as error:
        print(f"错误: {error}", file=sys.stderr)
        return 1

    if args.dry_run:
        print(f"书籍根目录: {target}")
        print("计划文件:")
        for path in created:
            print(f"  {path}")
        return 0

    print(f"书籍根目录: {target}")
    print(f"已创建文件: {len(created)}")
    for path in created:
        print(f"  已创建 {path}")
    if skipped:
        print(f"保留已有文件: {len(skipped)}")
        for path in skipped:
            print(f"  已保留 {path}")
    return 0


if __name__ == "__main__":
    raise SystemExit(main(sys.argv[1:]))
