param(
    [Parameter(Mandatory = $true)][string]$ArmaTools,
    [ValidatePattern('^[A-Za-z0-9_-]+$')][string]$BuildName = 'Antistasi_Ultimate_Infection'
)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$source = Join-Path $repoRoot 'Infection\addons\core'
$staging = Join-Path $repoRoot ('.work\infection-build\' + [guid]::NewGuid().ToString('N'))
$addon = Join-Path $staging 'a3i_core'
$packed = Join-Path $staging 'packed'
$output = Join-Path $repoRoot ('.work\build\@' + $BuildName)
if (Get-CimInstance Win32_Process | Where-Object {
    $_.Name -in @('arma3_x64.exe', 'arma3server_x64.exe') -and
    $_.CommandLine -and $_.CommandLine.Contains($output)
}) { throw 'That build directory is in use by Arma. Choose a different BuildName.' }
New-Item -ItemType Directory -Path $addon, $packed, (Join-Path $output 'addons') -Force | Out-Null
$converter = Join-Path $ArmaTools 'CfgConvert\CfgConvert.exe'
$packer = Join-Path $ArmaTools 'FileBank\FileBank.exe'
foreach ($requiredPath in @($converter, $packer, (Join-Path $source 'config.cpp'))) {
    if (-not (Test-Path -LiteralPath $requiredPath)) { throw "Missing build input: $requiredPath" }
}
Get-ChildItem -LiteralPath $source | Where-Object Name -ne 'config.cpp' |
    Copy-Item -Destination $addon -Recurse
& $converter -bin -dst (Join-Path $addon 'config.bin') (Join-Path $source 'config.cpp')
if ($LASTEXITCODE -ne 0 -or -not (Test-Path -LiteralPath (Join-Path $addon 'config.bin'))) {
    throw 'Infection config conversion failed'
}
& $packer -property 'prefix=x\a3i\addons\core' -dst $packed $addon
if ($LASTEXITCODE -ne 0) { throw 'Infection packing failed' }
$freshArchive = Join-Path $packed 'a3i_core.pbo'
if (-not (Test-Path -LiteralPath $freshArchive)) { throw 'FileBank produced no addon' }
$archive = Join-Path $output 'addons\a3i_core.pbo'
Copy-Item -LiteralPath $freshArchive -Destination $archive -Force
Copy-Item -LiteralPath (Join-Path $repoRoot 'Infection\mod.cpp') -Destination $output -Force
Copy-Item -LiteralPath (Join-Path $repoRoot 'Infection\THIRD_PARTY_LICENSES.txt') -Destination $output -Force
$sourceFiles = @(Get-ChildItem -LiteralPath (Join-Path $repoRoot 'Infection') -Recurse -File)
$manifest = [ordered]@{
    schema_version = 1
    product = 'Antistasi Ultimate: Infection'
    version = '0.1.0-dev'
    scope = 'Development prototype with registration, combat, bounded spawning and six persistent site routes, transient road/field controls and town patrols; full campaign routes remain incomplete'
    built_at_utc = [DateTime]::UtcNow.ToString('o')
    prefix = 'x\a3i\addons\core'
    addon_sha256 = (Get-FileHash -LiteralPath $archive -Algorithm SHA256).Hash.ToLowerInvariant()
    source = @($sourceFiles | Sort-Object FullName | ForEach-Object {
        [ordered]@{
            path = [System.IO.Path]::GetRelativePath($repoRoot, $_.FullName).Replace('\','/')
            sha256 = (Get-FileHash -LiteralPath $_.FullName -Algorithm SHA256).Hash.ToLowerInvariant()
        }
    })
}
$manifest | ConvertTo-Json -Depth 5 | Set-Content -LiteralPath (Join-Path $output 'build-manifest.json') -Encoding utf8
[pscustomobject]@{ ModDirectory = $output; SHA256 = $manifest.addon_sha256 }
