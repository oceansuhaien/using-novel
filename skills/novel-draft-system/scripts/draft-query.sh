#!/usr/bin/env bash
# draft-query.sh：按三层查询顺序定位一个 asset。
# 输出：
#   第一行：LAYER: drafts | snapshot | finalized | miss
#   第二行及以后：命中文件内容（miss 时为空）

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

usage() {
    echo "Usage: draft-query.sh <asset>" >&2
    exit 2
}

[[ $# -ne 1 ]] && usage

ASSET="$1"
assert_book_root
eval "$(asset_paths "$ASSET")"

# ① 工作台
if [[ -f "$ASSET_FILE" ]]; then
    echo "LAYER: drafts"
    cat "$ASSET_FILE"
    exit 0
fi

# ② 版本链最大 vNNN
CUR_MAX=$(latest_ver "$ASSET_DRAFTS_DIR")
if (( CUR_MAX > 0 )); then
    VER_PAD=$(pad_ver "$CUR_MAX")
    for f in "$ASSET_DRAFTS_DIR"/${VER_PAD}-*.*; do
        [[ -e "$f" ]] || continue
        echo "LAYER: snapshot"
        cat "$f"
        exit 0
    done
fi

# ③ 定稿层
if [[ -n "$ASSET_FINAL" ]] && [[ -f "$ASSET_FINAL" ]]; then
    echo "LAYER: finalized"
    cat "$ASSET_FINAL"
    exit 0
fi

# 全 miss
echo "LAYER: miss"
exit 0
