param(
    [Parameter(Mandatory = $true)]
    [string]$SteamLibrary,
    [switch]$IncludeChernarusRedux,
    [string]$InfectionMod
)

$ErrorActionPreference = 'Stop'
if (Get-CimInstance Win32_Process -Filter "Name='arma3_x64.exe'" |
    Where-Object { $_.CommandLine -match '(?:^|\s)-name=InfectionDev(?:\s|$)' }) {
    throw 'The InfectionDev test client is already running; use that session or close it first.'
}
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$gameDirectory = Join-Path $SteamLibrary 'steamapps\common\Arma 3'
$gameExecutable = Join-Path $gameDirectory 'arma3_x64.exe'
$workshopDirectory = Join-Path $SteamLibrary 'steamapps\workshop\content\107410'
$modIds = @('450814997', '2291129343', '2789152015', '3020755032')
if ($IncludeChernarusRedux) {
    $modIds += @('583496184', '1128256978')
}
$modPaths = @($modIds | ForEach-Object { Join-Path $workshopDirectory $_ })
if ($InfectionMod) {
    $modPaths += (Resolve-Path -LiteralPath $InfectionMod).Path
}
foreach ($requiredPath in @($gameExecutable) + $modPaths) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required test file or directory is missing: $requiredPath"
    }
}
$profileDirectory = Join-Path $repoRoot '.work\profiles\client'
New-Item -ItemType Directory -Path $profileDirectory -Force | Out-Null
$arguments = @(
    '-noSplash', '-skipIntro', '-world=empty', '-window', '-noPause',
    '-name=InfectionDev',
    ('"-profiles={0}"' -f $profileDirectory),
    ('"-mod={0}"' -f ($modPaths -join ';'))
)
# This is the visible client used for manual testing, with an isolated profile.
$process = Start-Process -FilePath $gameExecutable -ArgumentList $arguments `
    -WorkingDirectory $gameDirectory -PassThru
[pscustomobject]@{
    ProcessId = $process.Id
    ProfileDirectory = $profileDirectory
    Mods = $modIds -join ','
    InfectionLoaded = [bool]$InfectionMod
}
