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
truck, multiplayer or the native task-display retirement timer. Runtime results are recorded below; the original truck disappearance
remains unresolved. Five collector tests and launcher parsing pass.

## Failed Dev1

Elimination at Myshkino succeeds with a Screamer, four basic escorts and a
Leaper 2 escort; its exact 1000 reward and cleanup pass. Supplies Seizure registers
at milbase with fuel cargo, but the truck is already deleted at inspection.
Truck readiness, CREATED state and HQ placement fail, and the success assertions
cannot execute. The report contains only 21 of 27 expected checks, with three explicit
failures and zero matched errors. Preserve the entire run under
`native-success-missions-dev1-failed`. Cause is not established; add read-only
vehicle/task diagnostics before changing production behavior.

## Diagnostic Dev2: passing different sample, original failure open

Dev2 passes all 27 mission checks and 19 campaign checks with zero matched errors.
At outpost_27, the Leaper 2 Elimination target pays exactly 1000 and cleans up.
The ammunition truck O_T_Truck_03_ammo_ghex_F from outpost_27 delivers at HQ,
pays exactly 300, stays usable and Rebel-owned, and appears exactly once in
staticsToSave. Further ticks preserve the truck and funds (2300 total).

This does not reproduce or resolve Dev1's milbase fuel-truck disappearance.
Read-only entity creation/death/deletion and frequent task-state logs were added;
they observe the different successful truck. Keep the original failure open and
PR 75 draft. Next investigate a targeted milbase/fuel reproduction and the
placement/vehicle lifetime before changing production behavior.

The exact helper, raw log, receipt, reports and manifests are archived under
`native-success-missions-dev2`. All 324 production inputs and helper hashes match;
production code is unchanged. Both isolated servers have exited. No Computer Use
or other faction development occurred.

## Targeted reproduction mode

`-SuccessMissions -SupplyReproduction` keeps the Elimination request but calls
the production Supplies Seizure starter with explicit `milbase`/`fuel` inputs.
It waits ten seconds at the original truck position before attempting delivery.
Vehicle/task diagnostics remain read-only. This is a targeted production-starter
test, not public LOG selection coverage; the launch receipt identifies the mode.

## FuelRepro1 confirms spawn destruction

The explicit milbase/fuel run reproduces all three Dev1 failures without script
errors. O_T_Truck_02_fuel_F is created at [2645.5,5082.5,0], alive and undamaged.
At simulation time 131.097 it receives Killed at that position. Subsequent frames
show damage 1 and violent displacement upward (over nine metres ATL); at 132.012
it is deleted, then the native task records destroyed/FAILED. This rules out a
missing reward/registration path as the immediate cause. Unsafe physical spawn
placement is now the focus; slope/geometry and model-clearance diagnostics remain
necessary before selecting a correction. Preserve the entire failed trace under
`native-success-missions-fuel-repro1`. No production changes have been made.

FuelGeometry1 was interrupted when the owner paused the goal. Its server was
stopped and absence confirmed on resume. Startup/save checks had run, but no
mission/geometry assertions began. The exact helper, receipt and incomplete raw
result are preserved under `native-success-missions-geometry1-interrupted`.

## FuelGeometry2: passing different position; geometry logging limitation

The resumed fresh run passes 27 mission and 19 campaign checks with zero matched
errors. The milbase fuel truck is O_T_Truck_03_fuel_ghex_F at
[2528.52,5088.48,0], not the failed O_T_Truck_02_fuel_F position. It survives the
ten-second observation and delivers for exactly 600, retaining the usable truck.
This is not a fix or a reproduction of the original failing geometry.

At the original failed position, surfaceNormal is [0,0,1]; findEmptyPosition
accepts both fuel classes while sizeOf returns zero before either is instantiated.
The radius-3/6/10 isFlatEmpty checks reject both the failed point and the new
successful point. Therefore those checks alone do not establish a useful spawn
safety discriminator. Long terrain-object arrays are truncated in the engine
log; subsequent diagnostics emit one object per record, including its identity
and direction. Production remains unchanged. The stopped run, exact fixture,
receipt and reports are archived under `native-success-missions-geometry2`.

## FuelGeometry3: complete nearby-object records

All 27 mission and 19 campaign checks pass, with zero matched errors. Another
O_T_Truck_03_fuel_ghex_F survives at [2546.5,5096.5,0]. The original failed point
has Land_Hutch_01_F at [2649.3,5082.17,0], roughly 3.8 metres from its centre,
plus nearby vegetation and unnamed terrain objects. This suggests a footprint
overlap but does not identify the collision by itself. Object records are now
complete rather than truncated. Archive: `native-success-missions-geometry3`.

The next diagnostic samples vertical GEOM and PHYSX rays over a conservative
4 x 12 metre envelope at the failed point and both observed surviving points,
using eight headings. It only observes geometry; the failed truck's final
heading was not logged, and this envelope is not a production safety rule.
