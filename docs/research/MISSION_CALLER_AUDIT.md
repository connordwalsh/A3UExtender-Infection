# Native mission caller audit

Baseline: Ultimate 12.4.2, commit `c7c8247672ed5e7d4aa317d47efb371c41de4e7d`.
Infection baseline: merge `2f7042fe8be8ac5eade9d8e02023bf2232257dd6`.

The reproducible inventory is `Tools/dev/audit-mission-callers.py`; its result is
[evidence/sprint-4/mission-caller-audit-12.4.2.json](../../evidence/sprint-4/mission-caller-audit-12.4.2.json).
It classifies all 42 functions in native `core/functions/Missions`, finds exact
function-name and FUNC/FUNCMAIN references across 2,979 SQF/HPP/CPP/EXT files,
and records source hashes, reference lines, override paths and registration.
There are no unclassified endpoints or missing required override registrations.
This is a source inventory and reviewed route disposition, not a runtime call
graph: comments/self references are included, generated function names are not
resolved, and scripts from unrelated external addons are outside the scan.

## Reviewed routes

| Native route | Infection disposition | Source finding |
| --- | --- | --- |
| Six AS endpoints plus RIV_AS_Traitor | Elimination | Each guarded endpoint calls dispatchElimination; the six-category request adapter bypasses native random human-target selection. |
| Four CON endpoints | Liquidation | Each guarded endpoint calls dispatchLiquidation. Mutual native Outpost/Compet fallback cannot reintroduce the race variant while Infection is active. CON_Outpost_Zombies has no exact caller in this scan, but remains guarded. |
| Six LOG endpoints | Supplies Seizure | Guarded dispatchSupplySeizure replaces the native aircraft, bank and naval scenes. |
| Five RES endpoints plus RIV_RES_Prisoners | Extraction | Guarded dispatchExtraction. Civilian dialog selects extractionTargets and requestCivilianExtraction instead of the native list. |
| SUPP_Supplies and RIV_SUPP_Salvage | Humanitarian Aid | Both dispatchHumanitarianAid. The dynamic map hover menu also calls SUPP_Supplies through the scheduler, so it reaches the same adapter. The native menu label/availability still needs connected-player review. |
| CONVOY | Interception; Invader supply attacks remain background activity | Three native callers: missionRequest, selectIntel, chooseAttack. Infection overrides all three. The convoy endpoint independently separates Invader Supplies/attack from other requests. |
| Four DES endpoints | Disabled | Endpoint guards stop direct calls as well as catalog selection. The native DES_Heli recursive call cannot create a disabled task. |
| Random category | Disabled | missionRequest rejects RAN/default automatic requests. resourcecheck's no-argument request reaches that guard. The apparent loadStat replay call is commented out. |
| REP_Antenna | Disabled infected repair | resourcecheck/scheduler and endpoint guards retain the destroyed tower. Player-funded rebuildAssets is separate. |
| ENC_Trader | Unlock without introduction | Native prepareTraderQuest retains progression/intel timing and disabled-trader checks; scheduler routes the adapter to the server. |
| RIV_ENC_Rivals | Retained introduction, adapted narrative | Native prepareQuest remains the trigger. Existing narrative adaptation does not author a faction. |
| RIV_ATT_Cell/Hideout/Transfer | Retained native gang attacks | Three player UI dispatches and Transfer-to-Hideout fallback remain native, including approved staged casualties. |
| underAttack | Retained site defense alert | Called by native convoy movement and damage handlers. Infection's infectedDamageObserved also calls it. It is not a requested catalog mission. |
| findIfNearAndHostile, taskDelete, taskSetState, taskUpdate | Shared native utilities | Retained by replacement controllers and unrelated native systems; reference count is not a count of new mission sources. |

All replacement endpoint wrappers retain their non-Infection native aliases.
Server routing in scheduler covers the replacement mission families. Direct
legacy dispatcher calls validate Infection activation, server/HC origin and
eligible infected targets in their controllers. This inspection establishes
which policy each endpoint enters; it does not prove every remote execution,
locality transition, target selection or cleanup path.

## Remaining acceptance

The native Extraction and Elimination/Supplies success evidence remains in its
separate research reports. This audit does not replace native tests for other
missions, UI clarity, player requests, multiplayer/JIP, save restoration,
background Invader activity or the retained gang storyline. Encounter scripts
outside core Missions, dynamically built names and full Occupant vehicle/support
caller coverage remain part of S0-3/S3-3. No production changes, faction work,
Computer Use or new gameplay test occurred in this audit.
