#!/usr/bin/env bash
# state-rewrite.sh：对已 finalize 的场景触发状态回写流程（或补触发）。
#
# 脚本职责仅做流程控制和文件 I/O：
#   - 读 scene 工作台正文 + slice.yaml
#   - 输出 on_stage 角色列表（供上层 skill 逐一调 LLM 产 diff）
#   - 接受 /tmp/state-diff-<id>.md 作为 diff 源
#   - 应用 diff：旧 state.md 进 state.drafts/，新 state.md 覆盖工作台
#
# diff 的实际 LLM 生成由上层 skill 完成，不在本脚本。

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

usage() {
    cat >&2 <<EOF
Usage:
  state-rewrite.sh list <scene-asset>
      输出 scene 的 on_stage 角色列表（每行一个 id）

  state-rewrite.sh apply <scene-asset> <character-id>
      应用 /tmp/state-diff-<character-id>.md 为新的 state.md，
      旧 state.md 进 state.drafts/vNNN-manual.md

Exit codes: 见 scripts-usage.md
EOF
    exit 2
}

[[ $# -lt 2 ]] && usage

MODE="$1"; shift
SCENE="$1"; shift

assert_book_root

SLICE_FILE="drafts/${SCENE}.slice.yaml"
if [[ ! -f "$SLICE_FILE" ]]; then
    echo "ERROR: slice file not found: $SLICE_FILE" >&2
    exit 3
fi

extract_on_stage() {
    python3 - "$SLICE_FILE" <<'PY'
import sys, re
with open(sys.argv[1], "r", encoding="utf-8") as f:
    text = f.read()
m = re.search(r'on_stage:\s*\[([^\]]*)\]', text)
if not m:
    # 也支持列表风格
    m2 = re.search(r'on_stage:\s*\n((?:\s*-\s*\S+\s*\n)+)', text)
    if m2:
        for line in m2.group(1).splitlines():
            name = line.strip().lstrip("-").strip()
            if name:
                print(name)
    sys.exit(0)
for name in m.group(1).split(","):
    name = name.strip()
    if name:
        print(name)
PY
}

case "$MODE" in
    list)
        extract_on_stage
        ;;
    apply)
        [[ $# -ne 1 ]] && usage
        CHAR_ID="$1"
        DIFF_FILE="/tmp/state-diff-${CHAR_ID}.md"
        if [[ ! -f "$DIFF_FILE" ]]; then
            echo "ERROR: diff file not found: $DIFF_FILE" >&2
            echo "HINT: upper-level skill must write new state.md content there first" >&2
            exit 3
        fi
        STATE_ASSET="characters/${CHAR_ID}/state"
        # 用 draft-write.sh manual 模式，自然完成"旧进快照 + 新覆盖工作台 + 索引更新"
        "${HERE}/draft-write.sh" "$STATE_ASSET" "manual" "$DIFF_FILE" --note "state rewrite after ${SCENE}"
        ;;
    *)
        usage
        ;;
esac
