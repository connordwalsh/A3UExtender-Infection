# Sprint 0 evidence and open questions

Date: 12 November 2026. This is an evidence ledger, not a release certification.

## Reproducible dependency baseline

The installed Arma client reports 2.22.154089; Steam's app manifest records build
25623484. Ultimate reports 12.4.1, matching the current stable source release at
`ea8bcf9f05d6b0d4642179db845d7d3425ceab0d`. The extender fork starts at upstream
`fe425cdbff362d799393559f39292acec7129b5e`.

[installed-baseline.json](../../evidence/sprint-0/installed-baseline.json) records
Workshop manifests and SHA-256 hashes for 198 PBOs in the six-mod acceptance stack.
It was generated with `Tools/dev/inventory.py`, not inferred from Workshop titles.

| Load order | Workshop item | Role |
| --- | --- | --- |
| 1 | 450814997 | CBA_A3 |
| 2 | 2291129343 | Improved Melee System, required by WebKnight |
| 3 | 2789152015 | WebKnight Zombies and Creatures |
| 4 | 3020755032 | Antistasi Ultimate |
| 5 | 583496184 | CUP Terrains Core, required by the acceptance map |
| 6 | 1128256978 | Chernarus Redux, acceptance map only |

The installed Ultimate core was extracted with the installed Bohemia BankRev tool
and compared to the pinned source. 1,323 SQF/HPP/CPP files are byte-identical.
The only differing common file, `config.cpp`, adds the packer's
`#include "BIS_AddonInfo.hpp"` line. No source-only files were found; the generated
`BIS_AddonInfo.hpp` is installed-only. See
[core-source-equivalence.json](../../evidence/sprint-0/core-source-equivalence.json).
This comparison covers core source equivalence; it does not certify all other
addons or runtime compatibility.

## Local-host baseline: startup observed

Launched through `Tools/dev/start-local-test.ps1 -SteamLibrary <library>
-IncludeChernarusRedux`, using the isolated `InfectionDev` profile. Infection was
not loaded. The test used Multiplayer → LAN host → Chernarus Redux → Antistasi
Ultimate - Redux → Default Commander → Create new game.

The selected unmodified control factions were `Vanilla_NATO_Temperate`,
`Vanilla_CSAT_Temperate`, `Vanilla_LL`, `Vanilla_Civ`, and
`Vanilla_Exegermenos`. These are baseline controls, not the approved final
NATO/Russia product configuration.

At 19:10:53 UTC, Ultimate created campaign ID
`fb6c1eb1-c731-4c81-b280-67251b8c449f`. Its server and garrison initialization
completed. Client initialization completed at 19:11:09 UTC. The player appeared
at the HQ with Petros and the arsenal visible, war level 1, HR 8, faction money
1000, and player money 500. See
[startup screenshot](../../evidence/sprint-0/local-baseline-playable.png).

Manual save, archived baseline save, reload, and dedicated campaign startup
remain open. A created campaign ID alone is not proof of a persisted save.
The Computer Use keyboard input did not open the expected menus. The owner
reported the game ready for inspection, then paused work. After explicit resume,
both earlier test processes were closed. The client log ends normally at
19:53:01 UTC without a completed save. The isolated client was restarted to
repeat the save/reload check; the earlier campaign ID is not a saved fixture.

## Findings before Infection exists

The unmodified dedicated control was launched with
`Tools/dev/start-baseline-server.ps1`, the six-mod acceptance stack, profile
`InfectionBaseline`, loopback address, and port 2502. At 21:48:21 UTC the server
started `Antistasi_chernarusredux.chernarusredux`; zone initialization completed
at 21:48:37 and background/PATCOM initialization at 21:48:43. Its log confirms
that no extender was loaded. A client still needs to join, create the new
campaign, and demonstrate save/reload before S0-1 can pass.

