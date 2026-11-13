# Infected road and field controls

Source baseline: Ultimate 12.4.2 at
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`.
This increment adapts `CREATE/fn_createAIcontrols.sqf`; it does not adapt town
patrols, military administrations, mission forces or attack responses.

## Selection and spawning

The guarded entry point and scheduler keep Infection-owned controls on the
server. Ordinary Occupants, Invaders and missing dependencies delegate to an
alias of the installed original file with unchanged arguments.

Road classification uses the actual marker position. The road spawn chance is
the greater of Occupant aggression and Ultimate's configured base chance.
Frontline roads use the original militia group plus two former static crew roles,
all on foot. Other roads retain the upstream police-versus-military weights;
police use their officer group plus an officer, and military use their tiered
fireteam plus a crew role. No vehicle pool is queried. Field controls use the
original nearby-Rebel-marker frontier rule, special-forces group roles at the
frontier, and the existing war/aggression chance for a tiered patrol pair elsewhere.
All these role names resolve to the three registered basic infected classes;
they do not enable large creatures.

The selected per-visit roster uses the shared global/context budget and bounded
safe-placement checks. Each successful batch contains at most four actors;
later successful batches are separated by at least 15 seconds. Capacity and
placement refusals keep the waiting roles and retry after five seconds. One
controller owns each location and the watchdog reclaims interrupted work.
Groups approach the control center using ordinary movement waypoints. Broader
roaming patrol behavior and Redux navigation acceptance remain open.

Controls remain transient, matching Ultimate: they do not read, consume or write
a saved garrison. Their units use `legacy` resource accounting and an empty
bookkeeping marker, while the actual location marker still guards ownership and
activation during spawning. Living cleanup costs nothing; a death debits ten
legacy resources through the existing infected combat adapter. Reentry creates
a new patrol. The owner separately approved the same per-visit regeneration
policy for town patrols, which are not implemented by this control increment.

No control creates infected vehicles, static weapons, UAVs, dogs, flags, crates,
bunkers or minefields. Abandoned drivable vehicles remain a separate backlog item.

## Capture and lifecycle

An empty selection or a blocked spawn cannot award a control. Capture requires:

- At least one actual defender was created and no selected roles remain queued.
- No fighting defender remains in Ultimate's capture radius.
- No fighting defender is still approaching without having entered that radius.
- A non-captive Rebel or Invader who can conquer is inside the capture radius.

Among eligible contenders, the nearest unit wins. The server transaction changes
only control ownership, emits the native roadblock notifications for roads, and
applies the existing support penalty for an Invader capture. It does not invoke
the main-site flag/reward/QRF transaction. Repeated calls cannot award it again.
Defenders that entered and then left the radius retain Ultimate's ordinary
area-control semantics. Simulation follows the distance spawner's 0/1 states;
state 2 performs cleanup. An external ownership change cancels waiting arrivals
without making visible living actors disappear.

Static controls retain their captured ownership. Generated controls retain the
native reset after 120 campaign minutes following cleanup, using the nearest
non-control marker's Occupant/Invader ownership. A later ownership change cancels
an old reset; an active control postpones it until despawn. Calendar arithmetic
handles year and leap-day transitions without storing a large floating-point
minute timestamp. Reset records are transient like upstream's waiting script;
they are not a new persistent save schema. The existing server watchdog owns
these records and removes itself once both registries are empty.

## Validation boundary

The dedicated fixture exercises actual off-road marker routing, prepared units,
budget reservations, legacy costs, waiting arrivals, simulation, capture,
ownership races, calendar resets and cleanup. VR has no roads: road roster
branches receive explicit classification inputs, rather than claiming a terrain
road was tested. Original-faction calls and support/UI endpoints are recorded by
the isolated test addon; they are not a full campaign regression.

The [231-check combined report](../../evidence/sprint-2/control-contract.json)
passed, including all 37 control checks. No engine/SQF Error records were found;
27 startup/object warning messages are preserved for review. The separate
[missing-dependency report](../../evidence/sprint-2/control-dependencies-absent.json)
passed all 11 checks. The [build manifest](../../evidence/sprint-2/control-build.json)
matches the tested PBO and all 40 addon source files. Both completed servers were
stopped after collection. No Computer Use was involved.

The initial combined run completed 231 checks with two failed roster-size test
expectations and no SQF/engine Error records. Source review confirms that Ultimate's
`groupTierFireteam` contains six roles, despite its preceding four-man comment;
adding the former crew role produces seven foot actors. The fixture's expected
count was corrected from five to seven and its deterministic tier mode is now
explicit. That failed run is not accepted evidence. Road-terrain navigation,
client notifications, campaign save/reload, multiplayer and sprint gates remain
unaccepted.
