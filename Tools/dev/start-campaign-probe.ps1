param(
    [Parameter(Mandatory=$true)][string]$SteamLibrary,
    [Parameter(Mandatory=$true)][string]$ArmaTools,
    [Parameter(Mandatory=$true)][string]$InfectionMod,
    [string]$ReduxFixesMod,
    [switch]$TraceStartup,
    [switch]$TraceCrate,
    [switch]$CrateKeepInventory,
    [switch]$SiteLifecycle,
    [switch]$SiteCasualties,
    [switch]$CasualtySave,
    [switch]$ExtractionLifecycle,
    [switch]$SuccessMissions,
    [switch]$SupplyReproduction,
    [switch]$SupplyParking,
    [ValidateSet('Write','Read')][string]$Phase='Write',
    [ValidatePattern('^[A-Za-z0-9_-]{1,24}$')][string]$Instance='ReduxSave1',
    [ValidateRange(1024,65531)][int]$Port=5002
)
$ErrorActionPreference='Stop'
if ($SupplyParking -and ($SuccessMissions -or $ExtractionLifecycle -or $CasualtySave -or $SiteCasualties -or $SiteLifecycle -or $TraceStartup -or $TraceCrate)) {throw 'Choose the parking survey without other diagnostics.'}
if ($TraceStartup -and $TraceCrate) {throw 'Choose one startup diagnostic.'}
if ($CrateKeepInventory -and !$TraceCrate) {throw 'Keeping inventory is only a crate diagnostic control.'}
if ($SupplyReproduction -and !$SuccessMissions) {throw 'Supply reproduction requires SuccessMissions.'}
if ($SuccessMissions -and ($ExtractionLifecycle -or $CasualtySave -or $SiteCasualties -or $SiteLifecycle -or $TraceStartup -or $TraceCrate)) {throw 'Choose successful mission checks without other diagnostics.'}
if ($ExtractionLifecycle -and ($CasualtySave -or $SiteCasualties -or $SiteLifecycle -or $TraceStartup -or $TraceCrate)) {throw 'Choose Extraction lifecycle without other diagnostics.'}
if ($CasualtySave -and ($SiteCasualties -or $SiteLifecycle -or $TraceStartup -or $TraceCrate)) {throw 'Choose casualty save testing without other diagnostic modes.'}
if ($SiteCasualties -and ($SiteLifecycle -or $TraceStartup -or $TraceCrate)) {throw 'Choose casualty testing without other diagnostic modes.'}
if ($SiteLifecycle -and ($TraceStartup -or $TraceCrate)) {throw 'Site lifecycle requires the normal campaign helper.'}
$repoRoot=(Resolve-Path (Join-Path $PSScriptRoot '../..')).Path
$gameDirectory=Join-Path $SteamLibrary 'steamapps/common/Arma 3'
$executable=Join-Path $gameDirectory 'arma3server_x64.exe'
$modRoot=(Resolve-Path -LiteralPath $InfectionMod).Path
$helper=Join-Path $repoRoot '.work/campaign-probe/@Infection_Campaign_Probe'
$profile=Join-Path $repoRoot ('.work/profiles/campaign-server-'+$Instance)
$active=Get-CimInstance Win32_Process | Where-Object {
    $_.Name -in @('arma3_x64.exe','arma3server_x64.exe') -and $_.CommandLine -and
    ($_.CommandLine.Contains($helper) -or $_.CommandLine.Contains($profile))
}
if ($active) {throw 'Collect and stop the existing campaign probe before changing its addon or profile.'}
$source=Join-Path $repoRoot 'tests/arma/campaign_probe'
$stage=Join-Path $repoRoot ('.work/campaign-probe-build/'+[guid]::NewGuid().ToString('N'))
$addon=Join-Path $stage 'a3i_campaign_probe'
$packed=Join-Path $stage 'packed'
$output=Join-Path $helper 'addons'
$converter=Join-Path $ArmaTools 'CfgConvert/CfgConvert.exe'
$packer=Join-Path $ArmaTools 'FileBank/FileBank.exe'
$workshop=Join-Path $SteamLibrary 'steamapps/workshop/content/107410'
$mods=@('450814997','2291129343','2789152015','3020755032','583496184','1128256978') | ForEach-Object {Join-Path $workshop $_}
foreach ($required in @($executable,$converter,$packer,(Join-Path $modRoot 'addons/a3i_core.pbo'))+$mods) {
    if (!(Test-Path -LiteralPath $required)) {throw "Required campaign test input missing: $required"}
}
New-Item -ItemType Directory -Path $addon,$packed,$output,$profile -Force | Out-Null
Copy-Item -LiteralPath (Join-Path $source 'run.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'sites.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'casualties.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'casualtySave.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'extraction.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'successMissions.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'supplyParking.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'legacySupplyPosition.sqf') -Destination $addon
Copy-Item -LiteralPath (Join-Path $source 'tunedSupplyPosition.sqf') -Destination $addon
$(if ($SupplyParking) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'supply-parking-mode.sqf') -Encoding ASCII
$(if ($SupplyReproduction) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'supply-reproduction-mode.sqf') -Encoding ASCII
$(if ($SuccessMissions) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'success-missions-mode.sqf') -Encoding ASCII
$(if ($ExtractionLifecycle) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'extraction-mode.sqf') -Encoding ASCII
$(if ($CasualtySave) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'casualty-save-mode.sqf') -Encoding ASCII
$(if ($SiteCasualties) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'casualty-mode.sqf') -Encoding ASCII
$(if ($SiteLifecycle) {'true'} else {'false'}) | Set-Content (Join-Path $addon 'site-mode.sqf') -Encoding ASCII
if ($TraceStartup) {
    Copy-Item -LiteralPath (Join-Path $source 'observe.sqf'),(Join-Path $source 'traceActivateAddons.sqf') -Destination $addon
}
if ($TraceCrate) {
    Copy-Item -LiteralPath (Join-Path $source 'observe.sqf'),(Join-Path $source 'traceInitAmmoBox.sqf') -Destination $addon
}
('"'+$Phase.ToLowerInvariant()+'"') | Set-Content -LiteralPath (Join-Path $addon 'phase.sqf') -Encoding ASCII
$helperConfig=if ($TraceCrate) {'crate-trace-config.cpp'} elseif ($TraceStartup) {'trace-config.cpp'} else {'config.cpp'}
$configSource=Join-Path $source $helperConfig
if ($CrateKeepInventory) {
    $configSource=Join-Path $stage 'crate-control.cpp'
    ((Get-Content (Join-Path $source $helperConfig) -Raw)+"`nA3I_traceKeepCrateInventory=1;`n") | Set-Content $configSource -Encoding UTF8
}
& $converter -bin -dst (Join-Path $addon 'config.bin') $configSource
if ($LASTEXITCODE -ne 0) {throw 'Campaign helper configuration failed'}
& $packer -property 'prefix=x\a3i\tests\campaign' -dst $packed $addon
if ($LASTEXITCODE -ne 0) {throw 'Campaign helper packing failed'}
Copy-Item -LiteralPath (Join-Path $packed 'a3i_campaign_probe.pbo') -Destination $output -Force
$mods+=@($modRoot,$helper)
$companionReceipt=$null
if ($ReduxFixesMod) {
    $companion=(Resolve-Path -LiteralPath $ReduxFixesMod).Path
    $companionPbo=Join-Path $companion 'addons/a3urf_core.pbo'
    if (!(Test-Path -LiteralPath $companionPbo)) {throw 'Redux fixes addon missing'}
    $mods+=$companion
    $companionReceipt=@{Directory=$companion;PBO=(Get-FileHash $companionPbo).Hash}
}
$config=Join-Path $profile 'server.cfg'
@'
hostname = "Infection isolated full campaign save probe";
maxPlayers = 2;
loopback = 1;
upnp = 0;
persistent = 1;
class Missions {
    class Probe {
        template = "Antistasi_chernarusredux.chernarusredux";
        difficulty = "Regular";
    };
};
'@ | Set-Content -LiteralPath $config -Encoding ASCII
$launchArgs=@('-autoInit','-noSound','-ip=127.0.0.1',('-port='+$Port),('-name=InfectionCampaign_'+$Instance),
    ('"-profiles={0}"' -f $profile),('"-config={0}"' -f $config),('"-mod={0}"' -f ($mods -join ';')))
$process=Start-Process -FilePath $executable -ArgumentList $launchArgs -WorkingDirectory $gameDirectory -WindowStyle Hidden -PassThru
$helperInputs=@{}
$inputNames=if ($TraceCrate) {@('crate-trace-config.cpp','observe.sqf','traceInitAmmoBox.sqf')} elseif ($TraceStartup) {@('trace-config.cpp','observe.sqf','traceActivateAddons.sqf')} else {@('config.cpp','run.sqf')}
foreach ($inputName in $inputNames) {$helperInputs[$inputName]=(Get-FileHash (Join-Path $source $inputName)).Hash}
if ($SiteLifecycle) {$helperInputs['sites.sqf']=(Get-FileHash (Join-Path $source 'sites.sqf')).Hash}
if ($SiteCasualties -or $CasualtySave) {$helperInputs['casualties.sqf']=(Get-FileHash (Join-Path $source 'casualties.sqf')).Hash}
if ($CasualtySave) {$helperInputs['casualtySave.sqf']=(Get-FileHash (Join-Path $source 'casualtySave.sqf')).Hash}
if ($ExtractionLifecycle) {$helperInputs['extraction.sqf']=(Get-FileHash (Join-Path $source 'extraction.sqf')).Hash}
if ($SuccessMissions) {$helperInputs['successMissions.sqf']=(Get-FileHash (Join-Path $source 'successMissions.sqf')).Hash}
if ($SupplyParking) {$helperInputs['supplyParking.sqf']=(Get-FileHash (Join-Path $source 'supplyParking.sqf')).Hash}
if ($SupplyParking) {$helperInputs['legacySupplyPosition.sqf']=(Get-FileHash (Join-Path $source 'legacySupplyPosition.sqf')).Hash}
if ($SupplyParking) {$helperInputs['tunedSupplyPosition.sqf']=(Get-FileHash (Join-Path $source 'tunedSupplyPosition.sqf')).Hash}
$receipt=[ordered]@{SupplyParking=[bool]$SupplyParking;SupplyReproduction=[bool]$SupplyReproduction;SuccessMissions=[bool]$SuccessMissions;ExtractionLifecycle=[bool]$ExtractionLifecycle;CasualtySave=[bool]$CasualtySave;SiteCasualties=[bool]$SiteCasualties;Phase=$Phase;TraceStartup=[bool]$TraceStartup;TraceCrate=[bool]$TraceCrate;CrateKeepInventory=[bool]$CrateKeepInventory;SiteLifecycle=[bool]$SiteLifecycle;HelperInputs=$helperInputs;ProcessId=$process.Id;ProfileDirectory=$profile;Port=$Port;
    StartedUTC=[DateTime]::UtcNow.ToString('o');ProductionPBO=(Get-FileHash (Join-Path $modRoot 'addons/a3i_core.pbo')).Hash;
    HelperPBO=(Get-FileHash (Join-Path $output 'a3i_campaign_probe.pbo')).Hash;
    HelperSource=(Get-FileHash (Join-Path $source 'run.sqf')).Hash;ReduxFixes=$companionReceipt}
$receipt | ConvertTo-Json | Set-Content -LiteralPath (Join-Path $profile ($Phase.ToLowerInvariant()+'-launch.json')) -Encoding UTF8
[pscustomobject]$receipt
