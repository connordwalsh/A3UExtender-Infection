# Routine infected reinforcements

Implementation baseline: Ultimate 12.4.2, source commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. This is the S3-2 routine repair
increment, separate from initial queued garrisons, QRFs, major attacks and mission
convoys. The owner permits replacement infected to approach while players remain
nearby, subject to cooldown and combat checks.

## Source contracts

Ultimate calls `reinforcementsAI` from its 600-second resource cycle. It prioritizes
sites by the missing proportion of their native garrison size, selects four/eight
roles, and uses `4 * round(0.1 * defenceResources / 40)` as its cycle quota.
Forced spawns and more than 50 recent damage-resource points within 300 meters
exclude a target. Offscreen sites receive virtual roles; nearby sites use
`patrolReinf`, whose trucks, aircraft and carrier paths cannot serve Infection.

Native land-source selection also depends on vehicle spawn places, even in its
cached path helper. Infection instead checks actual road-graph connectivity and
base ownership directly. The unchanged native road graph only establishes a
possible connected land route; it does not demonstrate infected walking behavior
on Redux. Native `enemyGarrison` and positive `garrisonUpdate` calls cannot simply
be reused: the former owns independent despawn scripts and the latter does not
register arrivals with Infection's active site controller.

## Implemented behavior

Only the Infection side of the mixed reinforcement cycle changes. The remaining
Invader, kill-zone and maintenance lines match the pinned upstream source. The
standalone patrol entry point and scheduler keep infected work on the server;
ordinary factions and absent dependencies use installed-file aliases.

Routine targets retain the native deficit, combat and forced-spawn checks. The
original site's waiting roster must finish spawning first. A target accepts one
routine job at a time and has a 600-second mission-time cooldown, matching the
source resource cadence. Sources are owned, unspawned outposts, bases or airports
with at least 16 saved defenders, no native idle lock, no significant recent
damage, and no observer within 700 meters. Connected routes use the native land
distance allowance without requiring a vehicle position. No carrier is eligible.
Static road distances are cached during scheduled planning. Atomic requests use
that cache and recheck mutable eligibility; they cannot start a cold path search.

An unobserved, unloaded target can receive paid virtual roles. An active target
receives a job that creates basic infected at checked outdoor positions around
the source and orders them toward the destination. The shared budget limits
actual actors, batches and context occupancy. Payment is ten defence resources
per created actor, with a final affordability check at creation; refusals spend
nothing. Waiting births expire after one resource cycle. Travel has a generous
distance-based deadline; its pacing still needs gameplay acceptance.

Arriving groups are added to the saved roster and registered with the active
site in one unscheduled transaction. The budget ticket moves to the site's
context only if its ceiling permits it. This does not free global capacity or
create another copy of an actor. Adopted deaths use normal garrison bookkeeping;
distance cleanup preserves surviving saved entries. A group cannot be adopted
twice. Source/destination loss, expiry and interrupted controllers cancel the
job. Living cancelled actors retreat when possible and wait for observers to
leave before cleanup. Their prepaid cost is refunded by the existing deletion
accounting; dead actors are never refunded.

## Validation boundaries

All 340 combined dedicated checks and 11 dependency-absent checks passed on the
final candidate. Thirty-nine cases cover routine reinforcement; the fixture
uses real actors, resource functions and garrison death bookkeeping, with a small
synthetic road graph in VR. It observes movement separately and injects arrival
positions to isolate handoff/race behavior; such an injection is not route
completion evidence. Initial fixture attempts were rejected because two SQF
array-index operators started a line and were interpreted as preprocessor
directives, producing an empty test body. Explicit fixture-size diagnostics and
the strict expected-check manifest expose this failure.

The first executed fixture also sampled refunds before their queued server
messages arrived. Its corrected checks wait for the resource balance as well as
job cleanup, and inject a later resource shortage atomically. A subsequent
47-check focused run passed. A repeated run diagnosed the intermittent handoff
failure: the injected arrival left one actor approximately 999 meters from the
target while the leader was approximately 20 meters away. The implementation
correctly refused to save unarrived defenders. The revised fixture explicitly
tests partial arrival, then freezes its actors while injecting and verifying a
complete arrival. It re-enables simulation after the handoff checks. This does
not establish real long-distance walking. The final combined run passes both
arrival cases, the complete earlier regression suite and the new cold-route
atomicity check. It reports no engine/SQF Error records and retains 46 startup
and object-deletion warnings for review. Its PBO and all 66 addon sources match
the build manifest in `evidence/sprint-3/`.

The mixed cycle's separate patrol request now uses the
[roaming adapter](ROAMING_PATROLS.md). Capture/destruction QRFs, major attacks,
convoy additions, and other positive
native garrison mutations remain separate S3/S4 integration work. This increment
does not claim all campaign spawns use the budget. Cooldowns currently belong to
the running mission; restart persistence, Redux travel, connected-player observer
cases, Invader campaign behavior and performance remain acceptance gates.

## Pinned originals

| Core source | SHA-256 |
| --- | --- |
| `CREATE/fn_reinforcementsAI.sqf` | `44bb023659afd5848cffe57fdec4cecf7fba1b64005716ba3b0285f443c4f91f` |
| `CREATE/fn_patrolReinf.sqf` | `415927327826fe000a8f4ea0888d6165f3040f4ba01957af0e00c449d2a30627` |
| `CREATE/fn_garrisonUpdate.sqf` | `1860ac1642ee75399939bcef04b742b22a29bc40cab49f7416b8a377acaa600d` |
| `AI/fn_enemyGarrison.sqf` | `db8a74b0b1bb95cc0252b00642ae7e25976866014ad686fc900a0e3dbe0da1c4` |
| `CREATE/fn_availableBasesLand.sqf` | `ac5ae8aa4a777997b8084d59f2f41df4e696e666853c4147e6cf0089cccd7686` |
| `Pathfinding/fn_findLandSupportMarkers.sqf` | `fad3d32fecf151a997b0a5b6dc0762872c90ac8c01f14f4c52e77f7c143674de` |
