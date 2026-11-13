param(
    [Parameter(Mandatory = $true)][string]$SteamLibrary,
    [ValidateSet('Catalog', 'Behavior')][string]$Mode = 'Catalog',
    [switch]$Visible
)
$ErrorActionPreference = 'Stop'
$profileName = if ($Mode -eq 'Catalog') { 'InfectionProbe' } else { 'InfectionBehavior' }
$profileFolder = if ($Mode -eq 'Catalog') { 'probe-server' } else { 'behavior-server' }
$missionName = if ($Mode -eq 'Catalog') { 'Infection_ClassProbe.VR' } else { 'Infection_BehaviorProbe.VR' }
$port = if ($Mode -eq 'Catalog') { 2402 } else { 2602 }
$processPattern = '(?:^|\s)-name=' + [regex]::Escape($profileName) + '(?:\s|$)'
if (Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" |
    Where-Object { $_.CommandLine -match $processPattern }) {
    throw "The $profileName test server is already running; collect its results before restarting."
}
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$gameDirectory = Join-Path $SteamLibrary 'steamapps\common\Arma 3'
$executable = Join-Path $gameDirectory 'arma3server_x64.exe'
$workshop = Join-Path $SteamLibrary 'steamapps\workshop\content\107410'
$modPaths = @('450814997', '2291129343', '2789152015', '3020755032') |
    ForEach-Object { Join-Path $workshop $_ }
$missionSource = Join-Path $repoRoot ('.work\probe-missions\' + $missionName + '.pbo')
foreach ($requiredPath in @($executable, $missionSource) + $modPaths) {
    if (-not (Test-Path -LiteralPath $requiredPath)) {
        throw "Required test file or directory is missing: $requiredPath"
    }
}
# Use Arma's standard mission folder. Only this uniquely named, receipt-owned
# fixture may be installed or replaced; preserve every other mission.
$missionDirectoryName = 'MPMissions'
$missionDirectory = Join-Path $gameDirectory $missionDirectoryName
$missionTarget = Join-Path $missionDirectory ($missionName + '.pbo')
$receiptName = if ($Mode -eq 'Catalog') { 'probe-install.json' } else { 'behavior-install.json' }
$receiptPath = Join-Path $repoRoot ('.work\' + $receiptName)
if (Test-Path -LiteralPath $missionTarget) {
    if (-not (Test-Path -LiteralPath $receiptPath)) { throw "Unmanaged mission already exists: $missionTarget" }
    $receipt = Get-Content -LiteralPath $receiptPath -Raw | ConvertFrom-Json
    $existingHash = (Get-FileHash -LiteralPath $missionTarget -Algorithm SHA256).Hash
    if ($receipt.Path -ne $missionTarget -or $receipt.SHA256 -ne $existingHash) {
        throw 'Installed probe differs from its receipt; preserve it and investigate before replacing it.'
    }
}
New-Item -ItemType Directory -Path $missionDirectory -Force | Out-Null
Copy-Item -LiteralPath $missionSource -Destination $missionTarget -Force
[pscustomobject]@{ Path = $missionTarget; SHA256 = (Get-FileHash -LiteralPath $missionTarget -Algorithm SHA256).Hash } |
    ConvertTo-Json | Set-Content -LiteralPath $receiptPath -Encoding UTF8
$profile = Join-Path $repoRoot ('.work\profiles\' + $profileFolder)
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$configuration = Join-Path $profile 'server.cfg'
@"
hostname = "Infection $Mode development probe";
maxPlayers = 2;
loopback = 1;
upnp = 0;
persistent = 1;
class Missions
{
    class Probe
    {
        template = "$missionName";
        difficulty = "Regular";
    };
};
"@ | Set-Content -LiteralPath $configuration -Encoding ASCII
('logFile = "{0}";' -f (Join-Path $profile 'console.log')) |
    Add-Content -LiteralPath $configuration -Encoding ASCII
$arguments = @('-autoInit', '-noSound', '-ip=127.0.0.1', ('-port=' + $port),
    ('-name=' + $profileName), ('"-profiles={0}"' -f $profile),
    ('"-config={0}"' -f $configuration), ('"-mod={0}"' -f ($modPaths -join ';')))
$windowStyle = if ($Visible) { 'Normal' } else { 'Hidden' }
$process = Start-Process -FilePath $executable -ArgumentList $arguments `
    -WorkingDirectory $gameDirectory -WindowStyle $windowStyle -PassThru
[pscustomobject]@{ ProcessId = $process.Id; ProfileDirectory = $profile; Port = $port; Mode = $Mode }
