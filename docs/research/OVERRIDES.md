# Version-pinned override ledger

Baseline: Ultimate 12.4.2, source commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. Paths below are relative to
`A3A/addons/core/functions/`. This ledger records implemented overrides, not all
the proposed routes in the impact matrix.

| Ultimate entry point | Infection behavior | Original behavior retained | Evidence / remaining limits |
| --- | --- | --- | --- |
| `Garrison/fn_createGarrisonLine.sqf` | For the selected Infection WEST faction with available dependencies, return `["", [], footGroup]`; empty-only preferences stay `["", [], []]`. Select existing tier groups without vehicle or crew queries. | An alias loads the installed original file directly. All other sides, normal Occupants and the unavailable-dependency case call that alias with unchanged arguments. Shared preference tables are not modified. | `evidence/sprint-1/combat-contract.json`: all 25 upstream preference rows at deterministic/weighted war tiers, a verified zero vehicle-query count, normal WEST/EAST controls, invalid inputs, and initial-roster/ratio consumers. The older selector assertion is corrected in `VALIDATION_CORRECTIONS.md`. Full capture/reload/site integration is still open. |
| `CREATE/fn_NATOinit.sqf` | For registered prepared basic infected only, install metadata and once-only combat bookkeeping while preserving WebKnight health/AI/identity. | A direct installed-file alias receives unchanged arguments for normal factions, other sides, unrelated units and missing dependencies. No shared human damage/death function is overwritten. | `evidence/sprint-1/combat-contract.json`: initialization, inactive-site behavior, observer damage return, rifle kills, resources, garrison records, postmortem and cleanup. Endpoint recording is isolated from the gameplay addon. Player credit, ACE, HC transfer and JIP remain unaccepted. |

The garrison-line original file's SHA-256 is
`0994fb748a6b43429a782e52e8842aa1333cb6ae5b21c52b8269f2bb13a05017`.
Review both the upstream file and its callers when updating Ultimate. The
garrison-line override does not replace site creators, `updateGarrison`, live reinforcement,
marker ownership transactions, or persistent save handling.

Foot lines preserve the three-field format and original preference row count,
including empty vehicle-only positions, so requested/available rows retain their
indices. Existing war-tier selection remains in use. This operation creates a
virtual roster; live spawn budgeting remains a separate requirement.

The combat adapter follows these unchanged 12.4.1/12.4.2 sources (SHA-256):

| Source | Hash |
| --- | --- |
| `CREATE/fn_NATOinit.sqf` | `43e397a01cffd2b7e547101f7455f2547b529ff4b87f43aa1a4e1c247b87a9dc` |
| `EventHandler/fn_enemyUnitKilledEH.sqf` | `4d48158549f4432ed96d6471bc67596a9486e751156c6017443e9b5b5bcf7682` |
| `EventHandler/fn_enemyUnitDeletedEH.sqf` | `facf82adcda4fbc556316e758070349c1400330fd06225287ab8fbd415f973a3` |
| `Revive/fn_handleDamageAAF.sqf` | `4c82080fd775663d75ff8e67055166c0b314eadab0e2dcc493ed6dc1a19d145a` |

Adapted bookkeeping retains the upstream notices in
`Infection/THIRD_PARTY_LICENSES.txt`, included in the built mod directory.
See [combat contracts and limitations](COMBAT.md).

## Persistent-site routing increment

All aliases below load the installed Ultimate 12.4.2 file directly. Ordinary
Occupants, Invaders and the missing-dependency case retain their original routes.
The [site implementation](SITE_SPAWNING.md) records the remaining campaign gates.

| Entry point | Narrow Infection change |
| --- | --- |
| `CREATE/fn_createAIResources.sqf` | Resource/factory controllers use the full queued roster and safe budgeted foot spawning; preserve flags and the resource-worker callback. |
| `CREATE/fn_createAIOutposts.sqf` | Outpost/seaport controllers preserve flags/crates and replace combat vehicle/static/patrol branches with queued foot defenders. |
| `CREATE/fn_createAIMilbase.sqf` | Military bases use the shared controller, flag and two native crate creators. |
| `CREATE/fn_createAIAirplane.sqf` | Airports use the shared controller, flag and crate, without infected aircraft or crews. |
| `Base/fn_scheduler.sqf` | These four entry points run on the server when the marker is Infection-owned; unrelated functions and arguments delegate untouched. |
| `Base/fn_mrkWIN.sqf` | Deny a flag attempt while an active site's queued defenders remain; otherwise delegate before any ordinary action/reward code. |
| `Base/fn_markerChange.sqf` | Apply the queued-defender guard on the authoritative ownership-change path; the existing ownership transaction remains upstream. |
| `AI/fn_surrenderAction.sqf` | Registered prepared infected keep their AI instead of receiving human surrender commands. All other actors delegate. |

| Original source | SHA-256 |
| --- | --- |
| `Base/fn_scheduler.sqf` | `8daab3180fa8a1d6e6cc2c438e8e86f074ed77fd0d10d570da75480cc3c663c5` |
| `Base/fn_markerChange.sqf` | `4b283a4359190453daa5179c07616869a7e161cfd0c56a853278d3bbc2e25f5a` |
| `Base/fn_mrkWIN.sqf` | `47c08fea41f09a21f3e6fcb0050983b4fc579715877ed6e1b3e7bff62995c7c3` |
| `AI/fn_surrenderAction.sqf` | `62cfc41490be6bb351da45869315386bc8933c5e121288cbd2d4b194a2da734e` |
| `CREATE/fn_createAIResources.sqf` | `0c3f70883fbc744ed64a832121f5e3d63d9050b9ee540518ae6d820fb91f67f0` |
| `CREATE/fn_createAIOutposts.sqf` | `f3692aea5f9aca3ab207091b2299ad531ba6b7e9737e9da5d127da9adca01a64` |
| `CREATE/fn_createAIMilbase.sqf` | `030fc5683d3eb1e3b685e589270a8eecd3318ba42801c9fdb5dbfa5ea20d084a` |
| `CREATE/fn_createAIAirplane.sqf` | `4708a51c0b8bf1392fc8aa86d0de6f749cc993401a642bf066a4ed1548d157fe` |

These routes do not yet replace cities, road controls, military administrations,
reinforcement/repair, mission generators or capture-triggered counterattacks.
The old vehicle-pool assumptions in those paths remain release blockers.
