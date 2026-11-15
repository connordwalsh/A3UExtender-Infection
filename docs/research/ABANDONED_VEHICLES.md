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
