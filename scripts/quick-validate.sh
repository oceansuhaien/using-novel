#!/usr/bin/env bash
# quick-validate.sh
# 校验 novel-driver 插件结构。bash 版，替代原 quick-validate.ps1。
#
# 检查项：
#   - .codex-plugin/plugin.json 存在且基本字段正确
#   - 每个 skill 有 SKILL.md 且 frontmatter 含 name + description
#   - SKILL.md ≤100 行，references/ 下每个文件 ≤150 行
#   - commands/*.md 含 novel-driver: 引用
#   - 无 .ps1 残留（阶段 D 后生效；阶段 A 只 warn）
#   - README.md 与 skills/commands 同步（调用 generate-readme.sh --check）
#   - 两份平台清单无漂移（调用 generate-manifests.sh --check）
#   - assets/novel-driver.svg 存在

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
ERRORS=0

err() {
    echo "ERROR: $1" >&2
    ERRORS=$((ERRORS + 1))
}

warn() {
    echo "WARN: $1" >&2
}

# ---- plugin.json ----
PJ="$ROOT/.codex-plugin/plugin.json"
if [[ ! -f "$PJ" ]]; then
    err "Missing .codex-plugin/plugin.json"
else
    grep -q '"novel-driver"' "$PJ" || err "plugin.json name must be novel-driver"
    grep -q '"skills"' "$PJ" || err "plugin.json missing skills path"
    grep -q 'novel-driver.svg' "$PJ" || err "plugin.json must reference novel-driver.svg"
    grep -q 'example\.com' "$PJ" && err "plugin.json still contains example.com placeholder"
fi

# ---- asset ----
[[ -f "$ROOT/assets/novel-driver.svg" ]] || err "Missing assets/novel-driver.svg"

# ---- skills ----
if [[ ! -d "$ROOT/skills" ]]; then
    err "Missing skills/ directory"
else
    for dir in "$ROOT"/skills/*/; do
        skill_name=$(basename "$dir")
        sf="${dir}SKILL.md"
        if [[ ! -f "$sf" ]]; then
            err "Missing SKILL.md in ${skill_name}"
            continue
        fi
        # frontmatter check
        head -5 "$sf" | grep -q '^name:' || err "Missing 'name' in frontmatter of ${skill_name}"
        head -10 "$sf" | grep -q '^description:' || err "Missing 'description' in frontmatter of ${skill_name}"

        # line count
        lines=$(wc -l < "$sf")
        if (( lines > 100 )); then
            err "${skill_name}/SKILL.md has ${lines} lines (max 100)"
        fi

        # references line count
        if [[ -d "${dir}references" ]]; then
            for ref in "${dir}references"/*.md; do
                [[ -f "$ref" ]] || continue
                rlines=$(wc -l < "$ref")
                rname=$(basename "$ref")
                if (( rlines > 150 )); then
                    err "${skill_name}/references/${rname} has ${rlines} lines (max 150)"
                fi
            done
        fi

        # agents/openai.yaml（novel-system-reference 和 novel-draft-system 可豁免）
        if [[ "$skill_name" != "novel-system-reference" ]] && [[ "$skill_name" != "novel-draft-system" ]]; then
            [[ -f "${dir}agents/openai.yaml" ]] || err "Missing agents/openai.yaml in ${skill_name}"
        fi
    done
fi

# ---- commands ----
if [[ -d "$ROOT/commands" ]]; then
    for cmd in "$ROOT"/commands/*.md; do
        [[ -f "$cmd" ]] || continue
        grep -q 'novel-driver:' "$cmd" || err "$(basename "$cmd") does not dispatch to a novel-driver skill"
    done
fi

# ---- .ps1 残留 ----
PS1_COUNT=$(find "$ROOT" -name '*.ps1' -not -path '*/.git/*' | wc -l)
if (( PS1_COUNT > 0 )); then
    # 阶段 D 前是 warn，阶段 D 后改成 err
    warn "${PS1_COUNT} .ps1 file(s) remaining (will be error after phase-d-cleanup)"
fi

# ---- README 同步 ----
if [[ -f "$ROOT/scripts/generate-readme.sh" ]]; then
    if ! bash "$ROOT/scripts/generate-readme.sh" --check 2>/dev/null; then
        err "README.md out of sync. Run: bash scripts/generate-readme.sh"
    fi
fi

# ---- manifests 漂移 ----
if [[ -f "$ROOT/scripts/generate-manifests.sh" ]]; then
    if ! bash "$ROOT/scripts/generate-manifests.sh" --check 2>/dev/null; then
        err "Platform manifests out of sync. Run: bash scripts/generate-manifests.sh"
    fi
fi

# ---- 汇总 ----
if (( ERRORS > 0 )); then
    echo "validation FAILED with ${ERRORS} error(s)" >&2
    exit 1
fi

echo "novel-driver validation passed"
