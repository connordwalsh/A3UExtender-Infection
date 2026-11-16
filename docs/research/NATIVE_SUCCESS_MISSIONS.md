# Native Elimination and Supplies Seizure success probe

`start-campaign-probe.ps1 -SuccessMissions` runs two sequential public mission
requests in an actual fresh Redux campaign after startup/save checks. No
production selectors, factories, task endpoints, rewards or timers are replaced.

The 27 assertions cover an approved Elimination target, different basic/special
escorts, search marker, native task creation and success after engine target
death, exact campaign reward, asset cleanup and budget release. Supplies Seizure
must create an allowed service truck, complete through the real HQ delivery
predicate, pay exactly its reward, retain a usable Rebel-owned truck, register
it once for native persistence and retain that settlement across further ticks.
HQ must remain intact.

The test uses setDamage for the target and places the truck at an engine-found
empty position within HQ's delivery range. This is not player combat or driving.
It does not prove every target class/truck kind/location, save/reload of the
truck, multiplayer or the native task-display retirement timer. Runtime evidence
is pending. Five collector tests and launcher parsing pass.
