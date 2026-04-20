param(
    [string]$PluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [string]$TargetRoot = (Resolve-Path (Join-Path $PluginRoot "..\..\.codex\skills")).Path,
    [switch]$Apply
)

$ErrorActionPreference = "Stop"
$sourceRoot = Join-Path $PluginRoot "skills"

if (-not (Test-Path $sourceRoot)) {
    Write-Error "Missing source skills directory: $sourceRoot"
    exit 1
}

if (-not (Test-Path $TargetRoot)) {
    if ($Apply) {
        New-Item -ItemType Directory -Force -Path $TargetRoot | Out-Null
    } else {
        Write-Host "Would create target directory: $TargetRoot"
    }
}

foreach ($skill in Get-ChildItem -LiteralPath $sourceRoot -Directory) {
    $target = Join-Path $TargetRoot $skill.Name
    $targetFull = [System.IO.Path]::GetFullPath($target)
    $targetRootFull = [System.IO.Path]::GetFullPath($TargetRoot)
    if (-not $targetFull.StartsWith($targetRootFull, [System.StringComparison]::OrdinalIgnoreCase)) {
        Write-Error "Refusing to sync outside target root: $targetFull"
        exit 1
    }
    if (-not $Apply) {
        Write-Host "Would sync $($skill.FullName) -> $targetFull"
        continue
    }

    if (-not (Test-Path $targetFull)) {
        New-Item -ItemType Directory -Force -Path $targetFull | Out-Null
    }

    foreach ($item in Get-ChildItem -LiteralPath $skill.FullName -Force) {
        $destination = Join-Path $targetFull $item.Name
        if ($item.PSIsContainer) {
            if (Test-Path $destination) {
                Remove-Item -LiteralPath $destination -Recurse -Force -ErrorAction SilentlyContinue
            }
            New-Item -ItemType Directory -Force -Path $destination | Out-Null
            foreach ($child in Get-ChildItem -LiteralPath $item.FullName -Force) {
                Copy-Item -LiteralPath $child.FullName -Destination (Join-Path $destination $child.Name) -Recurse -Force
            }
        } else {
            Copy-Item -LiteralPath $item.FullName -Destination $destination -Force
        }
    }

    Write-Host "Synced $($skill.Name)"
}

if (-not $Apply) {
    Write-Host "Dry run only. Re-run with -Apply to update .codex/skills mirrors."
}
