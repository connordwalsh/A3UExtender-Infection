# Abandoned vehicles: native lifecycle audit

Status: asset prerequisites implemented and tested; town-spawning integration
and campaign acceptance remain open. Pinned Ultimate 12.4.2 source commit
c7c8247672ed5e7d4aa317d47efb371c41de4e7d. Paths below are relative to A3A/addons.

## Confirmed owner decisions

Abandoned vehicles belong in Infection, are repairable and drivable, and include
civilian cars, police vehicles and light Russian military vehicles (vanilla
stand-ins with optional faction equipment). Only infected-held towns receive
this mix. Taking an abandoned vehicle is free salvage without the native
civilian-theft penalty. Regeneration and persistence follow Ultimate defaults.
The owner approved native parked counts and developer tuning of the mix, fuel
and repairable damage.

## What Ultimate actually does

`patcom/functions/Civilian/fn_createAmbientCivTraffic.sqf` runs separately from
the town garrison using `marker + "_civ"` as its spawn-state key. It exits for
low-civilian/nonhuman civilian templates and destroyed towns. Native parked
vehicles are regenerated each activation, with no persistent depleted stock.
The road search covers 250 metres around the town centre.

Its parked count derives from `15 * sqrt(population) * (1 - warLevel / 20)`,
then multiplies by `civTraffic / 60`; nighttime (before 08:00 or after 21:00)
multiplies that by 1.5. It rounds and clamps to at least one and at most the
number of available road entries. The stored town vehicle-count field is read
but is not used in this calculation. A blocked placement consumes its candidate
iteration; the creator does not guarantee the full count.

Parked vehicles receive civilian AIVEHinit, random fuel 0.10/0.30/0.50 and
`originalPos`. On town civilian despawn, still-civilian cars within 100 metres
of their original position are deleted; moved vehicles go to VEHdespawner.
Captured Rebel vehicles bypass that cleanup. Civilian traffic and boats have
separate creation paths in the same function; changing parked cars must not
silently change those survivor behaviors.

`core/functions/CREATE/fn_AIVEHinit.sqf` installs the real Rebel GetIn capture
handler; `fn_vehKilledOrCaptured.sqf` changes ownerSide and removes the original
despawner when claimed. Civilian ownership causes a support penalty; enemy
ownership can charge military resources. The existing Supplies Seizure creator
uses complete native civilian initialization followed immediately by neutral
originalSide/ownerSide in one unscheduled transaction. That is a reusable
free-salvage approach, but ambient lifecycle and cleanup must also recognize
neutral ownership explicitly. Merely changing the vehicle pool is insufficient.

`core/functions/CREATE/fn_VEHdespawner.sqf` skips Rebel-owned vehicles and checks
other vehicles every 60 seconds. It preserves living crew, attached objects and
nearby Rebels. Its behavior is not a campaign-persistent depleted-stock ledger.

`core/functions/Save/fn_saveLoop.sqf` collects eligible ordinary vehicles as well
as staticsToSave, then keeps living objects inside the native nearest-friendly-
marker rule. This is stricter than promising that every claimed car anywhere
on the map survives a restart. Garaging and native save eligibility should be
preserved, with disk save/reload acceptance still required.

## Implementation boundaries

Keep the existing civilian activation cycle and native save/capture rules.
Use declared current civilian and Invader light/police pools with validated
vanilla fallbacks; avoid tanks, aircraft, static weapons and missing addon
classes. Do not modify selected faction templates globally or temporarily
replace the shared civilian vehicle pool while other locations spawn.

Any adapter must recheck infected ownership before placement, keep repairable
assets alive/uncrewed, avoid blocked/visible placement, initialize capture
without theft/resource effects, and retain ownership-scoped cleanup. Tests need
actual creation, repair, entry/capture, departure/revisit, intact captured-asset
retention, destruction and native save-filter behavior. Connected driving,
towing, garage, Redux road clearance and campaign disk saves remain NOT RUN.

## Asset prerequisite checkpoint

Three internal helpers select validated civilian/police/light military pools,
calculate the exact native parked count, and create one owned-by-caller salvage
asset. Fallbacks are C_Offroad_01_F/C_Hatchback_01_F/C_SUV_01_F,
B_GEN_Offroad_01_gen_F and O_MRAP_02_F. Selected faction pools supply optional
mod classes; missing/invalid pools fall back. The creator accepts only an
existing infected-held, undestroyed town and a safe position within the native
250-metre road-search radius. It creates no crew and no autonomous cleanup job.

