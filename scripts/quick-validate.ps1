param(
    [string]$PluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path
)

$ErrorActionPreference = "Stop"
$errors = New-Object System.Collections.Generic.List[string]

function Add-Error([string]$Message) {
    $errors.Add($Message) | Out-Null
}

$pluginJson = Join-Path $PluginRoot ".codex-plugin\plugin.json"
if (-not (Test-Path $pluginJson)) {
    Add-Error "Missing .codex-plugin/plugin.json"
} else {
    $raw = Get-Content -Raw -LiteralPath $pluginJson
    try {
        $plugin = $raw | ConvertFrom-Json
        if (-not $plugin.name) { Add-Error "plugin.json missing name" }
        if (-not $plugin.skills) { Add-Error "plugin.json missing skills path" }
        if ($raw -match "example[.]com") { Add-Error "plugin.json still contains example.com placeholder" }
    } catch {
        Add-Error "plugin.json is not valid JSON: $($_.Exception.Message)"
    }
}

$skillsRoot = Join-Path $PluginRoot "skills"
if (-not (Test-Path $skillsRoot)) {
    Add-Error "Missing skills directory"
} else {
    $skillDirs = Get-ChildItem -LiteralPath $skillsRoot -Directory
    foreach ($dir in $skillDirs) {
        $skillFile = Join-Path $dir.FullName "SKILL.md"
        if (-not (Test-Path $skillFile)) {
            Add-Error "Missing SKILL.md in $($dir.Name)"
            continue
        }
        $text = Get-Content -Raw -LiteralPath $skillFile
        if ($text -notmatch "(?s)^---\s*\nname:\s*.+?\ndescription:\s*.+?\n---") {
            Add-Error "Invalid or missing frontmatter in $($dir.Name)"
        }
        if ($dir.Name -ne "novel-system-reference") {
            $openai = Join-Path $dir.FullName "agents\openai.yaml"
            if (-not (Test-Path $openai)) {
                Add-Error "Missing agents/openai.yaml in user-facing skill $($dir.Name)"
            }
        }
    }
}

$commandsRoot = Join-Path $PluginRoot "commands"
if (Test-Path $commandsRoot) {
    foreach ($command in Get-ChildItem -LiteralPath $commandsRoot -Filter "*.md") {
        $text = Get-Content -Raw -LiteralPath $command.FullName
        if ($text -notmatch 'Invoke the `novel-skills:') {
            Add-Error "Command $($command.Name) does not dispatch to a novel-skills skill"
        }
    }
}

if ($errors.Count -gt 0) {
    $errors | ForEach-Object { Write-Error $_ }
    exit 1
}

Write-Host "novel-skills validation passed"
