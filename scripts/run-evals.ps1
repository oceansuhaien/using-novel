param(
    [string]$PluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$evalRoot = Join-Path $PluginRoot "evals"

if (-not (Test-Path $evalRoot)) {
    Write-Error "Missing evals directory"
    exit 1
}

$files = Get-ChildItem -LiteralPath $evalRoot -Filter "*.md"
if ($files.Count -eq 0) {
    Write-Error "No eval case files found"
    exit 1
}

Write-Host "Novel skill eval files:"
$files | ForEach-Object { Write-Host "- $($_.Name)" }

Write-Host ""
Write-Host "Manual eval workflow:"
Write-Host "1. Run each user prompt through the relevant skill router."
Write-Host "2. Check expected route, first move, evidence labeling, and writeback boundary."
Write-Host "3. Record regressions in the eval file before changing skill behavior."
