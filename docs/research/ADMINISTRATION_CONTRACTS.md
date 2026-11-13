# Administration stronghold source contracts

Research baseline: Ultimate 12.4.2, commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. This records verified source behavior
and implementation requirements. The separate [implementation record](ADMINISTRATIONS.md)
describes the resulting code and its acceptance boundaries.

The owner requires clearing the infected before capture, including after the
building is destroyed. Survivor rescues give separate benefits. The decisions
are recorded in [PRODUCT_DECISIONS.md](../planning/PRODUCT_DECISIONS.md).

## Native lifecycle

`createAIMilAdmin` finds a registered building within 30 meters, rejects a
destroyed building and a town skirmish, then creates two patrollers, a randomized
indoor garrison and a human collaborator. The inclusive garrison loop creates
one more soldier than its random counter. A parked car, captive unarmed Rebels
and an equipment crate are separate branches. Killing the collaborator completes
capture; destroying the building also completes it. Distance cleanup removes
the defenders and leaves moved loot to the vehicle despawner.

Infection must replace the collaborator objective and conventional vehicle
branch. Selected defender roles must pass through the shared budget and checked
placement. Empty capacity, failed placement or interrupted spawning must leave
the full waiting roster intact and cannot count as cleared defenders. The
destroyed-building rejection cannot be retained for an uncleared stronghold.

## Other completion paths

`SCRT_fnc_location_removeMilAdmin` is also called by the building's Killed event,
nearby town allegiance changes, nearby captured bases and save loading. The
creator alone is therefore not a sufficient capture guard.

The native removal function records the building in
`A3A_destroyedMilAdministrations`, changes the marker to the Rebel side and
publishes the result. Capture changes nearby support by `[-25,25]`. Destruction
also adds Occupant aggression and may request conventional support and a police
attack force. Those response paths cannot run against Infection's empty vehicle
pools. `LOADSTAT` and `SILENT` create a ruin and hide the original building.
The save loop records completed administrations by building position.

The native building Killed handler separately adds the marker to `destroyedSites`.
That flag must not be mistaken for completed Infection clearing. The distance
manager continues to dispatch the administration creator according to marker
ownership. Nearby town/base changes must also respect the clearing requirement;
loading an already-completed administration must remain possible.

## Survivors and positions

The native position helper supplies explicit cell, crate and guard indices for
supported buildings. Indices must be checked against the actual returned
building positions. Its default branch operates on an uninitialized array and
includes an out-of-range index; `Land_zachytka_nov`, listed by `initZones`, has no
explicit case. Do not use that fallback without validation or repair. Reusing a
cell index can also overlap captives, so survivor placement needs unique checked
positions and bounded failure handling.

Native captives use the Rebel unarmed role, are captive, and have movement and
targeting disabled. Their action calls `liberateFlee`, which releases them,
initializes Rebel bookkeeping, directs them toward HQ and eventually grants one
HR. This is a separate reward from capture. The native action has no once-only
claim guard and does not recheck survival after its final 30-second wait;
Infection's action must validate and own its transaction rather than allow
duplicate rewards or reward a subsequently dead survivor. Locality and JIP
action visibility require connected-client acceptance.

The native prisoner cooldown stores mission time plus one hour. Its treatment
across session restart needs review with the save/load adapter; source inspection
does not establish persistence correctness. Rescued actors must be excluded from
site cleanup, and rescue failure must not change the clearing objective.

## Pinned source hashes

| Ultimate source | SHA-256 |
| --- | --- |
| `core/functions/CREATE/fn_createAIMilAdmin.sqf` | `d6a27ece318f033d44e948a52266698fb4112e59f3a0a6ad0c3d3c893224ebe8` |
| `scrt/Location/fn_location_removeMilAdmin.sqf` | `c7ab2cff1019470cee047257d06972127ae13b973142406a0848719c19a415b6` |
| `scrt/Common/fn_common_getMilAdminGarrisonPositions.sqf` | `747b0ff74f5072822782ad9c0cc2320f37d46c737d2dd3a56294c92aa6f5c040` |
| `core/functions/AI/fn_liberateFlee.sqf` | `fe3fe9d017424af9858a148b2c73c8bb77d23b0ba253c51603fa3aacc4dbf5b1` |
| `core/functions/Missions/fn_CON_MilAdmin.sqf` | `6c1dfe0f0229c21d580f0ab219c5739bb470732c928eb34bea3dc5446b5ba2a2` |

`CON_MilAdmin` waits for Rebel ownership rather than inspecting the collaborator.
Its completion can therefore follow a corrected site transaction, but its human
collaborator wording and reward/failure paths still need mission integration.
Redux building geometry, live rescue interactions, saved progress and full
campaign response behavior remain untested.
