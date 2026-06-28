param(
    [string]$ProjectRoot = "",
    [string]$ConfigPath = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($ProjectRoot)) {
    $ProjectRoot = Resolve-Path (Join-Path $PSScriptRoot "..")
}
else {
    $ProjectRoot = Resolve-Path $ProjectRoot
}

if ([string]::IsNullOrWhiteSpace($ConfigPath)) {
    $ConfigPath = Join-Path $PSScriptRoot "doc-pairs.json"
}
else {
    $ConfigPath = Resolve-Path $ConfigPath
}

if (-not (Test-Path $ConfigPath)) {
    throw "Missing config file: $ConfigPath"
}

$pairs = Get-Content -LiteralPath $ConfigPath -Raw -Encoding UTF8 | ConvertFrom-Json

function Remove-YamlFrontmatter {
    param([string]$Text)
    if ($Text -match '(?s)^---\r?\n.*?\r?\n---\r?\n(.*)$') {
        return $Matches[1]
    }
    return $Text
}

function Normalize-MirrorText {
    param([string]$Text)

    $normalized = Remove-YamlFrontmatter $Text
    $normalized = [regex]::Replace($normalized, '<!--.*?-->', '', 'Singleline')
    $normalized = [regex]::Replace($normalized, '^\s*.+:\s*\[[^\]]+\]\([^\)]+\)\s*\r?\n', '', 'Multiline')

    $lines = $normalized -split '\r?\n' | ForEach-Object { $_.TrimEnd() }
    $builder = New-Object System.Text.StringBuilder
    $blankPending = $false

    foreach ($line in $lines) {
        if ([string]::IsNullOrWhiteSpace($line)) {
            if (-not $blankPending -and $builder.Length -gt 0) {
                [void]$builder.AppendLine()
                $blankPending = $true
            }
            continue
        }

        $blankPending = $false
        [void]$builder.AppendLine($line)
    }

    return $builder.ToString().TrimEnd()
}

function Get-SectionRangeText {
    param(
        [string]$Text,
        [string]$StartHeading,
        [string]$EndHeading = ""
    )

    $startMatch = [regex]::Match($Text, '(?m)^' + [regex]::Escape($StartHeading) + '\r?\n')
    if (-not $startMatch.Success) {
        throw "Section not found: $StartHeading"
    }

    $startIndex = $startMatch.Index

    if ([string]::IsNullOrWhiteSpace($EndHeading)) {
        return $Text.Substring($startIndex).TrimEnd()
    }

    $endMatch = [regex]::Match($Text, '(?m)^' + [regex]::Escape($EndHeading) + '\r?\n')
    if (-not $endMatch.Success) {
        throw "Section not found: $EndHeading"
    }

    $afterEndHeading = $endMatch.Index + $endMatch.Length
    $nextSection = [regex]::Match($Text.Substring($afterEndHeading), '(?m)^## ')
    if ($nextSection.Success) {
        $endIndex = $afterEndHeading + $nextSection.Index
        return $Text.Substring($startIndex, $endIndex - $startIndex).TrimEnd()
    }

    return $Text.Substring($startIndex).TrimEnd()
}

function Compare-DocPair {
    param(
        [string]$Name,
        [string]$MarkdownPath,
        [string]$RulePath,
        [string]$StartHeading,
        [string]$EndHeading = ""
    )

    $mdFull = Get-Content -LiteralPath $MarkdownPath -Raw -Encoding UTF8
    $mdcFull = Get-Content -LiteralPath $RulePath -Raw -Encoding UTF8

    $mdSection = Get-SectionRangeText -Text $mdFull -StartHeading $StartHeading -EndHeading $EndHeading
    $mdcSection = Get-SectionRangeText -Text $mdcFull -StartHeading $StartHeading -EndHeading $EndHeading

    $mdNorm = Normalize-MirrorText $mdSection
    $mdcNorm = Normalize-MirrorText $mdcSection

    if ($mdNorm -eq $mdcNorm) {
        Write-Host "OK  $Name"
        return $true
    }

    Write-Host "FAIL $Name" -ForegroundColor Red
    Write-Host "  markdown: $MarkdownPath"
    Write-Host "  rule:     $RulePath"
    $endLabel = if ($EndHeading) { $EndHeading } else { "EOF" }
    Write-Host "  section:  $StartHeading -> $endLabel"

    $mdLines = $mdNorm -split '\r?\n'
    $mdcLines = $mdcNorm -split '\r?\n'
    $max = [Math]::Max($mdLines.Count, $mdcLines.Count)
    $diffCount = 0

    for ($i = 0; $i -lt $max; $i++) {
        $left = if ($i -lt $mdLines.Count) { $mdLines[$i] } else { "<missing>" }
        $right = if ($i -lt $mdcLines.Count) { $mdcLines[$i] } else { "<missing>" }
        if ($left -ne $right) {
            if ($diffCount -lt 8) {
                Write-Host ("  line {0}:" -f ($i + 1))
                Write-Host ("    md : {0}" -f $left)
                Write-Host ("    mdc: {0}" -f $right)
            }
            $diffCount++
        }
    }

    if ($diffCount -gt 8) {
        $more = $diffCount - 8
        Write-Host "  ... and $more more differing line(s)"
    }

    return $false
}

$allOk = $true
foreach ($pair in $pairs) {
    $markdownPath = Join-Path $ProjectRoot $pair.markdown
    $rulePath = Join-Path $ProjectRoot $pair.rule

    if (-not (Test-Path $markdownPath)) {
        throw "Missing markdown file: $markdownPath"
    }
    if (-not (Test-Path $rulePath)) {
        throw "Missing rule file: $rulePath"
    }

    $ok = Compare-DocPair `
        -Name $pair.name `
        -MarkdownPath $markdownPath `
        -RulePath $rulePath `
        -StartHeading $pair.startHeading `
        -EndHeading $pair.endHeading

    if (-not $ok) {
        $allOk = $false
    }
}

if (-not $allOk) {
    Write-Error "Document pair verification failed."
    exit 1
}

Write-Host "All document pairs verified."
exit 0
