#!/usr/bin/env bash
# generate-readme.sh
# 从 commands/*.md 和 skills/*/SKILL.md 的 frontmatter 自动重新生成
# README.md 中 <!-- BEGIN:COMMANDS --> 和 <!-- BEGIN:SKILLS --> 区块。
#
# 用法：
#   bash scripts/generate-readme.sh            # 重新生成
#   bash scripts/generate-readme.sh --check    # 只检测漂移

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK=false
[[ "${1:-}" == "--check" ]] && CHECK=true

python3 - "$ROOT" "$CHECK" <<'PY'
import sys, os, re, glob

root = sys.argv[1]
check_only = sys.argv[2] == "True" or sys.argv[2] == "true"

readme_path = os.path.join(root, "README.md")
if not os.path.exists(readme_path):
    print("ERROR: README.md not found", file=sys.stderr)
    sys.exit(1)

def read_fm(filepath, key):
    """Read a single key from yaml frontmatter."""
    try:
        with open(filepath, "r", encoding="utf-8") as f:
            lines = f.readlines()
    except Exception:
        return ""
    if not lines or lines[0].strip() != "---":
        return ""
    for line in lines[1:]:
        if line.strip() == "---":
            break
        if line.startswith(f"{key}:"):
            val = line[len(key)+1:].strip()
            if len(val) >= 2 and val[0] in ('"', "'") and val[-1] == val[0]:
                val = val[1:-1]
            return val
    return ""

def escape_cell(text):
    return text.replace("|", "\\|").replace("\n", " ").strip()

# Build commands table
cmd_rows = ["| 命令 | 说明 |", "| --- | --- |"]
cmd_dir = os.path.join(root, "commands")
if os.path.isdir(cmd_dir):
    for f in sorted(glob.glob(os.path.join(cmd_dir, "*.md"))):
        name = os.path.splitext(os.path.basename(f))[0]
        desc = escape_cell(read_fm(f, "description"))
        cmd_rows.append(f"| `/{name}` | {desc} |")
cmd_table = "\n".join(cmd_rows)

# Build skills table (exclude using-novel)
skill_rows = ["| 技能 | 说明 |", "| --- | --- |"]
skills_dir = os.path.join(root, "skills")
if os.path.isdir(skills_dir):
    for d in sorted(os.listdir(skills_dir)):
        sf = os.path.join(skills_dir, d, "SKILL.md")
        if not os.path.isfile(sf):
            continue
        name = read_fm(sf, "name")
        if name == "using-novel" or not name:
            continue
        desc = escape_cell(read_fm(sf, "description"))
        skill_rows.append(f"| `{name}` | {desc} |")
skill_table = "\n".join(skill_rows)

# Read current README
with open(readme_path, "r", encoding="utf-8") as f:
    content = f.read()

def replace_block(content, begin, end, body):
    pattern = re.compile(
        r"(" + re.escape(begin) + r")\s*.*?\s*(" + re.escape(end) + r")",
        re.DOTALL
    )
    if not pattern.search(content):
        raise ValueError(f"Markers not found: {begin} ... {end}")
    return pattern.sub(rf"\1\n{body}\n\2", content, count=1)

updated = replace_block(content, "<!-- BEGIN:COMMANDS -->", "<!-- END:COMMANDS -->", cmd_table)
updated = replace_block(updated, "<!-- BEGIN:SKILLS -->", "<!-- END:SKILLS -->", skill_table)

if check_only:
    if content == updated:
        print("README.md in sync")
        sys.exit(0)
    else:
        print("README.md is out of sync with commands/ and/or skills/", file=sys.stderr)
        sys.exit(1)

if content == updated:
    print("README.md already up to date")
    sys.exit(0)

with open(readme_path, "w", encoding="utf-8", newline="\n") as f:
    f.write(updated)
print("updated README.md")
PY
