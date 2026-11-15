# Humanitarian Aid adaptation audit

The owner's replacement Supply category delivers a package of supplies to
survivors before an infected settlement is cleansed. The requested catalog is
infected-only and must not fall back to gang missions. Timing and rewards may
start from Ultimate's defaults under the owner's earlier authorization.

Pinned source: Ultimate 12.4.2, c7c8247672ed5e7d4aa317d47efb371c41de4e7d,
Missions/fn_missionRequest.sqf, fn_SUPP_Supplies.sqf and
fn_RIV_SUPP_Salvage.sqf; CREATE/fn_AIVEHinit.sqf.

## Native behavior to account for

- Requested SUPP chooses a non-destroyed town within distanceMission with Rebel
  support below 90, weighting low support and short distance. It does not require
  infected ownership. It may dispatch RIV_SUPP_Salvage instead. Both endpoints
  therefore need guarded Infection behavior, preserving ordinary campaigns.
- Native normal/difficult deadlines are 60/30 minutes. It creates an invulnerable
  Land_FoodSacks_01_cargo_brown_F package near HQ, adds native loading and rope
  support, and initializes it as Rebel-owned. This is a delivery package, not
  the recoverable truck used by Supplies Seizure.
- Native placement uses findEmptyPosition without a checked empty-result branch.
  The replacement needs bounded, collision-checked HQ placement and rollback.
- Delivery starts within 40 metres of the town center with the package detached
  and unroped. Normal/difficult unloading is 180/90 seconds. It checks that nearby
  Rebels can fight and no Occupants are within 50 metres. The inner loop can
  advance with no nearby Rebels because zero eligible units equals zero total;
  the replacement must not mistake that vacuous count for a present escort.
- Initial activation spawns conventional police, and the difficult mission adds
  another conventional group. Native direct movement/reveal instructions also
  affect nearby troops/civilians. Infection cannot reuse empty vehicle/group
  pools or assume ordinary waypoints control WebKnight behavior.
- Success adds 5*bonus Rebel support, subtracts that much Occupant support,
  gives all Rebel players 15*bonus score and 300*bonus money, and gives the
  commander 5*bonus score and 100*bonus money. It reduces Occupant aggression
  by 10 for 60 minutes. Failure reverses support and penalizes commander score
  by 10*bonus. No direct FIA army resource reward is issued.
- Native cleanup releases the global supply lock, deletes the package, then
  reads its position to create a pallet. The replacement must capture any needed
  position before deletion and own task/asset cleanup independently of a worker.
  Native task retention averages 900 seconds.

## Open decisions and implementation

The owner chose the existing unloading phase and cancellation without a penalty
if Rebels or Russia capture the destination. The internal ledger now tracks that
phase independently of a mission worker, requires an actual eligible escort,
pauses when conditions fail, and gives ownership cancellation priority over
simultaneous delivery or timeout. It caps sampled progress at one second per tick
instead of crediting unobserved time after a stalled worker. Serial ownership
protects packages and terminal outcomes freeze. No public tasks, rewards or
package cleanup are issued by this layer.

Public dispatch, safe package creation, task rewards/cleanup and engine evidence
remain NOT IMPLEMENTED or NOT RUN. No Computer Use or manual-install changes.
