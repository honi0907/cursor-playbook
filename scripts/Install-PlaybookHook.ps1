$ErrorActionPreference = "Stop"

$PlaybookRoot = Split-Path -Parent $PSScriptRoot
$HookPath = Join-Path $PlaybookRoot ".git\hooks\post-merge"

$hookContent = @'
#!/bin/sh
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/Install-UserCursorRules.ps1
powershell.exe -NoProfile -ExecutionPolicy Bypass -File scripts/Sync-AllProjects.ps1
'@

Set-Content -LiteralPath $HookPath -Value $hookContent -Encoding ASCII
Write-Host "Installed post-merge hook: $HookPath"
