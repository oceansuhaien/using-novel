#!/usr/bin/env bash
# novel-draft-system 共享函数库。被其他脚本 source。
# 不直接执行。

set -euo pipefail

# ---- 全局约定 ----

DRAFT_DIR="drafts"
INDEX_FILE=".draft-index.yaml"

# ISO 8601 UTC 时间戳
iso_now() {
    date -u +"%Y-%m-%dT%H:%M:%SZ"
}

# ---- 书籍根检测 ----
# 当前工作目录必须是书籍根：summary.md 存在，outline/ plot/ characters/ 三目录都存在。
assert_book_root() {
    if [[ ! -f "summary.md" ]] || [[ ! -d "outline" ]] || [[ ! -d "plot" ]] || [[ ! -d "characters" ]]; then
        echo "ERROR: current directory is not a valid book root (missing summary.md or outline/plot/characters/)" >&2
        exit 2
    fi
    # 首次运行时自动建立 drafts/ 和索引
    mkdir -p "${DRAFT_DIR}"
    if [[ ! -f "${INDEX_FILE}" ]]; then
        cat > "${INDEX_FILE}" <<EOF
book_id: $(basename "$(pwd)")
updated_at: $(iso_now)
assets: {}
stats:
  total_assets: 0
  forced_count: 0
  forced_ratio: 0.0
EOF
    fi
}

# ---- asset 路径解析 ----
# 输入：asset（如 chapters/ch007 或 characters/lin_wan/state）
# 输出：工作台路径 / 版本链目录 / asset 类别
# 使用：eval "$(asset_paths "chapters/ch007")"
# 产生变量：ASSET_FILE、ASSET_DRAFTS_DIR、ASSET_FINAL、ASSET_CATEGORY、IS_SCENE、IS_STATE、IS_SLICE
asset_paths() {
    local asset="$1"
    local category="${asset%%/*}"
    local is_scene=false
    local is_state=false
    local is_slice=false
    local ext="md"

    # 特判 state 资产（复合路径 characters/<id>/state）
    if [[ "$asset" =~ ^characters/.+/state$ ]]; then
        is_state=true
    elif [[ "$category" == "chapters" ]]; then
        is_scene=true
    fi

    # 特判 slice 资产（chapters/<scene>.slice，扩展名 yaml）
    if [[ "$asset" =~ \.slice$ ]]; then
        is_slice=true
        ext="yaml"
    fi

    echo "ASSET_FILE='${DRAFT_DIR}/${asset}.${ext}'"
    echo "ASSET_DRAFTS_DIR='${DRAFT_DIR}/${asset}.drafts'"
    # state 资产无定稿层
    if [[ "$is_state" == "true" ]] || [[ "$is_slice" == "true" ]]; then
        echo "ASSET_FINAL=''"
    else
        echo "ASSET_FINAL='${asset}.${ext}'"
    fi
    echo "ASSET_CATEGORY='${category}'"
    echo "IS_SCENE=${is_scene}"
    echo "IS_STATE=${is_state}"
    echo "IS_SLICE=${is_slice}"
    echo "ASSET_EXT='${ext}'"
}

# ---- 版本号探测 ----
# 扫描版本链目录，返回当前最大 vNNN（无快照时返回 0）。
latest_ver() {
    local drafts_dir="$1"
    if [[ ! -d "$drafts_dir" ]]; then
        echo 0
        return
    fi
    local max=0
    for f in "$drafts_dir"/v*-*.md "$drafts_dir"/v*-*.yaml; do
        [[ -e "$f" ]] || continue
        local base
        base="$(basename "$f")"
        # v007-rewrite.md / v001-slice.yaml
        if [[ "$base" =~ ^v([0-9]+)- ]]; then
            local n=$((10#${BASH_REMATCH[1]}))
            (( n > max )) && max=$n
        fi
    done
    echo "$max"
}

# 格式化版本号：3 位零填充
pad_ver() {
    printf "v%03d" "$1"
}

# ---- yaml 头注入 ----
# 读源文件，确保头部有 yaml 头；若源文件已有头则替换，否则前置插入。
# 参数：<src-file> <dst-file> <ver> <kind> <from-ver|null> <forced:true|false> [note] [slice_ref] [forced_directive] [source]
write_with_header() {
    local src="$1"
    local dst="$2"
    local ver="$3"
    local kind="$4"
    local from_ver="$5"
    local forced="$6"
    local note="${7:-}"
    local slice_ref="${8:-}"
    local forced_directive="${9:-}"
    local source_tag="${10:-}"

    local tmp
    tmp="$(mktemp)"
    {
        echo "---"
        echo "ver: ${ver}"
        echo "kind: ${kind}"
        if [[ "$from_ver" != "null" ]] && [[ -n "$from_ver" ]]; then
            echo "from_ver: ${from_ver}"
        fi
        echo "timestamp: $(iso_now)"
        echo "forced: ${forced}"
        [[ -n "$slice_ref" ]] && echo "slice_ref: ${slice_ref}"
        [[ -n "$source_tag" ]] && echo "source: ${source_tag}"
        [[ -n "$note" ]] && echo "author_note: \"${note//\"/\\\"}\""
        [[ -n "$forced_directive" ]] && echo "forced_directive: \"${forced_directive//\"/\\\"}\""
        echo "---"
        echo
        # 跳过源文件自身的 yaml 头（如果有）
        awk '
            BEGIN { in_fm = 0; past_fm = 0 }
            NR==1 && /^---$/ { in_fm = 1; next }
            in_fm && /^---$/ { in_fm = 0; past_fm = 1; next }
            in_fm { next }
            { print }
        ' "$src"
    } > "$tmp"
    mv "$tmp" "$dst"
}

# ---- 索引读写 ----
# 所有写入后用全量重扫保证索引 = 文件系统真相。
# 避免 rollback/write 后字段遗漏或覆盖。

reindex() {
    assert_book_root
    local here
    here="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
    "${here}/draft-index-update.sh" >/dev/null
}
