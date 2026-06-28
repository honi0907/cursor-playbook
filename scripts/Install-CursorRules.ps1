param(
    [Parameter(Mandatory = $true)]
    [string]$ProjectPath,

    [ValidateSet("generic", "winui", "all")]
    [string[]]$Layers = @("all"),

    [switch]$Verify
)

$ErrorActionPreference = "Stop"

$PlaybookRoot = Split-Path -Parent $PSScriptRoot
$TargetDir = Join-Path (Resolve-Path $ProjectPath).Path ".cursor\rules"

if (-not (Test-Path $TargetDir)) {
    New-Item -ItemType Directory -Path $TargetDir -Force | Out-Null
}

$layerMap = @{
    generic = Join-Path $PlaybookRoot "rules\generic"
    winui   = Join-Path $PlaybookRoot "rules\winui"
}

$selected = if ($Layers -contains "all") { @("generic", "winui") } else { $Layers }
$installed = @()

foreach ($layer in $selected) {
    $sourceDir = $layerMap[$layer]
    if (-not (Test-Path $sourceDir)) {
        Write-Warning "Layer not found: $layer ($sourceDir)"
        continue
    }

    Get-ChildItem -Path $sourceDir -Filter "*.mdc" | ForEach-Object {
        $destName = "playbook-$($_.Name)"
        $destPath = Join-Path $TargetDir $destName
        Copy-Item -Path $_.FullName -Destination $destPath -Force
        $installed += $destName
        Write-Host "Installed: $destName"
    }
}

$manifest = @{
    source     = "cursor-playbook"
    installedAt = (Get-Date).ToString("o")
    layers     = $selected
    files      = $installed
}

$manifestPath = Join-Path $TargetDir ".playbook-installed.json"
$manifest | ConvertTo-Json -Depth 4 | Set-Content -Path $manifestPath -Encoding UTF8

Write-Host ""
Write-Host "Done. $($installed.Count) rule(s) -> $TargetDir"
Write-Host "Project-specific rules (e.g. kakipen-*.mdc) are not modified."

if ($Verify) {
    $verifyScript = Join-Path $PSScriptRoot "verify-doc-pairs.ps1"
    & $verifyScript -ProjectRoot $PlaybookRoot
}
