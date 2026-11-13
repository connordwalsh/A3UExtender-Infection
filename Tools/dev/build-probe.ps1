param(
    [Parameter(Mandatory = $true)][string]$ArmaTools,
    [ValidateSet('Catalog', 'Behavior', 'Template', 'Dependencies')][string]$Mode = 'Catalog'
)
$ErrorActionPreference = 'Stop'
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$sourceName = @{ Catalog = 'catalog.VR'; Behavior = 'behavior.VR'; Template = 'template.VR'; Dependencies = 'template.VR' }[$Mode]
$missionName = @{ Catalog = 'Infection_ClassProbe.VR'; Behavior = 'Infection_BehaviorProbe.VR'; Template = 'Infection_TemplateProbe.VR'; Dependencies = 'Infection_DependencyProbe.VR' }[$Mode]
$source = Join-Path $repoRoot ('tests\arma\infection_probe\' + $sourceName)
$output = Join-Path $repoRoot '.work\probe-missions'
# Every build uses an empty staging directory; an old PBO cannot mask a failure.
$temporary = Join-Path $repoRoot ('.work\probe-build\' + [guid]::NewGuid().ToString('N'))
$stagedSource = Join-Path $temporary $missionName
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
if ($Mode -eq 'Behavior') {
    Copy-Item -LiteralPath (Join-Path $repoRoot 'tests\arma\infection_probe\catalog.VR\candidates.sqf') -Destination $stagedSource
}
if ($Mode -in @('Template', 'Dependencies')) {
    # The expected state is part of the packed fixture, not inferred from results.
    ($Mode -eq 'Template').ToString().ToLowerInvariant() |
        Set-Content -LiteralPath (Join-Path $stagedSource 'expectedDependencies.sqf') -Encoding ASCII
}
& $packer -property ('prefix=' + $missionName) -dst $packedOutput $stagedSource
if ($LASTEXITCODE -ne 0) { throw 'Probe packing failed' }
$freshArchive = Join-Path $packedOutput ($missionName + '.pbo')
if (-not (Test-Path -LiteralPath $freshArchive)) { throw 'FileBank did not produce the probe mission' }
$archive = Join-Path $output ($missionName + '.pbo')
Copy-Item -LiteralPath $freshArchive -Destination $archive -Force
Get-FileHash -LiteralPath $archive -Algorithm SHA256
