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


def render_files(title: str) -> dict[str, str]:
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
        "inbox/raw-ideas.md": "# 原始灵感\n\n待定。\n",
        "inbox/unresolved-questions.md": "# 未解决问题\n\n待定。\n",
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

    planned_files = render_files(title)
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
