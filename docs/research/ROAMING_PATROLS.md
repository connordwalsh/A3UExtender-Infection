# Infected roaming patrols

Baseline: Ultimate 12.4.2, source commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. This increment replaces the remaining
vehicle-dependent patrol request at the end of the routine reinforcement cycle.

## Source contract and adapter

The resource cycle requests roughly three patrols per player-scale hour, subject
to its random trigger and shared `AAFpatrols` count. `AAFroadPatrol` selects owned
seaports, airports, outposts or military bases within 2 km of actual players.
Its chosen faction then supplies a boat, car, armor or aircraft. Empty infected
vehicle lists cannot safely serve this request.

The mixed adapter retains the native ordinary-faction vehicle selection and
controller. Its base predicate preserves ordinary seaport boat availability and
navigation checks. Only infected selection uses the new source predicate and
foot controller. Missing dependencies and other Occupant templates delegate to
the installed original. No client or headless machine owns infected creation.

## Infected policy

A source must still be owned, unloaded, have saved defenders, respect Ultimate's
source idle lock, and avoid forced spawning or recent combat. One patrol per source and a
600-second source cooldown prevent repeated calls from creating parallel patrols.
The shared native patrol ceiling is committed atomically. Infected seaports can
provide a land patrol; no boat or crew is selected.

A small tiered group, limited to four basic infected, travels between its source
and one nearby owned location. Source and destination have checked outdoor
points; the native road graph must connect them. Navigation uses those outdoor
endpoints without redirecting to a vehicle spawn marker. The route stays within
the smaller of the configured land-attack radius and 2 km, excludes controls, checks
at most twelve candidate destinations and refuses a route when none qualifies.
It does not substitute an unchecked center or prove the whole walking route.

The existing shared budget controls real actors and partial arrivals. A spawn
queue expires after 120 seconds; a patrol ends after 30 minutes, ownership loss,
defeat or a 60-second absence of observers from its area. Surviving actors are
ordered back where possible and cleanup waits until observers leave. Interrupted
controllers are recovered from their context bindings, including actors not yet
registered in the controller. The shared patrol counter is released exactly once
after cleanup. Native legacy death costs remain; healthy deletion does not refund
resources that were never prepaid. Patrols do not alter saved garrisons.

## Validation boundary

All 377 combined dedicated checks and 11 dependency-absent checks pass, including
37 roaming cases. The fixture uses real actors, budget and death
accounting with a synthetic two-node road graph in VR. AI objects exercise the
read-only player-area selector; this does not certify connected-player behavior.
Actual movement is checked separately from route and lifecycle predicates.
Full walking circuits, Redux geometry, player-visible cleanup, Invader campaign
behavior, restart persistence and performance remain acceptance work.

The first focused run was rejected. It exposed a route helper returning the
placement predicate's reason string instead of the validated position, causing
invalid waypoints. The helper now returns the position. The isolated fixture
also explicitly initializes Ultimate's tier-selection setting; its omission
caused undefined-variable errors even though the full suite sets that value.
Neither the failed route checks nor the run's other results are acceptance.
The corrected 47-check focused run passed. Review then removed the native marker
helper's vehicle-spawn redirect from infected route planning and added an explicit
missing-vehicle-spawn case. The final combined run includes that correction and
the complete previous regression suite. It reports no engine/SQF Error records
and preserves 47 startup/deletion warnings. Its PBO and all 73 addon source files
match the build manifest in `evidence/sprint-3/`.

## Pinned originals

| Core source | SHA-256 |
| --- | --- |
| `CREATE/fn_AAFroadPatrol.sqf` | `7a13758c54070ad1d9689131efb382e5f3397f44a21b18802d83aa115a13b839` |
| `Base/fn_patrolDestinations.sqf` | `66f52b1314bd3815fb0cd80e74fd1a7e68e0eb1332d050817fe33cb350b37966` |
