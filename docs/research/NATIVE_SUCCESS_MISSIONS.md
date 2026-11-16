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

## Failed Dev1

Elimination at Myshkino succeeds with a Screamer, four basic escorts and a
Leaper 2 escort; its exact 1000 reward and cleanup pass. Supplies Seizure registers
at milbase with fuel cargo, but the truck is already deleted at inspection.
Truck readiness, CREATED state and HQ placement fail, and the success assertions
cannot execute. The report contains only 21 of 27 expected checks, with three explicit
failures and zero matched errors. Preserve the entire run under
`native-success-missions-dev1-failed`. Cause is not established; add read-only
vehicle/task diagnostics before changing production behavior.
