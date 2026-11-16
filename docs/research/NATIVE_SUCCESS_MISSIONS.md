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

## FuelFootprint1: failed-point envelope intersects hut

The fixed-position diagnostic completes without matched errors. Each of eight
headings at [2645.5,5082.5,0] intersects Land_Hutch_01_F geometry inside the
sampled envelope. At 131.552 degrees a hit is only two metres along the centre
line, at ASL [2647,5081.17,196.16]. This is direct geometry evidence against
accepting that centre point merely because findEmptyPosition accepted it.
It does not reconstruct the original truck's unknown final heading or prove
which contact caused the recorded destruction. Both surviving positions also
have geometry inside this conservative envelope, so actual class dimensions
and heading must inform the production correction rather than copying this
diagnostic rectangle as a universal truck size.

The same run passes 27 mission and 19 campaign checks, including a separate
milbase fuel truck delivered for 300. Exact logs, fixture, receipt and reports
are preserved in `native-success-missions-footprint1`; the isolated server is
stopped. No production correction is implemented or validated yet.

Engine query references: [boundingBoxReal](https://community.bistudio.com/wiki/boundingBoxReal)
reports model-space bounds; [lineIntersectsSurfaces](https://community.bistudio.com/wiki/lineIntersectsSurfaces)
accepts ASL endpoints and GEOM/PHYSX collision LODs. The next change needs a
truck-specific footprint guard before creation, applied in both selection and
final validation, with the failed position as a regression case and real
surviving spawns to check that the search remains usable.

## Truck-clearance candidate (runtime validation pending)

The candidate introduces supplyTruckBounds and supplyPositionClear. A temporary
local simple model supplies actual class bounds, then is deleted immediately;
bounds are cached per class. No simulated truck is used for this measurement.
The guard rotates the footprint by the intended heading, adds a 0.25 m margin,
samples at no more than 0.75 m spacing, and rejects water, steep/uneven ground,
or GEOM/PHYSX intersections. Horizontal scans supplement the vertical samples.
Both the parking selector and final unscheduled creation path enforce it.
Generic infected spawn rules are unchanged.

This is a conservative sampled envelope, not a mathematical proof that every
possible tiny obstacle is excluded. Runtime usability, representative truck
classes and mission regressions must pass before accepting the correction.
The native helper now requires 29 checks, including nonempty bounds for both
selected fuel classes and rejection of the historical failed point in eight
headings per class. Earlier archived 27-check reports retain their original
meaning. The candidate builds and five collector tests pass; native validation
is pending on TruckClearance1.

TruckClearance1 now passes all 29 mission and 19 campaign checks with zero
matched errors. Both selected fuel classes reject the historical failed point
as truck_geometry at all eight headings. The originally failing class,
O_T_Truck_02_fuel_F, spawns elsewhere at milbase, survives the ten-second
observation, delivers at HQ for exactly 300, stays usable/Rebel-owned and is
registered once for saving. The exact helper and all 326 production inputs
match the launch/build receipts. Evidence is in
`native-success-missions-clearance1`; the server is stopped. This supports the
sampled regression correction; other truck types, broad contract regression,
player driving and representative parking availability still need validation.

The focused SupplyTrucks regression now passes all 35 dedicated checks with
zero matched errors on the same candidate. It covers ammunition/fuel/repair
creation, allowed pools, native initialization and Rebel capture, retained
claimed trucks, neutral resource effects on creation/destruction/cleanup, and
asset cleanup. The original report and fixture inputs are preserved under
`native-success-missions-truck-contracts1`. The combined Full contract suite is
running as TruckClearanceFull1; representative Redux parking availability is
still outstanding. PR 75 remains draft.

TruckParking1 surveys all 413 current infected-held site/kind/class combinations
in a fresh native Redux campaign. It records 356 available positions, 57 empty
search results, zero invalid returned positions and zero matched errors. Native
startup/save also passes 19 checks. Kozlovka, outpost_7 and outpost_29 have no
successful class search in this single pass. Class totals/available are
O_T_Truck_02_fuel_F 112/90, O_T_Truck_03_fuel_ghex_F 112/103,
O_T_Truck_03_ammo_ghex_F 63/59, O_T_Truck_03_repair_ghex_F 63/56 and
O_T_Truck_02_Box_F 63/48. These are search observations, not truck survival tests.

The survey is complete, not an all-locations availability pass. Empty results
must be reviewed against the previous search and existing exclusions before
attributing them to the new guard or changing search bounds. The exact helper,
receipt, build manifest, reports and raw log are in
`native-success-missions-parking1`; its server has stopped. Full contract
regression remains running and no production inputs have changed underneath it.

TruckParkingCompare1 repeats the 413 combinations and also runs the exact
pre-guard findSupplyPosition source from d666fff as a local code value, without
replacing the production endpoint. Candidate: 355 found, 58 unavailable, zero
invalid. Historical search: 413 found, zero unavailable, but 333 fail the new
clearance revalidation (80 pass). Both have complete records and no matched
errors. The baseline report deliberately remains failed for its invalid-position
check; it is not rewritten as passing evidence.

The candidate finds both Kozlovka classes and one class each at outpost_7 and
outpost_29 this time. Thus the earlier empty results at those sites are not proof
of an absolute exclusion. Independent random samples and already-loaded models
mean this comparison is observational, not a paired deterministic experiment or
proof that all 333 rejected legacy positions would destroy a truck. Candidate
search times observed here are median 0.037 s, p95 0.109 s, maximum 0.215 s;
this is not gameplay performance acceptance. Next evaluate a larger bounded
search budget while retaining the tested geometry guard. The stopped comparison
is preserved under `native-success-missions-parking-compare1`.

TruckParkingTuned1 evaluates a local copy of the candidate search with only the
attempt bound changed from 24 to 96. Its 413 samples find 401 valid positions
and 12 unavailable, versus 356 valid/57 unavailable for the production search
in the same campaign. Neither returns an invalid position or matches an error.
Native startup/save passes 19 checks. Search duration median/p95/max is
0.037/0.146/0.468 s for the proposal and 0.037/0.109/0.181 s for production.
These independent random observations support adopting the larger finite budget,
not claiming universal availability or gameplay performance acceptance.

The guard, first 12 roadside attempts, ownership/boundary/exclusion rules and
failure return are unchanged. The proposal is not yet in production: the active
Full regression still uses the frozen 24-attempt build. The comparison server is
stopped and its exact inputs/results are preserved under
`native-success-missions-parking-tuned1`. After the frozen regression is archived,
apply the proven one-line budget change and verify the resulting production build.
