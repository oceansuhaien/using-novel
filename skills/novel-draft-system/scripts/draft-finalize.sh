#!/usr/bin/env bash
# draft-finalize.sh：finalize 一个资产（工作台 → 定稿层 + 补锚 + 索引更新）。
# 若 asset 属于 chapters/，打印 STATE_REWRITE_REQUIRED 让上层 skill 接手。

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

usage() {
    echo "Usage: draft-finalize.sh <asset> [--note \"...\"]" >&2
    exit 2
}

[[ $# -lt 1 ]] && usage

ASSET="$1"; shift
NOTE=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --note) NOTE="$2"; shift 2 ;;
        *) echo "ERROR: unknown arg $1" >&2; usage ;;
    esac
done

assert_book_root
eval "$(asset_paths "$ASSET")"

# state 和 slice 资产无定稿层，不能 finalize
if [[ "$IS_STATE" == "true" ]]; then
    echo "ERROR: state assets cannot be finalized (they are drafts-only by design)" >&2
    exit 3
fi
if [[ "$IS_SLICE" == "true" ]]; then
    echo "ERROR: slice assets cannot be finalized (they freeze with their scene)" >&2
    exit 3
fi

# 工作台必须存在
if [[ ! -f "$ASSET_FILE" ]]; then
    echo "ERROR: workbench file not found: $ASSET_FILE" >&2
    exit 3
fi

CUR_VER=$(latest_ver "$ASSET_DRAFTS_DIR")
(( CUR_VER == 0 )) && { echo "ERROR: no snapshots in ${ASSET_DRAFTS_DIR}" >&2; exit 3; }

# 1. 复制工作台到定稿层
mkdir -p "$(dirname "$ASSET_FINAL")"
cp "$ASSET_FILE" "$ASSET_FINAL"

# 2. 版本链补 finalized 锚点
VER_PAD=$(pad_ver "$CUR_VER")
FINAL_SNAPSHOT="${ASSET_DRAFTS_DIR}/${VER_PAD}-finalized.md"
write_with_header "$ASSET_FILE" "$FINAL_SNAPSHOT" "$CUR_VER" "finalized" "$CUR_VER" "false" "$NOTE" "" ""

# 3. 读工作台 yaml 头里的 forced 字段（确定本次 finalize 是否基于 forced 版本）
FORCED_FLAG=$(awk '/^forced:/ {print $2; exit}' "$ASSET_FILE" 2>/dev/null || echo "false")
[[ -z "$FORCED_FLAG" ]] && FORCED_FLAG="false"

# 4. 更新索引（重扫）
reindex

echo "OK: finalized ${ASSET} at v${CUR_VER}"
echo "OK: wrote ${ASSET_FINAL}"
echo "OK: anchor ${FINAL_SNAPSHOT}"

# 5. 场景类资产 → 触发状态回写信号
if [[ "$IS_SCENE" == "true" ]]; then
    if [[ "$FORCED_FLAG" == "true" ]]; then
        echo "SKIP_STATE_REWRITE: forced=true, run state-rewrite.sh manually if needed"
    else
        echo "STATE_REWRITE_REQUIRED: ${ASSET}"
    fi
fi
