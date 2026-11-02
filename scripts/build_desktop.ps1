param([switch]$Release)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$localCargo = Join-Path $projectRoot '.tools\cargo\bin\cargo.exe'
if (Test-Path -LiteralPath $localCargo) {
    $env:RUSTUP_HOME = Join-Path $projectRoot '.tools\rustup'
    $env:CARGO_HOME = Join-Path $projectRoot '.tools\cargo'
    $env:PATH = "$(Split-Path $localCargo);$env:PATH"
    $cargo = $localCargo
} else {
    $cargo = (Get-Command cargo -ErrorAction Stop).Source
}
$env:CARGO_PROFILE_DEV_DEBUG = '0'
Push-Location (Join-Path $projectRoot 'desktop')
try {
    $buildArgs = @('build', '--locked', '-p', 'craft-anything', '--bins')
    if ($Release) { $buildArgs += '--release' }
    & $cargo @buildArgs
    if ($LASTEXITCODE -ne 0) { throw 'Desktop compilation failed.' }
    $profile = if ($Release) { 'release' } else { 'debug' }
    Write-Output (Join-Path $projectRoot "desktop\target\$profile\rei-reverse-engineer.exe")
} finally {
    Pop-Location
}
