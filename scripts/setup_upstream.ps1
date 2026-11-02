param([string]$Node)
$ErrorActionPreference = 'Stop'
$projectRoot = Split-Path $PSScriptRoot -Parent
$tools = Join-Path $projectRoot '.tools'
New-Item -ItemType Directory -Path $tools -Force | Out-Null
if (-not $Node) {
    $version = '24.22.1'
    $archiveName = "node-v$version-win-x64.zip"
    $Node = Join-Path $tools "node-v$version-win-x64\node.exe"
    if (-not (Test-Path -LiteralPath $Node)) {
        $archive = Join-Path $tools $archiveName
        Invoke-WebRequest "https://nodejs.org/dist/v$version/$archiveName" -OutFile $archive
        $checksums = (Invoke-WebRequest "https://nodejs.org/dist/v$version/SHASUMS256.txt").Content
        $line = ($checksums -split "`n" | Where-Object { $_.Trim().EndsWith(" $archiveName") })
        if (@($line).Count -ne 1) { throw 'Node checksum entry not unique.' }
        $expected = ($line.Trim() -split '\s+')[0]
        if ((Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash -ne $expected) { throw 'Node checksum mismatch.' }
        Expand-Archive -LiteralPath $archive -DestinationPath $tools -Force
    }
}
$nodeRoot = Split-Path (Resolve-Path -LiteralPath $Node).Path
$npm = Join-Path $nodeRoot 'npm.cmd'
$oldPath = $env:PATH
$env:PATH = "$nodeRoot;$oldPath"
$env:TURBO_TELEMETRY_DISABLED = '1'
Push-Location (Join-Path $projectRoot 'upstream\rea')
try {
    & $npm ci --ignore-scripts
    if ($LASTEXITCODE -ne 0) { throw 'Locked upstream dependency installation failed.' }
    $packageVersion = (Get-Content package.json -Raw | ConvertFrom-Json).version
    $staging = Join-Path $tools "rea-native-$packageVersion"
    New-Item -ItemType Directory -Path $staging -Force | Out-Null
    & $npm pack "rea-agents@$packageVersion" --ignore-scripts --pack-destination $staging
    if ($LASTEXITCODE -ne 0) { throw 'Matching upstream npm package unavailable.' }
    $tarball = Join-Path $staging "rea-agents-$packageVersion.tgz"
    & tar.exe -xzf $tarball -C $staging 'package/native/windows/build/manifest.json' 'package/native/windows/build/rea-windows-x64.node'
    if ($LASTEXITCODE -ne 0) { throw 'Native module extraction failed.' }
    $nativeSource = Join-Path $staging 'package\native\windows\build'
    $manifest = Get-Content (Join-Path $nativeSource 'manifest.json') -Raw | ConvertFrom-Json
    if ($manifest.packageVersion -ne $packageVersion -or $manifest.architecture -ne 'x64') { throw 'Native provenance mismatch.' }
    if ((Get-FileHash (Join-Path $nativeSource 'rea-windows-x64.node') -Algorithm SHA256).Hash -ne $manifest.artifactSha256) { throw 'Native module checksum mismatch.' }
    New-Item -ItemType Directory -Path native/windows/build -Force | Out-Null
    Copy-Item -LiteralPath (Join-Path $nativeSource 'manifest.json'), (Join-Path $nativeSource 'rea-windows-x64.node') -Destination native/windows/build
    & $npm run build:cached
    if ($LASTEXITCODE -ne 0) { throw 'Upstream runtime build failed.' }
} finally {
    Pop-Location
    $env:PATH = $oldPath
}
