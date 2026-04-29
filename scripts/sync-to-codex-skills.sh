#!/usr/bin/env bash
# sync-to-codex-skills.sh
# 把 skills/ 单向镜像到一个外部 skills/ 目录（用于老式镜像 skill 分发）。
# Claude Code / Codex 原生加载现在走 .claude-plugin / .codex-plugin 两份清单，
# 本脚本仅在特殊环境（需要物理复制 skill 目录）时使用。
#
# 用法：
#   bash scripts/sync-to-codex-skills.sh --target /path/to/skills-mirror           # 预览
#   bash scripts/sync-to-codex-skills.sh --target /path/to/skills-mirror --apply   # 真执行

set -euo pipefail

TARGET=""
APPLY=false

usage() {
    cat >&2 <<'EOF'
Usage: sync-to-codex-skills.sh --target <dir> [--apply]

  --target <dir>   目标 skills/ 目录（必填）
  --apply          真写入；省略时只做 dry-run 预览
EOF
    exit 2
}

while [[ $# -gt 0 ]]; do
    case "$1" in
        --target) TARGET="$2"; shift 2 ;;
        --apply) APPLY=true; shift ;;
        -h|--help) usage ;;
        *) echo "ERROR: unknown arg $1" >&2; usage ;;
    esac
done

[[ -z "$TARGET" ]] && usage

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
SOURCE="$ROOT/skills"

if [[ ! -d "$SOURCE" ]]; then
    echo "ERROR: Missing source skills directory: $SOURCE" >&2
    exit 1
fi

# 解析为绝对路径
TARGET_ABS="$(cd "$(dirname "$TARGET")" 2>/dev/null && pwd || echo "")"
if [[ -z "$TARGET_ABS" ]]; then
    if $APPLY; then
        mkdir -p "$TARGET"
        TARGET_ABS="$(cd "$(dirname "$TARGET")" && pwd)"
    else
        echo "Would create target directory: $TARGET"
        TARGET_ABS="$TARGET"
    fi
fi
TARGET_ABS="${TARGET_ABS}/$(basename "$TARGET")"

for skill_dir in "$SOURCE"/*/; do
    [[ -d "$skill_dir" ]] || continue
    name="$(basename "$skill_dir")"
    dest="$TARGET_ABS/$name"

    if ! $APPLY; then
        echo "Would sync $skill_dir -> $dest"
        continue
    fi

    mkdir -p "$dest"
    # 清理目标内老文件，避免残留；然后 cp -r
    rm -rf "$dest"/*
    cp -r "$skill_dir"/* "$dest/" 2>/dev/null || true
    # 包含 hidden files（例如 .gitkeep）
    shopt -s dotglob nullglob
    for hidden in "$skill_dir".[!.]*; do
        [[ -e "$hidden" ]] && cp -r "$hidden" "$dest/"
    done
    shopt -u dotglob nullglob

    echo "Synced $name"
done

if ! $APPLY; then
    echo ""
    echo "Dry run only. Re-run with --apply to update the target skills mirror."
fi
