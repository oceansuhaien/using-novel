#!/usr/bin/env bash
# generate-manifests.sh
# 从 skills/*/SKILL.md 的 frontmatter 生成两份平台清单：
#   .codex-plugin/plugin.json（Codex）
#   .claude-plugin/plugin.json（Claude Code）
# 同时为 Claude Code 生成 .claude-plugin/commands/*.md 镜像。
#
# 用法：
#   bash scripts/generate-manifests.sh            # 生成
#   bash scripts/generate-manifests.sh --check    # 只检测漂移（CI 用）

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
CHECK=false
[[ "${1:-}" == "--check" ]] && CHECK=true

# ---- 读 SKILL.md frontmatter ----
read_fm() {
    local file="$1" key="$2"
    awk -v k="$key" '
        BEGIN{in_fm=0}
        NR==1 && /^---$/{in_fm=1;next}
        in_fm && /^---$/{exit}
        in_fm && $0 ~ "^"k":" {
            sub("^"k":\\s*",""); gsub(/^["'\'']|["'\'']$/,""); print; exit
        }
    ' "$file"
}

# ---- 收集 skills ----
SKILLS_JSON=""
for dir in "$ROOT"/skills/*/; do
    skill_file="${dir}SKILL.md"
    [[ -f "$skill_file" ]] || continue
    name=$(read_fm "$skill_file" "name")
    desc=$(read_fm "$skill_file" "description")
    [[ -z "$name" ]] && continue
    # 转义 JSON 特殊字符
    desc="${desc//\\/\\\\}"
    desc="${desc//\"/\\\"}"
    SKILLS_JSON="${SKILLS_JSON}    {\"name\": \"${name}\", \"description\": \"${desc}\"},
"
done
# 去掉最后一个逗号
SKILLS_JSON="${SKILLS_JSON%,
}
"

# ---- Codex 清单 ----
mkdir -p "$ROOT/.codex-plugin"
CODEX_OUT="$ROOT/.codex-plugin/plugin.json"

cat > "${CODEX_OUT}.new" <<CODEX_EOF
{
  "name": "novel-driver",
  "version": "0.4.0",
  "description": "面向中文网文创作流程的 Codex 插件（含草稿版本系统、角色驱动场景生成）。",
  "author": {
    "name": "Novel Driver 贡献者"
  },
  "license": "MIT",
  "keywords": ["novel","webnovel","outline","plot","character","canon","draft","workflow"],
  "skills": "./skills/",
  "interface": {
    "displayName": "Novel Driver",
    "shortDescription": "把中文网文任务分流到大纲、剧情、人物、草稿版本管理和场景生成技能",
    "longDescription": "可安装插件，提供 /using-novel 总入口、小说专项命令，以及中文网文大纲、剧情、人物、草稿版本系统和角色驱动场景生成所需的技能。",
    "developerName": "Novel Driver 贡献者",
    "category": "Writing",
    "capabilities": ["Interactive","Read","Write"],
    "defaultPrompt": [
      "使用 /using-novel 为这个故事任务选择合适技能",
      "使用 /novel-outline 把这个点子整理成大纲和主线骨架",
      "使用 /novel-plot 修复这条剧情弧线并加强钩子",
      "使用 /novel-character 根据我的故事笔记制作或优化人物卡"
    ],
    "brandColor": "#8C4A2F",
    "composerIcon": "./assets/novel-driver.svg",
    "logo": "./assets/novel-driver.svg",
    "screenshots": []
  }
}
CODEX_EOF

# ---- Claude Code 清单 ----
mkdir -p "$ROOT/.claude-plugin"
CLAUDE_OUT="$ROOT/.claude-plugin/plugin.json"

cat > "${CLAUDE_OUT}.new" <<CLAUDE_EOF
{
  "name": "novel-driver",
  "version": "0.4.0",
  "description": "面向中文网文创作流程的 Claude Code 插件（含草稿版本系统、角色驱动场景生成）。",
  "skills": [
${SKILLS_JSON}
  ],
  "commands_dir": "./commands/"
}
CLAUDE_EOF

# ---- Claude Code commands 镜像 ----
mkdir -p "$ROOT/.claude-plugin/commands"
for cmd_file in "$ROOT"/commands/*.md; do
    [[ -f "$cmd_file" ]] || continue
    cp "$cmd_file" "$ROOT/.claude-plugin/commands/$(basename "$cmd_file")"
done

# ---- Check 模式 ----
if $CHECK; then
    DRIFT=false
    for f in "$CODEX_OUT" "$CLAUDE_OUT"; do
        if [[ ! -f "$f" ]]; then
            echo "DRIFT: $f does not exist" >&2
            DRIFT=true
        elif ! diff -q "$f" "${f}.new" > /dev/null 2>&1; then
            echo "DRIFT: $f is out of sync" >&2
            DRIFT=true
        fi
    done
    rm -f "${CODEX_OUT}.new" "${CLAUDE_OUT}.new"
    if $DRIFT; then exit 1; fi
    echo "manifests in sync"
    exit 0
fi

# ---- 写回 ----
mv "${CODEX_OUT}.new" "$CODEX_OUT"
mv "${CLAUDE_OUT}.new" "$CLAUDE_OUT"
echo "updated .codex-plugin/plugin.json"
echo "updated .claude-plugin/plugin.json"
echo "mirrored commands/ -> .claude-plugin/commands/"