Native initialization is followed atomically by neutral ownership, empty cargo,
unlocked access, fuel sampled from 0.10/0.30/0.50 and repairable overall damage
from 0.15/0.35/0.55. The existing native GetIn and destruction handlers remain.
No global faction template or civilian vehicle pool is replaced.

AbandonedAssets Dev1 passes 42 focused engine checks, 11 actual missing-
dependency checks and three parser tests, with no engine/SQF errors. Sixteen
startup notices match the reviewed baseline. All 257 source inputs and the PBO
match the manifest. The test uses real native capture, actual vehicle damage and
repair, native captured-vehicle retention and destruction/resource callbacks.
It does not certify player driving, road placement, visit regeneration, garage,
optional faction-pack behavior, towing, or disk save/reload. No town spawning
caller exists in this increment.

Artifact SHA-256:
7beb01bbf2ee445ed0817cac65a298f6442a2397384f8c68d17560841e3878f7.


## Town adapter in development, 15 November 2026

The adapter now replaces parked cars only in infected-held towns. It retains
Ultimate 12.4.2's road filtering, per-visit placement-attempt counts, activation
key, boat generation and civilian traffic logic. The chosen category weights
are 65 percent civilian, 20 percent police and 15 percent light military.
These are probabilities per attempt, not quotas promised for each town.
Unsafe or occupied positions are skipped; counts are never inflated to force
a category quota. Ownership is checked again by the asset factory at creation.

A server-owned visit record tracks every created car. An independent monitor
handles both normal despawn and interrupted workers. Claimed cars are released
without deletion. Nearby observers, living occupants, attachments and ropes
defer cleanup of neutral cars; a changed ownership tag belongs to another
controller and is left alone. Unclaimed cars still near their parking location
are removed, while moved cars go through native VEHdespawner. Native boats and
traffic retain their native cleanup paths. No persistent replacement-car ledger
or change to Ultimate's save filtering is introduced.

The dedicated Altis probe uses real roads, vehicle creation, native capture and
native moved-car cleanup. Civilian driving and boats are gated out of this
fixture (one town, no sea spawn), so source preservation is not runtime evidence
for those paths. Dev1 passed 32 checks, including scheduler dispatch, road
placement, neutral capture, visit cleanup, observer protection and regeneration.
All 262 production inputs and the PBO matched its manifest. A review then added
an explicit server-local, scheduled-only guard to the internal worker; Dev2
adds attachment, foreign-owner and moved-car cleanup cases. Dev2 passed all 36
checks, 11 actual dependency-absence checks and three parser tests. No engine/SQF
errors occurred; its 16 startup notices match the reviewed baseline. All 262
production inputs and the PBO matched after execution. Both vehicle test servers
were stopped. Artifact SHA-256:
e4a8e98b39a449dac9e725a5029a236dbcf776778e335161686adeeb106167f1.

Redux roads, connected driving, headless clients, optional faction packs,
boat/traffic runtime regression, towing interactions, garage and disk save/reload
remain unaccepted. The manual Dev9 installation is untouched.


## Redux parking sweep and fixture correction

The named ReduxParking probe loads the installed Chernarus Redux and CUP Terrains
Core alongside the minimal Infection stack. It calls Ultimate's actual
getCityData/initCities functions, so the 49 town names, populations, marker
positions and native road offsets come from installed campaign/map data.
Only parking is exercised: there are no sea spawns and heavy fog gates out driven
traffic. War level 1 and the native traffic multiplier 1 define the scenario.

The first completed sweep created 112 cars and passed all placement assertions,
but failed 15 immediate cleanup checks. It is retained as rejected, not accepted.
Its final entity/group cleanup passed. A separate diagnostic run captured cars
still present immediately after the controller retired its visit record; that
run was deliberately stopped after capturing failures and remains incomplete.
The fixture now waits at most five seconds for both record retirement and actual
vehicle deletion before asserting cleanup. It does not remove extra entities to
force a pass, and the production Dev2 PBO is unchanged. The corrected full sweep
passed all 163 checks across 49 towns, created 110 cars and left no fixture
vehicles/groups. Nadezhdino had zero successful placements in this randomized
visit; native attempts are preserved rather than guaranteeing a car at an unsafe
position. The per-town attempt/spawn counts are committed as CSV. All 262 source
inputs and the Dev2 PBO still matched; no engine/SQF errors, with the same 16
reviewed startup notices. The completed Redux server was stopped. These checks do not establish vehicle driving, pedestrian/horde
navigation, civilian traffic, boats, towing, save/reload or full campaign acceptance.
