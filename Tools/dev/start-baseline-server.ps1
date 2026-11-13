param([Parameter(Mandatory = $true)][string]$SteamLibrary)
$ErrorActionPreference = 'Stop'
if (Get-CimInstance Win32_Process -Filter "Name='arma3server_x64.exe'" |
    Where-Object { $_.CommandLine -match '(?:^|\s)-name=InfectionBaseline(?:\s|$)' }) {
    throw 'The InfectionBaseline test server is already running; use that session or close it first.'
}
$repoRoot = (Resolve-Path -LiteralPath (Join-Path $PSScriptRoot '..\..')).Path
$gameDirectory = Join-Path $SteamLibrary 'steamapps\common\Arma 3'
$executable = Join-Path $gameDirectory 'arma3server_x64.exe'
$workshop = Join-Path $SteamLibrary 'steamapps\workshop\content\107410'
$modPaths = @('450814997', '2291129343', '2789152015', '3020755032', '583496184', '1128256978') |
    ForEach-Object { Join-Path $workshop $_ }
foreach ($requiredPath in @($executable) + $modPaths) {
    if (-not (Test-Path -LiteralPath $requiredPath)) { throw "Required path is missing: $requiredPath" }
}
$profile = Join-Path $repoRoot '.work\profiles\baseline-server'
New-Item -ItemType Directory -Path $profile -Force | Out-Null
$configuration = Join-Path $profile 'server.cfg'
@'
hostname = "Infection unmodified baseline";
maxPlayers = 8;
loopback = 1;
upnp = 0;
persistent = 1;
class Missions
{
    class Baseline
    {
        template = "Antistasi_chernarusredux.chernarusredux";
        difficulty = "Regular";
    };
};
'@ | Set-Content -LiteralPath $configuration -Encoding ASCII
('logFile = "{0}";' -f (Join-Path $profile 'console.log')) |
    Add-Content -LiteralPath $configuration -Encoding ASCII
# Arma's loopback setting above restricts this test to local clients. Allow the
# engine to choose its interfaces so Steam networking can initialize normally.
$arguments = @('-autoInit', '-noSound', '-port=2502',
    '-name=InfectionBaseline', ('"-profiles={0}"' -f $profile),
    ('"-config={0}"' -f $configuration), ('"-mod={0}"' -f ($modPaths -join ';')))
$process = Start-Process -FilePath $executable -ArgumentList $arguments `
    -WorkingDirectory $gameDirectory -WindowStyle Hidden -PassThru
[pscustomobject]@{ ProcessId = $process.Id; ProfileDirectory = $profile; Port = 2502 }
