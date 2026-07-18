$ErrorActionPreference = "Stop"

$PlaybookRoot = Split-Path -Parent $PSScriptRoot
$TargetDir = Join-Path $env:USERPROFILE ".cursor\rules"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$installed = @()
$obsolete = @("docs-md-mdc-sync.mdc")

foreach ($name in $obsolete) {
    $path = Join-Path $TargetDir $name
    if (Test-Path $path) {
        Remove-Item -LiteralPath $path -Force
        Write-Host "Removed obsolete: $name"
    }
}

# generic は alwaysApply、winui は globs で必要なときだけ効く
$sourceDirs = @(
    (Join-Path $PlaybookRoot "rules\generic"),
    (Join-Path $PlaybookRoot "rules\winui")
)

foreach ($SourceDir in $sourceDirs) {
    if (-not (Test-Path $SourceDir)) {
        Write-Warning "Skip missing: $SourceDir"
        continue
    }

    Get-ChildItem -Path $SourceDir -Filter "*.mdc" | ForEach-Object {
        $destName = "playbook-$($_.Name)"
        $destPath = Join-Path $TargetDir $destName
        Copy-Item -Path $_.FullName -Destination $destPath -Force
        $installed += $destName
        Write-Host "Installed: $destName"
    }
}

$manifest = @{
    source      = "cursor-playbook"
    installedAt = (Get-Date).ToString("o")
    scope       = "user"
    files       = $installed
}

$manifestPath = Join-Path $TargetDir ".playbook-installed.json"
$manifest | ConvertTo-Json -Depth 4 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host ""
Write-Host "Done. $($installed.Count) user rule(s) -> $TargetDir"
