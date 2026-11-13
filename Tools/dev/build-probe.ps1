param([Parameter(Mandatory = $true)][string]$ArmaTools)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$source = Join-Path $repoRoot 'tests\arma\infection_probe\catalog.VR'
$output = Join-Path $repoRoot '.work\probe-missions'
# Every build uses an empty staging directory; an old PBO cannot mask a failure.
$temporary = Join-Path $repoRoot ('.work\probe-build\' + [guid]::NewGuid().ToString('N'))
$stagedSource = Join-Path $temporary 'Infection_ClassProbe.VR'
$packedOutput = Join-Path $temporary 'packed'
New-Item -ItemType Directory -Path $output, $stagedSource, $packedOutput -Force | Out-Null
$converter = Join-Path $ArmaTools 'CfgConvert\CfgConvert.exe'
$packer = Join-Path $ArmaTools 'FileBank\FileBank.exe'
foreach ($relative in @('mission.sqm', 'description.ext')) {
    $checkOutput = Join-Path $temporary ($relative + '.bin')
    & $converter -bin -dst $checkOutput (Join-Path $source $relative)
    if ($LASTEXITCODE -ne 0) { throw "Config validation failed: $relative" }
}
Get-ChildItem -LiteralPath $source -File | Copy-Item -Destination $stagedSource
& $packer -property 'prefix=Infection_ClassProbe.VR' -dst $packedOutput $stagedSource
if ($LASTEXITCODE -ne 0) { throw 'Probe packing failed' }
$freshArchive = Join-Path $packedOutput 'Infection_ClassProbe.VR.pbo'
if (-not (Test-Path -LiteralPath $freshArchive)) { throw 'FileBank did not produce the probe mission' }
$archive = Join-Path $output 'Infection_ClassProbe.VR.pbo'
Copy-Item -LiteralPath $freshArchive -Destination $archive -Force
Get-FileHash -LiteralPath $archive -Algorithm SHA256
