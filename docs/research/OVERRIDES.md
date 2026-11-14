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

Together with the control, town and administration increments below, these routes
still leave reinforcement/repair, mission generators and capture-triggered counterattacks.
The old vehicle-pool assumptions in those paths remain release blockers.

## Road/field control routing increment

`CREATE/fn_createAIcontrols.sqf` now has a narrow Infection-only adapter using
budgeted foot groups, transient patrol accounting and local contender capture.
The scheduler's server-only set includes this fifth creator. The installed original
remains the alias for normal factions and missing dependencies. Its pinned hash is
`584ee253e61f567af3c2bcd154797ecf12a1f7f3fe767518992b38c74482e66a`.
See [control behavior and validation boundaries](ROAD_CONTROLS.md).

## Town patrol routing increment

`CREATE/fn_createAICities.sqf` has an Infection-only per-visit adapter. The latest
owner-approved policy uses population-based logistic totals of 10-200 and full-town
activation, including skirmishes and conflicting base ownership. Frontline/ruined
status selects basic roles without changing the count; all remain WEST. Native support/ownership and
civilian systems are retained. The scheduler's server-only set includes this
sixth creator. The original source SHA-256 is
`146b4d1a7d3db93656739c38409f4bce80235e2141411d76b8978100ad801e2f`.
See [town behavior and validation boundaries](TOWN_INFESTATIONS.md); earlier
small-patrol evidence is retained in [TOWN_PATROLS.md](TOWN_PATROLS.md).

## Administration stronghold increment

`CREATE/fn_createAIMilAdmin.sqf` routes infected sites to a server-owned transient
stronghold with full queued defenders and optional captives. The scheduler's
server-only set now includes this seventh creator. In the separate `scrt` addon,
`Location/fn_location_removeMilAdmin.sqf` guards capture/destruction/nearby-change
entry points and retains server loading of completed sites. `A3A_scrt` is an
explicit addon dependency so the override loads in order. Both installed-file
aliases still handle ordinary factions. Successful clearing calls the original
capture transaction rather than copying the completed-building/save registry.

Source hashes and caller contracts are in [ADMINISTRATION_CONTRACTS.md](ADMINISTRATION_CONTRACTS.md).
[ADMINISTRATIONS.md](ADMINISTRATIONS.md) records the 301-check validation and
remaining client, mission, response and save gates.

## Routine reinforcement increment

`CREATE/fn_patrolReinf.sqf` routes only infected requests to a paid foot/virtual
repair transaction. Its scheduler route stays on the server. The mixed
`CREATE/fn_reinforcementsAI.sqf` retains the pinned native Invader, kill-zone and
maintenance logic; only the infected side dispatches the new selector. Installed
aliases handle inactive dependencies/templates and ordinary patrol requests.
The remaining road-patrol call uses the separate adapter described below.

Source hashes, source-selection differences, costs, cooldowns, roster transfer
and the 340-check evidence are recorded in [REINFORCEMENTS.md](REINFORCEMENTS.md).

## Roaming patrol increment

`CREATE/fn_AAFroadPatrol.sqf` now dispatches selected infected sources to a
bounded foot controller. The common source selector retains the ordinary
seaport boat/navigation rules; the remaining ordinary-faction patrol body
matches the pinned original. Inactive templates/dependencies use its installed
alias. Infection route nodes use actual outdoor endpoints rather than native
vehicle spawn-marker redirects. The original SHA-256 is
`7a13758c54070ad1d9689131efb382e5f3397f44a21b18802d83aa115a13b839`.

[ROAMING_PATROLS.md](ROAMING_PATROLS.md) records policy, the corrected initial
failure, 377-check validation and remaining terrain/player gates. The response
caller/payment audit is in [RESPONSE_CONTRACTS.md](RESPONSE_CONTRACTS.md).

## Capture counterattack increment

`CREATE/fn_singleAttack.sqf` routes the active infected side to paid, bounded
foot forces. Its scheduler route stays on the server; ordinary or inactive
requests retain the installed alias. The original SHA-256 is
`4307b88c3385da599c745e8fba23671642f7721fe12554a0745a610fb221beda`.

The adapter activates defending garrisons through the native spawner flag and
waits for their saved roster before requesting capture. Successful active-site
handoff can start an actor-only Infection controller without duplicating assets
owned by the previous creator. Offscreen arrivals use an atomic roster handoff.
[CAPTURE_COUNTERATTACKS.md](CAPTURE_COUNTERATTACKS.md) records costs, limits,
source contracts and validation boundaries; tactical/major responses remain open.