| Finding | Evidence / current interpretation | Follow-up |
| --- | --- | --- |
| Missing population values for several Redux settlements | `fn_getCityData.sqf` reports an error, then explicitly falls back to counting nearby houses. Startup completed. | Compare population names to map data and inspect effects before proposing a separate terrain correction. |
| Sites without vehicle placement markers | `fn_initSpawnPlaces.sqf` reports warnings. Its source explicitly allows locations with no vehicle places. | Sample the actual sites; a warning alone is not a demonstrated placement defect. |
| Missing Redux description localization keys | Baseline RPT reports missing `STR_antistasi_mission_info_chernarus_*` strings. | Track as upstream/map baseline behavior; avoid attributing it to Infection. |
| IMS/WebKnight animation warnings on a dedicated process | Logs report missing animation resources before the class probe starts. | Determine which selected creature behaviors are affected in live tests. |
| Standalone class-probe launch loop | Console repeatedly reports the probe mission read from bank; no tagged start record appears. The unmodified Redux mission starts on the same installed server executable. | Resolve the probe mission/configuration defect before claiming any class result. |

Bohemia's [crash-log reference](https://community.bistudio.com/wiki/Crash_Files)
identifies the isolated `a3_characters_f` missing-content warning as a false
warning. It occurs before the probe launch loop, but is not established as its
cause. Other missing-content messages must still be investigated individually.

Raw logs, profile data, saves, and extracted third-party files stay in ignored
`.work/`. Public evidence must omit player identifiers and private paths.

## Confirmed source contracts

All Ultimate references below refer to the pinned 12.4.1 source.

* `core/functions/init/fn_initVarCommon.sqf` already sets Occupants to WEST,
  Invaders and Rivals to EAST, and teamPlayer to INDEPENDENT.
* `core/functions/CREATE/fn_createUnit.sqf` supports a `baseClass` trait and
  preserving the prepared class loadout. `fn_spawnGroup.sqf` is scheduled
  (it sleeps between unit creation); callers must preserve that requirement.
* `core/functions/CREATE/fn_NATOinit.sqf` installs Ultimate's damage, killed, and
  deleted handlers before emitting `A3A_event_serverInitAiUnit`. Damage-handler
  ordering must be tested against WebKnight's custom hit points; replacing all
  handlers would discard campaign bookkeeping.
* `patcom/functions/Civilian/fn_createAmbientCiv.sqf` creates CIV groups and
  counts `units civilian` against the global limit. Resource and traffic civilian
  creators also use CIV. Moving survivors to INDEP requires auditing counts,
  capture attribution, cleanup, traffic, and civilian penalties. This is not yet
  evidence that the preferred INDEP design is impossible.
* `core/Includes/cba_events.hpp` exposes server game-load/save/saved, AI-init,
  civilian-init, location-spawn, and marker-change events. These are observable
  hooks; post-spawn events alone cannot prevent an incompatible vehicle spawn.

## WebKnight source findings

The installed PBO configuration contains the 14 BLUFOR candidates listed in
`tests/arma/infection_probe/catalog.VR/candidates.sqf`. Each uses the mod's own
prepared-class initialization. No arbitrary-human conversion hook is required
to start the class smoke test.

The prepared-class extended init handlers run their AI only where the unit is
local. Basic walkers use `findNearestEnemy`; their death/deletion handlers remove
the stored CBA per-frame handlers. Locality transfer and dedicated targeting are
still unverified.

`WBK_AI_ISZombie` is **not consistently Boolean**. Smasher initialization writes
numeric `0`; other inspected AI writes `true`. Code must check presence/type
deliberately, not use the variable directly as an `if` condition.

The Corrupted headcrab has an explicit successful-attack possession routine
which changes a non-player victim's group side and starts runner AI. That is
different from a blanket rule converting every killed human. No universal
kill-to-infection behavior has been established; preserve the installed defaults
and complete the controlled civilian tests before documenting player behavior.

## Current gate status

Gate 0 remains open. Local startup and source matching are evidenced; dedicated
campaign startup, saved baseline, per-class combat behavior, and the complete
reviewed Occupant impact matrix are not yet accepted.
