#!/usr/bin/env bash
# run-evals.sh - 列出手工评测用例并说明流程

set -euo pipefail

ROOT="$(cd "$(dirname "${BASH_SOURCE[0]}")/.." && pwd)"
EVAL_DIR="$ROOT/evals"

if [[ ! -d "$EVAL_DIR" ]]; then
    echo "ERROR: Missing evals directory: $EVAL_DIR" >&2
    exit 1
fi

files=("$EVAL_DIR"/*.md)
if [[ ${#files[@]} -eq 0 ]] || [[ ! -e "${files[0]}" ]]; then
    echo "ERROR: No eval case files found" >&2
    exit 1
fi

echo "Novel Driver eval files:"
for f in "${files[@]}"; do
    echo "- $(basename "$f")"
done

echo ""
echo "Manual eval workflow:"
echo "1. Run each user prompt through the relevant skill router."
echo "2. Check expected route, first move, evidence labeling, and writeback boundary."
echo "3. Record regressions in the eval file before changing skill behavior."
