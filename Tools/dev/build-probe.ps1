param(
    [Parameter(Mandatory = $true)][string]$ArmaTools,
    [ValidateSet('Catalog', 'Behavior', 'Template', 'Dependencies')][string]$Mode = 'Catalog',
    [ValidateSet('Full', 'Administration', 'Reinforcements', 'Roaming', 'Counterattacks', 'Towns', 'Tactical', 'Major', 'Competitive')][string]$Suite = 'Full'
)
$ErrorActionPreference = 'Stop'
if ($Mode -ne 'Template' -and $Suite -ne 'Full') { throw 'Focused suites require Template mode.' }
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
if ($Mode -eq 'Template') {
    $activeHooks = Join-Path $repoRoot '.work\probe-addons\@Infection_Contract_Probe'
    if (Get-CimInstance Win32_Process | Where-Object {
        $_.Name -in @('arma3_x64.exe', 'arma3server_x64.exe') -and
        $_.CommandLine -and $_.CommandLine.Contains($activeHooks)
    }) { throw 'The template contract addon is in use; collect and stop that probe before rebuilding.' }
}
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
    ('"{0}"' -f $Suite.ToLowerInvariant()) |
        Set-Content -LiteralPath (Join-Path $stagedSource 'selectedSuite.sqf') -Encoding ASCII
}
& $packer -property ('prefix=' + $missionName) -dst $packedOutput $stagedSource
if ($LASTEXITCODE -ne 0) { throw 'Probe packing failed' }
$freshArchive = Join-Path $packedOutput ($missionName + '.pbo')
if (-not (Test-Path -LiteralPath $freshArchive)) { throw 'FileBank did not produce the probe mission' }
$archive = Join-Path $output ($missionName + '.pbo')
Copy-Item -LiteralPath $freshArchive -Destination $archive -Force
if ($Mode -eq 'Template') {
    $hookSource = Join-Path $repoRoot 'tests\arma\infection_probe\contracts-addon'
    $hookStage = Join-Path $temporary 'a3i_contracts'
    $hookOutput = Join-Path $repoRoot '.work\probe-addons\@Infection_Contract_Probe\addons'
    New-Item -ItemType Directory -Path $hookStage, $hookOutput -Force | Out-Null
    Get-ChildItem -LiteralPath $hookSource -File | Where-Object Name -ne 'config.cpp' |
        Copy-Item -Destination $hookStage
    & $converter -bin -dst (Join-Path $hookStage 'config.bin') (Join-Path $hookSource 'config.cpp')
    if ($LASTEXITCODE -ne 0) { throw 'Test endpoint config validation failed' }
    & $packer -property 'prefix=x\a3i\tests\contracts' -dst $packedOutput $hookStage
    if ($LASTEXITCODE -ne 0) { throw 'Test endpoint packing failed' }
    Copy-Item -LiteralPath (Join-Path $packedOutput 'a3i_contracts.pbo') -Destination $hookOutput -Force
}
Get-FileHash -LiteralPath $archive -Algorithm SHA256
