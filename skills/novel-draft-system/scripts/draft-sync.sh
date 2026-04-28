#!/usr/bin/env bash
# draft-sync.sh：把某个版本链快照同步为工作台。
# 用于 rewrite 作者确认后，或手工把某版推回工作台。

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

usage() {
    echo "Usage: draft-sync.sh <asset> <ver>" >&2
    exit 2
}

[[ $# -ne 2 ]] && usage

ASSET="$1"
VER="$2"

[[ "$VER" =~ ^[0-9]+$ ]] || { echo "ERROR: ver must be integer" >&2; exit 2; }

assert_book_root
eval "$(asset_paths "$ASSET")"

VER_PAD=$(pad_ver "$VER")

# 找到对应快照
SNAPSHOT=""
for f in "$ASSET_DRAFTS_DIR"/${VER_PAD}-*.*; do
    [[ -e "$f" ]] || continue
    SNAPSHOT="$f"
    break
done

if [[ -z "$SNAPSHOT" ]]; then
    echo "ERROR: snapshot ${VER_PAD}-*.* not found in ${ASSET_DRAFTS_DIR}" >&2
    exit 3
fi

mkdir -p "$(dirname "$ASSET_FILE")"
cp "$SNAPSHOT" "$ASSET_FILE"
echo "OK: synced workbench ${ASSET_FILE} from ${SNAPSHOT}"
