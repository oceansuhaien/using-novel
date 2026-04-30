#!/usr/bin/env bash
# draft-write.sh：写一版草稿到版本链，并同步覆盖工作台（rewrite 除外）。
# 详见 skills/novel-draft-system/references/scripts-usage.md。

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

usage() {
    cat >&2 <<EOF
Usage: draft-write.sh <asset> <kind> <content-file> [--from-ver N] [--forced] [--note "..."] [--slice-ref "..."] [--forced-directive "..."] [--source TAG]

  <asset>         e.g. chapters/ch007  或  characters/lin_wan/state
  <kind>          draft|polish|expand|rewrite|manual|forced|slice
  <content-file>  路径，正文源文件（UTF-8），脚本会在其前插入 yaml 头
  --source TAG    可选标签。manual kind 常用值：imported（作者外部导入）、
                  state-archive（状态回写归档）；其他 kind 一般留空。

Exit codes:
  0 成功
  1 通用错误
  2 环境/参数错误
  3 asset 状态不一致
EOF
    exit 2
}

[[ $# -lt 3 ]] && usage

ASSET="$1"; shift
KIND="$1"; shift
CONTENT_FILE="$1"; shift

FROM_VER=""
FORCED="false"
NOTE=""
SLICE_REF=""
FORCED_DIRECTIVE=""
SOURCE_TAG=""

while [[ $# -gt 0 ]]; do
    case "$1" in
        --from-ver) FROM_VER="$2"; shift 2 ;;
        --forced) FORCED="true"; shift ;;
        --note) NOTE="$2"; shift 2 ;;
        --slice-ref) SLICE_REF="$2"; shift 2 ;;
        --forced-directive) FORCED_DIRECTIVE="$2"; shift 2 ;;
        --source) SOURCE_TAG="$2"; shift 2 ;;
        *) echo "ERROR: unknown arg $1" >&2; usage ;;
    esac
done

case "$KIND" in
    draft|polish|expand|rewrite|manual|forced|slice) ;;
    *) echo "ERROR: invalid kind '$KIND'" >&2; exit 2 ;;
esac

if [[ ! -f "$CONTENT_FILE" ]]; then
    echo "ERROR: content file not found: $CONTENT_FILE" >&2
    exit 2
fi

assert_book_root
eval "$(asset_paths "$ASSET")"

mkdir -p "$(dirname "$ASSET_FILE")"
mkdir -p "$ASSET_DRAFTS_DIR"

# forced=true 时，source 文件末尾必须包含"合理性偏离说明"
if [[ "$FORCED" == "true" ]]; then
    if ! grep -q "^## 合理性偏离说明" "$CONTENT_FILE"; then
        echo "ERROR: forced=true content must include '## 合理性偏离说明' section at the end" >&2
        exit 3
    fi
fi

# slice 资产的 kind 必须是 slice
if [[ "$IS_SLICE" == "true" ]] && [[ "$KIND" != "slice" ]]; then
    echo "ERROR: slice asset must use kind=slice" >&2
    exit 3
fi

# 计算新版本号
CUR_MAX=$(latest_ver "$ASSET_DRAFTS_DIR")
NEW_VER=$((CUR_MAX + 1))
[[ -z "$FROM_VER" ]] && FROM_VER="$CUR_MAX"
[[ "$FROM_VER" == "0" ]] && FROM_VER="null"

VER_PAD=$(pad_ver "$NEW_VER")
# 版本链文件扩展名：slice 资产走 yaml；其他走 md
if [[ "$IS_SLICE" == "true" ]]; then
    SNAPSHOT_FILE="${ASSET_DRAFTS_DIR}/${VER_PAD}-${KIND}.yaml"
else
    SNAPSHOT_FILE="${ASSET_DRAFTS_DIR}/${VER_PAD}-${KIND}.md"
fi

# 写版本链
write_with_header "$CONTENT_FILE" "$SNAPSHOT_FILE" "$NEW_VER" "$KIND" "$FROM_VER" "$FORCED" "$NOTE" "$SLICE_REF" "$FORCED_DIRECTIVE" "$SOURCE_TAG"

# 覆盖工作台（rewrite 例外 —— 不覆盖，提示作者对比后手动 sync）
if [[ "$KIND" == "rewrite" ]]; then
    echo "OK: wrote ${SNAPSHOT_FILE}"
    echo "HINT: rewrite produced snapshot only. Workbench not updated."
    echo "HINT: run draft-sync.sh '${ASSET}' ${NEW_VER} after author approves."
else
    cp "$SNAPSHOT_FILE" "$ASSET_FILE"
    echo "OK: wrote ${SNAPSHOT_FILE}"
    echo "OK: synced workbench ${ASSET_FILE}"
fi

# 更新索引（全量重扫保证索引 = 文件系统真相）
reindex
