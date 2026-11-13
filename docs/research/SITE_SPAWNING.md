# Persistent infected site spawning

This increment connects the spawn budget to resources, factories, outposts,
seaports, military bases and airports. Towns, road controls and military
administrations remain separate work. It does not complete the campaign gate.

## Roster and lifecycle

The owner's 13 November decision preserves the full garrison. Each site queues
a copy of its existing Ultimate roster; it does not shrink that roster to the
active cap. At most four queued entries are requested per batch. Successful
batches are at least 15 seconds apart; capacity or placement refusals retry after
five seconds. Requests share the server budget and site context. Only successfully
created actors leave the queue. Deaths update Ultimate's original saved roster
through the existing Infection combat adapter.

The controller issues a movement waypoint toward the site center. It retains
WebKnight's prepared-class melee AI and health. There are no human vehicle crews,
static weapons, aircraft, boats, dogs or extra human patrols in these routes.
Existing non-Occupant routes delegate to installed Ultimate files unchanged.

Duplicate requests share one server controller. Infected site scheduling bypasses
headless-client selection; this does not certify headless support. Units follow
Ultimate's enabled/disabled/despawn site states. On distance cleanup, living
defenders are deleted without being removed from the saved roster. Reentry uses
that remaining roster. Ownership changes stop unspawned arrivals while existing
actors remain until ordinary distance cleanup; they do not disappear at capture.
Prepared infected bypass the human surrender procedure.

A single server recovery handler checks for stopped controllers every two seconds
and cleans their tickets, partially-created groups, actors and assets. It removes
itself when no site controllers remain. Reentry also reclaims an already-stopped
controller before creating its replacement.

Pending defenders block the flag action and the server ownership-change entry
point at an active infected site. Once all queued entries have appeared, normal
Ultimate capture rules apply. A denied spawn cannot make the queued garrison
count as cleared. This guard is not a replacement for the campaign ownership,
rewards, counterattack or save/reload acceptance tests.

## Placement policy

The common scheduled spawner accepts only registered basic Infection roles. It
reserves capacity before creation, rechecks ownership and placement immediately
before creation, binds each actor, and releases unused slots. A failed bind
deletes the newly created actor. Limit reductions preserve actors already alive
at the instant the change takes effect and prevent spending removed capacity.

Each position search makes at most 16 attempts, each with an eight-meter empty
position search. Results must stay inside the requested annulus and world bounds,
on land with a slope no steeper than 30 degrees, clear of blocking geometry and
nearby actors/vehicles. No map-center or site-center fallback is accepted.

Spawns remain at least 150 meters from player observer objects and 200 meters
from the actual `respawnTeamPlayer` HQ marker. A missing HQ marker rejects the
request. Engine visibility checks reject exposed chest/head positions in every
direction from observers, including known remotely controlled actors and connected
UAVs. These are server-side geometry checks, not proof of every client camera or
third-person viewpoint. Chernarus Redux terrain and real-player observation remain
required tests. A site with no eligible position waits; it does not bypass safety.

The initial development search radius is the site's radius plus 250 meters,
capped at 1,000 meters. Density, arrival times and placement thresholds require
playtesting; they are implementation choices, not measured performance targets.

## Site assets and boundary of the fixture

The installed flag and ammo-box creators remain in use. Resources/factories have
their original flag and resource-worker callback. Outposts/seaports and airports
have one crate; military bases have two. Spawn-place reservations are freed during
cleanup. Unclaimed crates are removed; moved surviving crates go to Ultimate's
vehicle despawner and apply its existing loot cooldown. Existing civilian
selection/default behavior is not changed here.

The isolated fixture uses real registered infected, budget settings, site
controllers, flag/crate objects, spawn-place reservations, movement, combat death,
garrison updates and cleanup. Arsenal filling, logistics actions, worker behavior,
task/support/UI endpoints and original-faction dispatch are recorded callbacks.
It therefore cannot certify playable loot, civilian behavior or the actual
campaign capture/reward transaction.

The [194-check report](../../evidence/sprint-2/site-contract.json) passed on
Ultimate 12.4.2. Its 36 site checks cover all six types, duplicates, later arrivals,
movement, actual death/roster changes, simulation transitions, cleanup/reentry,
moved loot, interrupted controllers, automatic recovery, full-budget refusal,
capture guards and ordinary-route delegation. Seventeen placement/spawn checks
include real geometry/visibility, HQ exclusion, invalid requests and a concurrent
limit reduction. The budget preflight check brings budget coverage to 21 checks.
The existing template/garrison/combat regressions also passed.

The [dependency-absent report](../../evidence/sprint-2/site-dependencies-absent.json)
passed 11 checks. Neither report recorded SQF/engine `Error` lines. Startup warnings
and object-not-found messages from the run are retained for review. The
[build manifest](../../evidence/sprint-2/site-build.json) matches both the tested
PBO and every source file at collection. The fixture left no actors, groups,
reservations, site records or recovery handler behind. Its remote-call check
confirmed that another recurring handler continued running after an attempted
remote invocation of the internal recovery function.

Earlier attempts are not accepted evidence: an invalid-role rejection used an
incorrect loop exit and aborted; a limit-change test initially assumed exactly
one actor had been created before the asynchronous change; and a stopped-script
test restarted before Arma reported the old script done. The final checks use
observed state at the change/stop boundary. Automatic stopped-controller cleanup
was added during review and exercised independently of reentry.

Still open: towns/road controls/military administrations, added garrison and
reinforcement routes, response/mission routing, Redux approach/reentry and terrain
pathing, actual flag interaction and ownership transaction, save/reload, connected
players, camera visibility, headless/JIP and the performance soak. Native routes
outside this increment can still violate the intended all-Infection budget.
