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

## Local-host baseline: startup and persistent save observed

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

The first client log ends normally at 19:53:01 UTC without a completed save;
that earlier campaign ID is not a saved fixture. After the owner's explicit
resume, the isolated client created a fresh campaign at 21:40:47 UTC with ID
`32ca87ca-6170-4b73-b64a-3d7ad2879802`. The owner opened the commander menu because
Computer Use keyboard input did not activate it. Computer Use then selected
Game Options → Persistent Save. The log records `Persistent Save Completed`
at 23:56:35.608 UTC, and the actual `AntistasiUltimate.vars` file was archived
locally with the test profile files.

The [save manifest](../../evidence/sprint-0/local-baseline-save.json) records
their hashes and the [post-save screen](../../evidence/sprint-0/local-baseline-saved.png)
shows war level 1, HR 8, faction money 1019 and player money 506. Raw saves stay
private because they contain player identifiers.

After checking that the current save exactly matched its backup, the owned test
client was stopped and relaunched. Mouse interaction selected the same campaign
in Ultimate's load dialog. Persistent load completed at 00:16:57.951 UTC on
13 November, and client initialization completed at 00:17:14.084 UTC. The player
returned to HQ with war level 1, HR 8, faction money 1019 and player money 506;
the player-load log independently confirms the money value. See the
[reload screenshot](../../evidence/sprint-0/local-baseline-reloaded.png).
This verifies recovery after a process restart. Normal pause-menu exit was not
verified because the game intercepted injected keyboard/window-close input.
Dedicated campaign creation/save/reload still remain open for S0-1.

## Findings before Infection exists

The unmodified dedicated control was launched with
`Tools/dev/start-baseline-server.ps1`, the six-mod acceptance stack, profile
`InfectionBaseline`, loopback address, and port 2502. At 21:48:21 UTC the server
started `Antistasi_chernarusredux.chernarusredux`; zone initialization completed
at 21:48:37 and background/PATCOM initialization at 21:48:43. Its log confirms
that no extender was loaded. A client still needs to join, create the new
campaign, and demonstrate save/reload before S0-1 can pass.

The first dedicated client connection did not reach the server while the server
was bound explicitly to `127.0.0.1`. Restarting with normal interface selection
while retaining Arma's documented `loopback = 1` local-client restriction made
the server discoverable in the LAN browser. Joining reached the BattlEye license
dialog. Acceptance is pending the owner's decision; no license was accepted by
the developer. A port conflict was considered during diagnosis but was not
established as the cause.

| Finding | Evidence / current interpretation | Follow-up |
| --- | --- | --- |
| Missing population values for several Redux settlements | `fn_getCityData.sqf` reports an error, then explicitly falls back to counting nearby houses. Startup completed. | Compare population names to map data and inspect effects before proposing a separate terrain correction. |
| Sites without vehicle placement markers | `fn_initSpawnPlaces.sqf` reports warnings. Its source explicitly allows locations with no vehicle places. | Sample the actual sites; a warning alone is not a demonstrated placement defect. |
| Missing Redux description localization keys | Baseline RPT reports missing `STR_antistasi_mission_info_chernarus_*` strings. | Track as upstream/map baseline behavior; avoid attributing it to Infection. |
| IMS/WebKnight animation warnings on a dedicated process | Logs report missing animation resources before the class probe starts. | Determine which selected creature behaviors are affected in live tests. |
| Initial class-probe launch loop | The incomplete hand-authored Eden fixture repeatedly loaded without starting. Replacing its mission structure with the documented version-12 format produced a complete run. | Resolved for the diagnostic fixture; no gameplay change required. |
| Large-creature model errors | Corrupted and Smasher variants report missing bones/head-body skeleton mismatches. Goliath additionally reports an invalid `Spine3` attachment point. | Visual and combat inspection required; these classes are not accepted for gameplay yet. |
| Baseline save price warning | `fn_vehiclePrice` reports an invalid price for `A3AP_Box_Syndicate_Ammo_F` and falls back to 1000. Persistent saving completes afterward. | Retain as an unmodified Ultimate baseline finding; check restored state before judging its impact. |

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

The repeated dedicated prepared-class probe completed at 00:16:09 UTC on
13 November with the strengthened corpse-inclusive entity query. All 14 candidates
existed, spawned as WEST, remained alive and server-local, initialized through
their prepared-class handlers, and carried no primary/secondary/handgun weapon.
Each left zero additional live or dead entities in the three-second post-deletion snapshot;
the remaining group count was one throughout. Smasher's initialization marker
was numeric zero, confirming the source finding. The run had no SQF expression
errors, but the model errors above prevent an overall clean acceptance.

[prepared-class-smoke.json](../../evidence/sprint-0/prepared-class-smoke.json)
records the exact runtime settings, class inheritance, skeletons, animations,
locality, cleanup observations, source-log hash, and fixture hashes. The collector
returns `needs_review` for this run. It also correctly rejects the earlier
non-starting RPT as `incomplete`. Neither result establishes combat, civilian
targeting, waypoint compliance, vehicle interactions, JIP, or delayed cleanup.

Gate 0 remains open. Local startup, saving and process-restart reload, dedicated
mission initialization, source matching and prepared-class smoke checks are
evidenced. Dedicated campaign creation/save/reload, per-class combat behavior, and the
complete reviewed Occupant impact matrix are not yet accepted.
