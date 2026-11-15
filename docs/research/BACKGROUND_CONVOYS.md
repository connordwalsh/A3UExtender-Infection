# Background Russian supply convoys

The product owner chose to retain Russia's automatic supply convoys as background
military activity, without offering a player mission. This is part of the new
infected-only mission catalog; it does not disable Russian strategic activity.

## Scope and behavior

Ultimate 12.4.2's `chooseAttack` schedules `CONVOY` with `Supplies` and the
`attack` resource pool. Infection sends that call to the server and, when the
source belongs to the Invaders, runs the background supply controller. The
convoy lock is claimed atomically. Ordinary campaigns delegate to Ultimate.
Other convoy types and legacy request/intel calls still delegate while their
replacement integration remains unfinished.

The controller adapts the supply branch of pinned Ultimate source
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. It retains faction-selected vehicles,
native crew/cargo creation, route placement, travel handoff, attack resource
costs, source idle time, departure delay, outcome timeout, support and strategic
resource effects, kill zones, despawner handoff and escort return orders.

It creates no task, task registry entry, route dots or automatically revealed
objective marker. It grants no personal mission score/money and imposes no
commander penalty for an unassigned convoy. Physical cargo remains interactable.
The native one-hour outcome timeout and its strategic effects are retained;
this change does not redefine how Ultimate resolves a stalled convoy.

## Validation boundary

The focused `BackgroundConvoys` fixture exercises the real scheduler/server
dispatch, engine vehicles and crew, native navigation placement, native cargo
loading, attack-pool accounting, arrival, destruction and captured delivery.
It checks duplicate refusal, unchanged ordinary/legacy dispatch, no mission
registration, strategic effects, teardown handoff and worker completion.

Movement and combat initialization are isolated test endpoints. Despawner calls
and campaign notifications are recorded; fixture entities are then explicitly
removed. This does not certify driving, combat, native despawner behavior,
connected-player UI, timeout after a real hour, headless clients, or a complete
Chernarus Redux campaign. Interrupted native-style convoy cleanup remains part
of the broader campaign resilience work.

Build and source hashes are recorded in
`evidence/sprint-4/background-convoys-build.json` and
`background-convoys-source-audit.json`. Current focused validation is in progress.
The Dev1 missing-dependency run passes 11 checks; Dev2 is being checked again. Two rejected fixture runs
retain their evidence: the cargo-action recorder originally accepted only arrays,
and the isolated Rebel faction omitted the loot-crate key used by native logistics.
Neither correction changes production code. No Computer Use or manual install
update was performed.

The Dev1 destruction test also exposed a production race inherited from Ultimate:
its truck-killed handler was installed after departure, so a truck destroyed while
leaving could leave living cargo and keep the convoy lock. Dev2 installs the
handler before removing spawn protection and targets only its own still-attached
cargo. An additional parked-truck destruction case covers the pre-departure gap.
The rejected Dev1 evidence and manifest remain archived.
