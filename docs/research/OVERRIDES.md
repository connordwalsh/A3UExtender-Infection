# Version-pinned override ledger

Baseline: Ultimate 12.4.2, source commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. Paths below are relative to
`A3A/addons/core/functions/`. This ledger records implemented overrides, not all
the proposed routes in the impact matrix.

| Ultimate entry point | Infection behavior | Original behavior retained | Evidence / remaining limits |
| --- | --- | --- | --- |
| `Garrison/fn_createGarrisonLine.sqf` | For the selected Infection WEST faction with available dependencies, return `["", [], footGroup]`; empty-only preferences stay `["", [], []]`. Select existing tier groups without vehicle or crew queries. | An alias loads the installed original file directly. All other sides, normal Occupants and the unavailable-dependency case call that alias with unchanged arguments. Shared preference tables are not modified. | `evidence/sprint-1/combat-contract.json`: all 25 upstream preference rows at deterministic/weighted war tiers, a verified zero vehicle-query count, normal WEST/EAST controls, invalid inputs, and initial-roster/ratio consumers. The older selector assertion is corrected in `VALIDATION_CORRECTIONS.md`. Full capture/reload/site integration is still open. |
| `CREATE/fn_NATOinit.sqf` | For registered prepared basic infected only, install metadata and once-only combat bookkeeping while preserving WebKnight health/AI/identity. | A direct installed-file alias receives unchanged arguments for normal factions, other sides, unrelated units and missing dependencies. No shared human damage/death function is overwritten. | `evidence/sprint-1/combat-contract.json`: initialization, inactive-site behavior, observer damage return, rifle kills, resources, garrison records, postmortem and cleanup. Endpoint recording is isolated from the gameplay addon. Player credit, ACE, HC transfer and JIP remain unaccepted. |

The inspected original file's SHA-256 is
`0994fb748a6b43429a782e52e8842aa1333cb6ae5b21c52b8269f2bb13a05017`.
Review both the upstream file and its callers when updating Ultimate. The
override does not replace site creators, `updateGarrison`, live reinforcement,
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
