# Version-pinned override ledger

Baseline: Ultimate 12.4.1, source commit
`ea8bcf9f05d6b0d4642179db845d7d3425ceab0d`. Paths below are relative to
`A3A/addons/core/functions/`. This ledger records implemented overrides, not all
the proposed routes in the impact matrix.

| Ultimate entry point | Infection behavior | Original behavior retained | Evidence / remaining limits |
| --- | --- | --- | --- |
| `Garrison/fn_createGarrisonLine.sqf` | For the selected Infection WEST faction with available dependencies, return `["", [], footGroup]`; empty-only preferences stay `["", [], []]`. Select existing tier groups without vehicle or crew queries. | An alias loads the installed original file directly. All other sides, normal Occupants and the unavailable-dependency case call that alias with unchanged arguments. Shared preference tables are not modified. | `evidence/sprint-1/garrison-contract.json`: all 25 upstream preference rows at deterministic/weighted war tiers, zero vehicle-selector calls, normal WEST/EAST controls, invalid inputs, and initial-roster/ratio consumers. Full capture/reload/site integration is still open. |

The inspected original file's SHA-256 is
`0994fb748a6b43429a782e52e8842aa1333cb6ae5b21c52b8269f2bb13a05017`.
Review both the upstream file and its callers when updating Ultimate. The
override does not replace site creators, `updateGarrison`, live reinforcement,
marker ownership transactions, or persistent save handling.

Foot lines preserve the three-field format and original preference row count,
including empty vehicle-only positions, so requested/available rows retain their
indices. Existing war-tier selection remains in use. This operation creates a
virtual roster; live spawn budgeting remains a separate requirement.
