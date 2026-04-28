#!/usr/bin/env bash
# draft-rollback.sh：回滚工作台到某个历史版本。后续版本不删除。

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

usage() {
    echo "Usage: draft-rollback.sh <asset> <ver>" >&2
    exit 2
}

[[ $# -ne 2 ]] && usage

ASSET="$1"
VER="$2"

[[ "$VER" =~ ^[0-9]+$ ]] || { echo "ERROR: ver must be integer" >&2; exit 2; }

assert_book_root
eval "$(asset_paths "$ASSET")"

VER_PAD=$(pad_ver "$VER")

SNAPSHOT=""
for f in "$ASSET_DRAFTS_DIR"/${VER_PAD}-*.*; do
    [[ -e "$f" ]] || continue
    SNAPSHOT="$f"
    break
done

if [[ -z "$SNAPSHOT" ]]; then
    echo "ERROR: snapshot ${VER_PAD}-*.* not found" >&2
    exit 3
fi

CUR_MAX=$(latest_ver "$ASSET_DRAFTS_DIR")

mkdir -p "$(dirname "$ASSET_FILE")"
cp "$SNAPSHOT" "$ASSET_FILE"

# 读快照 kind（仅用于回报）
LAST_KIND="rollback-to-v${VER}"

# 索引 current_ver 保持 = max（历史保留，下次新写从 max+1）
# 重扫确保 finalized 等字段根据文件系统真相更新
reindex

echo "OK: rolled back ${ASSET} workbench to v${VER}"
echo "HINT: v$((VER+1))..v${CUR_MAX} preserved. Next write will be v$((CUR_MAX+1))."
