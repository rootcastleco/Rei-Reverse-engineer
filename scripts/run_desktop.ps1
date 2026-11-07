param([string]$Python = $env:REI_PYTHON)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$exe = Join-Path $projectRoot 'desktop\target\debug\rei-reverse-engineer.exe'
if (-not (Test-Path -LiteralPath $exe)) {
    & (Join-Path $PSScriptRoot 'build_desktop.ps1')
}
if (-not $Python) {
    $pythonCommand = Get-Command python -ErrorAction SilentlyContinue
    if ($pythonCommand) { $Python = $pythonCommand.Source }
}
if (-not $Python) {
    $uvCommand = Get-Command uv -ErrorAction SilentlyContinue
    if ($uvCommand) { $Python = (& $uvCommand.Source python find --offline | Select-Object -Last 1) }
}
if (-not $Python) { throw 'Use -Python <python.exe path> to connect the REI Python workbench.' }
$env:PYTHONPATH = Join-Path $projectRoot 'src'
$env:REI_CONFIG_DIR = Join-Path $projectRoot '.rei-desktop'
$node = Join-Path $projectRoot '.tools\node-v24.22.1-win-x64\node.exe'
$prepareArgs = @('-m', 'rei_rea.desktop_bridge', '--workspace', $projectRoot, '--config', $env:REI_CONFIG_DIR)
if (Test-Path -LiteralPath $node) { $prepareArgs += @('--node', $node) }
& $Python @prepareArgs
if ($LASTEXITCODE -ne 0) { throw 'Desktop bridge preparation failed.' }
$bridge = Join-Path $projectRoot 'desktop\target\debug\rei-bridge-check.exe'
if (Test-Path -LiteralPath $bridge) {
    & $bridge
    if ($LASTEXITCODE -ne 0) { Write-Warning 'MCP discovery was incomplete. Check Plugins in Settings; the native engine remains available.' }
}
Start-Process -FilePath $exe -WorkingDirectory $projectRoot
