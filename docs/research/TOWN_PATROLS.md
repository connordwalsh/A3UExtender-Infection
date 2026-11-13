# Infected town patrols

Baseline: Ultimate 12.4.2, source
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. The owner explicitly chose to preserve
Ultimate's per-visit town patrol regeneration on 13 November 2026.

## Selection and lifecycle

The guarded `createAICities` adapter and scheduler route infected WEST towns to
the server. Ordinary factions and missing dependencies use an alias of the
installed original. Towns share the transient patrol controller with road/field
controls, but retain their own selection and ownership rules.

Selection follows the native marker-size and town-support scaling, with at least
one patrol. Normal towns use police pairs; frontline towns double the patrol
count and select the existing tiered small groups. Ruined towns keep their
unscaled special-forces role groups. These roles resolve to approved basic
infected. Unlike the native ruined-town branch, their runtime side stays WEST,
as required for the infected Occupant faction.

Conflicting main-marker ownership prevents the town patrol. The native town
skirmish and optional nonhuman-civilian skip conditions remain, including paired
City spawn/despawn events for skipped visits. Missing town data rejects the
request without guessing population or support values.

Every selected role belongs to the visit's transient queue. The shared spawn
budget, placement safety, batch pacing, simulation-state handling, duplicate
suppression and interrupted-script cleanup apply. Police/frontline pairs arrive
in batches of two; larger ruined-town groups arrive in batches of at most four.
No active limit truncates the selected total. External ownership changes cancel
waiting arrivals while existing actors remain until normal distance cleanup.

Units use legacy resource accounting and an empty garrison-bookkeeping marker.
Town patrol deaths do not write a persistent garrison; revisiting generates a new
patrol using the current town state. The existing combat support/aggression
callbacks remain in effect. Town ownership continues through Ultimate's support
and ownership systems: town patrols do not use the control-point capture
transaction or the persistent-site queued-defender flag guard.

The town adapter does not create or remove civilians, traffic, dogs, vehicles,
flags or crates. It does not modify town-data or civilian-template values.

## Bounded roaming

Each group gets up to four outdoor MOVE points inside its town marker and at
most 150 meters from the center. The search prefers nearby roads, then samples
the surrounding ground, with at most 24 attempts. Existing ground, slope,
geometry and HQ-exclusion checks validate the points; observer visibility and
distance restrictions apply to spawning, not to an already-visible patrol's
movement targets.

A CYCLE waypoint at the first route point loops routes with multiple points.
The [engine's waypoint contract](https://community.bistudio.com/wiki/Waypoints)
selects the nearest other waypoint, so the cycle is placed on the intended first
point rather than the group's spawn position. The route does not change combat
mode, stance, weapons or WebKnight handlers. Repeated route setup is idempotent.
If no checked target is available, no unchecked center fallback is inserted;
the controller retries the bounded search after 30 seconds. A single valid point
provides a safe destination without inventing a second one.

These target filters do not prove that Arma can navigate every Redux street,
bridge, ruin or courtyard. Terrain pathing and actual repeated patrol circuits
remain acceptance work.

## Validation boundary

The [dedicated report](../../evidence/sprint-2/town-contract.json) passes all 264
combined checks, including 31 town cases. It exercises source-derived counts, source/dependency
delegation, skip events, real budgeted actors, waypoint bounds, actual movement,
legacy costs, per-visit regeneration, ownership cancellation, civilian preservation,
ruined-town WEST identity and cleanup. Support/UI and original-route endpoints
remain recording callbacks; unchanged town data in this fixture does not mean
the production support callback has no effect.

The [dependency-absent report](../../evidence/sprint-2/town-dependencies-absent.json)
passes 11 checks. The [build manifest](../../evidence/sprint-2/town-build.json)
matches the tested package and all 43 addon source files. Both runs contain no
engine/SQF Error records. The main report retains 32 startup/animation/final-function
and object-not-found warnings. The fixture finishes with no extra actors, groups,
reservations, site records or watchdog handler. Completed servers were stopped.
Terrain acceptance, campaign save/reload, connected-client and sprint gates remain
open; this report does not establish repeated patrol circuits or Redux navigation.

The first run exposed a shared-budget defect: raising the server context limit
could leave a town constrained by an older ticket's cached limit. Tickets now
retain their caller's ceiling, with two additional budget regressions. Failed
route searches also retain their own 30-second retry deadline. The next engine
run reported all 264 assertions passing, but an oversized diagnostic line was
truncated by the engine, so the strict collector correctly rejected that run.
Neither run is accepted evidence. A final run with corrected observations and
short diagnostics passes the strict collector.

Site fixture review also corrected two observation boundaries. Object deletion
becomes visible on the next engine frame, so cleanup waits for both controller
removal and a null flag ([deleteVehicle](https://community.bistudio.com/wiki/deleteVehicle)).
Approach movement is measured on the living leader before the casualty test;
the earlier follower could be regrouping with its distant leader, as confirmed
by the engine's formation-planning destination. This does not establish terrain
navigation or post-casualty group behavior in a campaign.
