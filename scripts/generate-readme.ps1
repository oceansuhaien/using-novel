param(
    [string]$PluginRoot = (Resolve-Path (Join-Path $PSScriptRoot "..")).Path,
    [switch]$Check
)

$ErrorActionPreference = "Stop"

function Read-Frontmatter {
    param([string]$Path)

    $raw = Get-Content -Raw -Encoding UTF8 -LiteralPath $Path
    if ($raw -notmatch "(?s)^---\s*\r?\n(.*?)\r?\n---") {
        return $null
    }
    $block = $Matches[1]

    $result = @{}
    foreach ($line in ($block -split "\r?\n")) {
        if ($line -match '^\s*([A-Za-z0-9_-]+)\s*:\s*(.*)$') {
            $key = $Matches[1]
            $value = $Matches[2].Trim()
            if ($value.StartsWith('"') -and $value.EndsWith('"') -and $value.Length -ge 2) {
                $value = $value.Substring(1, $value.Length - 2)
            } elseif ($value.StartsWith("'") -and $value.EndsWith("'") -and $value.Length -ge 2) {
                $value = $value.Substring(1, $value.Length - 2)
            }
            $result[$key] = $value
        }
    }
    return $result
}

function Format-Cell {
    param([string]$Text)
    if ($null -eq $Text) { return "" }
    $t = $Text -replace "`r?`n", " "
    $t = $t -replace "\|", "\|"
    return $t.Trim()
}

function Build-CommandsTable {
    param([string]$CommandsDir)

    $rows = New-Object System.Collections.Generic.List[string]
    $rows.Add("| 命令 | 说明 |")
    $rows.Add("| --- | --- |")

    if (-not (Test-Path $CommandsDir)) {
        return ($rows -join "`n")
    }

    $files = Get-ChildItem -LiteralPath $CommandsDir -Filter "*.md" |
        Sort-Object -Property Name

    foreach ($file in $files) {
        $fm = Read-Frontmatter -Path $file.FullName
        if (-not $fm) { continue }
        $name = [System.IO.Path]::GetFileNameWithoutExtension($file.Name)
        $desc = Format-Cell ($fm["description"])
        $rows.Add("| ``/$name`` | $desc |")
    }

    return ($rows -join "`n")
}

function Build-SkillsTable {
    param([string]$SkillsDir, [string[]]$Exclude)

    $rows = New-Object System.Collections.Generic.List[string]
    $rows.Add("| 技能 | 说明 |")
    $rows.Add("| --- | --- |")

    if (-not (Test-Path $SkillsDir)) {
        return ($rows -join "`n")
    }

    $entries = @()
    foreach ($dir in (Get-ChildItem -LiteralPath $SkillsDir -Directory)) {
        $skillFile = Join-Path $dir.FullName "SKILL.md"
        if (-not (Test-Path $skillFile)) { continue }
        $fm = Read-Frontmatter -Path $skillFile
        if (-not $fm) { continue }
        $skillName = if ($fm.ContainsKey("name")) { $fm["name"] } else { $dir.Name }
        if ($Exclude -contains $skillName) { continue }
        $entries += [pscustomobject]@{
            Name = $skillName
            Description = Format-Cell ($fm["description"])
        }
    }

    foreach ($e in ($entries | Sort-Object -Property Name)) {
        $rows.Add("| ``$($e.Name)`` | $($e.Description) |")
    }

    return ($rows -join "`n")
}

function Replace-Block {
    param(
        [string]$Content,
        [string]$BeginMarker,
        [string]$EndMarker,
        [string]$NewBody
    )

    $beginEsc = [regex]::Escape($BeginMarker)
    $endEsc = [regex]::Escape($EndMarker)
    $pattern = "(?s)($beginEsc)\s*.*?\s*($endEsc)"

    $regex = New-Object System.Text.RegularExpressions.Regex($pattern)
    if (-not $regex.IsMatch($Content)) {
        throw "Marker block not found: $BeginMarker ... $EndMarker"
    }

    $replacement = "`$1`n$NewBody`n`$2"
    return $regex.Replace($Content, $replacement, 1)
}

$readmePath = Join-Path $PluginRoot "README.md"
if (-not (Test-Path $readmePath)) {
    Write-Error "README.md not found at $readmePath"
    exit 1
}

$commandsTable = Build-CommandsTable -CommandsDir (Join-Path $PluginRoot "commands")
$skillsTable = Build-SkillsTable -SkillsDir (Join-Path $PluginRoot "skills") -Exclude @("using-novel")

$current = Get-Content -Raw -Encoding UTF8 -LiteralPath $readmePath
$currentNormalized = $current -replace "`r`n", "`n"

try {
    $updated = Replace-Block -Content $currentNormalized `
        -BeginMarker "<!-- BEGIN:COMMANDS -->" -EndMarker "<!-- END:COMMANDS -->" `
        -NewBody $commandsTable
    $updated = Replace-Block -Content $updated `
        -BeginMarker "<!-- BEGIN:SKILLS -->" -EndMarker "<!-- END:SKILLS -->" `
        -NewBody $skillsTable
} catch {
    Write-Error $_.Exception.Message
    exit 1
}

if ($Check) {
    if ($currentNormalized -ne $updated) {
        Write-Host "README.md is out of sync with commands/ and/or skills/."
        exit 1
    }
    exit 0
}

if ($currentNormalized -eq $updated) {
    Write-Host "README.md already up to date."
    exit 0
}

$utf8NoBom = New-Object System.Text.UTF8Encoding($false)
[System.IO.File]::WriteAllText($readmePath, $updated, $utf8NoBom)
Write-Host "Updated README.md"
