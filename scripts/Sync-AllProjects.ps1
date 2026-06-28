param(
    [string]$RegistryPath = ""
)

$ErrorActionPreference = "Stop"

if ([string]::IsNullOrWhiteSpace($RegistryPath)) {
    $RegistryPath = Join-Path $PSScriptRoot "registered-projects.json"
}

if (-not (Test-Path $RegistryPath)) {
    $examplePath = Join-Path $PSScriptRoot "registered-projects.example.json"
    Write-Warning "Registry not found: $RegistryPath"
    Write-Warning "Copy registered-projects.example.json to registered-projects.json and edit paths."
    if (Test-Path $examplePath) {
        Write-Warning "Example: $examplePath"
    }
    exit 0
}

$projects = Get-Content -LiteralPath $RegistryPath -Raw -Encoding UTF8 | ConvertFrom-Json
$installScript = Join-Path $PSScriptRoot "Install-CursorRules.ps1"

foreach ($projectPath in $projects) {
    if (-not (Test-Path $projectPath)) {
        Write-Warning "Skip missing project: $projectPath"
        continue
    }

    Write-Host "Syncing: $projectPath"
    & $installScript -ProjectPath $projectPath
}

Write-Host "All registered projects synced."
