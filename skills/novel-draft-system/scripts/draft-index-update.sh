#!/usr/bin/env bash
# draft-index-update.sh：重扫 drafts/ 全目录，重建 .draft-index.yaml。
# 用于迁移场景或索引漂移修复。

set -euo pipefail

HERE="$(cd "$(dirname "${BASH_SOURCE[0]}")" && pwd)"
# shellcheck source=./_common.sh
source "${HERE}/_common.sh"

CHECK=false
[[ "${1:-}" == "--check" ]] && CHECK=true

assert_book_root

BOOK_ID=$(basename "$(pwd)")
UPDATED_AT=$(iso_now)

python3 - "$DRAFT_DIR" "$BOOK_ID" "$UPDATED_AT" "$CHECK" "$INDEX_FILE" <<'PY'
import sys, os, re, pathlib, datetime

draft_dir, book_id, updated_at, check_str, index_file = sys.argv[1:6]
check_only = (check_str == "True" or check_str == "true")

root = pathlib.Path(draft_dir)
if not root.exists():
    print(f"book_id: {book_id}")
    print(f"updated_at: {updated_at}")
    print("assets: {}")
    print("stats:")
    print("  total_assets: 0")
    print("  forced_count: 0")
    print("  forced_ratio: 0.0")
    sys.exit(0)

def parse_header(p):
    """从快照文件头读 yaml 字段"""
    try:
        with open(p, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except Exception:
        return {}
    if not lines or lines[0].strip() != "---":
        return {}
    data = {}
    for line in lines[1:]:
        if line.strip() == "---":
            break
        m = re.match(r'^([A-Za-z_][A-Za-z0-9_]*):\s*(.*)$', line.strip())
        if m:
            v = m.group(2).strip()
            if v.startswith('"') and v.endswith('"'):
                v = v[1:-1]
            data[m.group(1)] = v
    return data

assets = {}

# 遍历所有 .drafts/ 目录
for drafts_path in root.rglob("*.drafts"):
    if not drafts_path.is_dir():
        continue
    rel = drafts_path.relative_to(root)
    # 去掉 .drafts 后缀得到 asset
    asset_str = str(rel).replace("\\", "/")
    asset = asset_str[:-len(".drafts")]

    # 找出最新版本
    max_ver = 0
    max_file = None
    for f in drafts_path.iterdir():
        m = re.match(r'^v(\d+)-([a-z-]+)\.(md|yaml)$', f.name)
        if not m:
            continue
        n = int(m.group(1))
        if n > max_ver:
            max_ver = n
            max_file = f

    if max_ver == 0:
        continue

    hdr = parse_header(max_file)
    kind = hdr.get("kind", "unknown")
    forced = hdr.get("forced", "false")

    # finalized 检测：有 v*-finalized.* 锚点
    finalized = False
    finalized_at = ""
    for f in drafts_path.iterdir():
        m = re.match(r'^v(\d+)-finalized\.(md|yaml)$', f.name)
        if m:
            finalized = True
            fh = parse_header(f)
            finalized_at = fh.get("timestamp", "")
            break

    assets[asset] = {
        "current_ver": max_ver,
        "last_kind": kind,
        "forced": forced,
        "finalized": "true" if finalized else "false",
        "finalized_at": finalized_at,
    }

total = len(assets)
forced_count = sum(1 for a in assets.values() if a["forced"] == "true")
ratio = round(forced_count / total, 4) if total > 0 else 0.0

# 生成文本
lines = []
lines.append(f"book_id: {book_id}")
lines.append(f"updated_at: {updated_at}")
if assets:
    lines.append("assets:")
    for name in sorted(assets.keys()):
        lines.append(f"  {name}:")
        for k in ["current_ver", "last_kind", "forced", "finalized", "finalized_at"]:
            if k in assets[name] and assets[name][k] != "":
                lines.append(f"    {k}: {assets[name][k]}")
else:
    lines.append("assets: {}")
lines.append("stats:")
lines.append(f"  total_assets: {total}")
lines.append(f"  forced_count: {forced_count}")
lines.append(f"  forced_ratio: {ratio}")
new_content = "\n".join(lines) + "\n"

if check_only:
    # 比较但忽略 updated_at（因为时间戳总是变）
    if os.path.exists(index_file):
        with open(index_file, "r", encoding="utf-8") as f:
            cur = f.read()
        cur_lines = [l for l in cur.splitlines() if not l.startswith("updated_at:")]
        new_lines = [l for l in new_content.splitlines() if not l.startswith("updated_at:")]
        if cur_lines == new_lines:
            sys.exit(0)
    sys.stderr.write("INDEX_DRIFT: .draft-index.yaml is out of sync; run draft-index-update.sh to fix\n")
    sys.exit(1)

with open(index_file, "w", encoding="utf-8") as f:
    f.write(new_content)
sys.stdout.write(f"OK: rebuilt {index_file} ({total} assets, forced_ratio={ratio})\n")
if ratio > 0.15:
    sys.stderr.write(f"WARN: forced ratio {ratio:.2%} exceeds 15% threshold\n")
PY
