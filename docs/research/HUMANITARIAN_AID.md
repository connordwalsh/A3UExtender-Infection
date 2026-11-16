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
  support, and passes teamPlayer to AIVEHinit. That function returns before its
  ownership/resource hooks for this non-crewed object. This is a delivery package, not
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

Public dispatch, safe package creation and task rewards/cleanup remain
NOT IMPLEMENTED by this prerequisite. No Computer Use or manual-install changes.

## Corrected engine evidence

AidLedger Dev3 passes 37 focused engine checks, eleven actual missing-dependency
checks, packaging and three parser tests. No engine/SQF errors; 16 focused and
seven absence-run startup notices reviewed. All 211 production inputs and the
PBO match after execution, and both completed servers exited. Artifact SHA-256:
`4fc03398e3d1b80318ff01f4da3b1c7558e9a05b0f209038264ed4b171363ad2`.
The baseline includes merged Supplies Seizure and Extraction scene increments.

Dev2 initially passed 36 checks, but the strengthened 37-check run is REJECTED:
a live package deletion sometimes made alive false before isNull, causing an
incorrect destroyed outcome. The real sling check itself passed. Retained reports
include aid-ledger-engine-initial.json and aid-ledger-rejected-dev2.json, with
Dev1/Dev2 manifests and dependency reports named separately.

Dev3 observes actual EntityKilled/EntityDeleted events for the exact package and
serial. Only observed destruction is destroyed; unexplained deletion interrupts
recovery. Actual death remains recorded if its corpse is later deleted. The
fixture waits for native event delivery and verifies the distinct death/deletion
flags, rather than assuming synchronous deleteVehicle completion. Event handlers
retire with the last record. The strengthened checks now all pass, including
an actual helicopter sling attachment.

The fixture uses real packages, native capable-escort queries, nearby actors,
attachment and ropes, with controlled time/ownership. It does not establish
player notification, long-duration continuous unloading, connected carrying,
client locality, task rewards or full mission acceptance. No sprint closes.

## Public mission integration draft: 15 November 2026

The owner selected the town's existing infected population for the unloading
defense. No additional horde is created. The public controller now connects the
ledger to bounded HQ package placement, native logistics loading, a SUPP task,
the normal and legacy menus, mission requests and both native supply endpoints.
Ordinary campaigns still delegate to Ultimate. Infection keeps execution on the
server, including scheduler requests that would otherwise select an HC.

The package retains Ultimate's invulnerability and rope support. Native
AIVEHinit exits before vehicle ownership/resource hooks for this non-crewed
object. The task has the original 60/30-minute deadline and 180/90-second unload
duration. A nearby capable escort is required; an empty escort cannot progress.
Nearby undercover escorts are exposed during distribution. No extra defenders,
civilians, police or horde are spawned by this mission.

Settlement uses native support, aggression, score and cash functions, with
once-only settlement before external effects. Capturing the town cancels without
penalty. Cleanup protects attached, slung, visibly observed and logistics-owned
packages, including Ultimate's nested Cargo entries and LoadingCargo operation.
Task metadata has a separate native-length retention interval. A stopped mission
script does not stop the independent deadline and settlement monitor.

The isolated AidTask suite exercises actual packages, native task bookkeeping,
support/aggression state and logistics registration, with controlled travel and
time. Player notifications, connected loading and cash/score delivery remain
NOT RUN. Engine evidence for this integration is pending; earlier ledger results
do not certify the new public controller.


## Focused controller evidence

AidTask Dev2 passes 50 focused engine checks, 11 actual missing-dependency
checks and three parser tests, with no engine/SQF errors. Sixteen focused and
seven missing-dependency startup notices match the reviewed dependency baseline.
All 229 production inputs and the PBO match the manifest after execution.
SHA-256: `7b9a870e341ccfccd47d908359f9d51fe8bdd817e595a9cee3b859b46ac3d2d3`.
Both completed servers exited before the combined run started.

The rejected initial report is retained: its 48 assertions passed, but the
fixture had not initialized the marker-update log used by native support changes.
The corrected fixture initializes that state. Two added checks verify foreign
asset preservation and that unexplained package deletion cancels without penalty.
Cleanup now preserves the object-derived native logistics JIP action when an
existing package has been reassigned. This is server-side preservation evidence,
not connected JIP acceptance. The combined regression is still running.


## Dev3 review and combined-run correction

Dev3 corrects progress-message retirement when another notification covers the
Aid timer: it removes only the matching Aid queue entry, preserving unrelated
messages. Client rendering remains NOT RUN. The Dev3 dependency-absence run
passes all 11 checks. Its first full run completed 1317 checks and 67 role records
with no engine/SQF errors, but is REJECTED for one fixture assertion:
`atask_unobserved_package_retired`. All other 1316 assertions passed. The report
retains 16 startup notices, 72 object-deletion notices and eight null-target
notifications from fixtures without a commander.

The fixture previously checked isNull immediately after registry retirement,
although cleanup retires the record after submitting deleteVehicle and the
engine can retain the reference until a later frame. It now waits up to two
seconds for the actual deletion and reports task/asset/registry state. All 50
focused checks pass on the unchanged Dev3 production build after that correction.
A new combined run will include the separately reviewed Elimination prerequisites;
there is not yet an accepted clean combined Aid report. Historical Dev2 engine,
build and absence reports and the interrupted Dev2 full run remain preserved.

## Dev4 integrated regression

AidTask Dev4 includes the merged Elimination ledger/scene prerequisites and
completes 1371 checks plus 67 role records. It is REJECTED for two Aid-ledger
fixture assertions: outside-dropoff pause and stalled-sample accounting. All
other 1369 checks pass, with no engine/SQF errors. All 237 source inputs and the
PBO still match the build manifest; the report remains committed. The Dev4
actual missing-dependency run passes all 11 checks.

The normal unloading fixture used manually injected one-second samples while
the production per-frame handler remained active between scheduled statements.
A real timer tick could advance the valid in-town sample before the later
outside-dropoff assertion compared it with an older progress value. The normal
sample sequence is now one unscheduled block, with explicit position/eligibility
details. Its separate independent-deadline test continues to exercise the real
handler. The gameplay ledger is unchanged. Focused verification is running;
combined acceptance is still pending.

The corrected fixture passes all 37 focused checks on unchanged Dev4, with no engine/SQF errors and 16 startup notices. The completed focused server exited. Dev4 full notices comprise 16 startup, 74 object-deletion and eight null-commander notifications. The next full run will combine this fixture correction with the public Elimination controller; both remain drafts pending that result.


## Accepted combined code regression, 15 November 2026

The unchanged integrated EliminationTask Dev3 rerun passes all 1,427 checks and
67 role-spawn records. All 254 production inputs and the PBO still match its
manifest (SHA-256 9563500a216a240540f138daafe98c8fed257b102d47b5e6a2ab21b37d6b06ef).
Its actual dependency-absence run passes eleven checks. No engine/SQF errors;
96 reviewed notices comprise 16 startup, 70 object-deletion and ten null-fixture-
commander notifications. The completed server was stopped. The earlier
interrupted run and rejected Aid fixture reports remain preserved.

This accepts the combined code regression containing public Aid and Elimination,
not a standalone passing Aid Dev4 full run or campaign acceptance. Connected
players, visible menus/rewards, real-terrain mission behavior, HC/JIP, saves and
performance remain open. No sprint gate or manual Dev9 installation changed.

## Native ownership cancellation, 16 November 2026

The `-AidLifecycle` campaign probe uses the public SUPP request in a fresh
Redux campaign and the unchanged production build. It validates the native
loadable HQ package and CREATED task, then invokes Ultimate's actual
Invader town-capture transaction. No ledger, reward, task-state or timer
endpoint is replaced. The package remains paused at HQ before capture.

All 16 Aid assertions and 19 campaign startup/save checks pass with zero matched
errors. Ownership cancellation removes the package, pickup marker and native
task, retires the controller, releases the supply lock, and excludes the captured
town from subsequent Aid targets. Town data remains [367,122.333,75,0]; Rebel
funds and manpower are unchanged. HQ remains intact. The isolated server exited.
Five collector tests, launcher parsing and self-review pass. The probe observes
native task removal after cancellation; it does not claim visible client feedback.

Evidence: `evidence/sprint-6/native-campaign-aid-cancel-dev1`, including raw RPT,
exact three helper inputs, launch receipt, both build manifests and reports.
All helper hashes match. Of 326 production inputs, 324 match byte-for-byte and
two match after checkout line-ending normalization, with their original frozen
source hashes verified. Production files and the manual Dev9 install did not
change. No faction implementation or Computer Use occurred.

Unloading success still requires a native capable Rebel escort, which also
activates ordinary nearby site spawning. Do not stub that interaction merely
to obtain a passing unloading timer. Real transport, visible menus/actions,
player rewards, Rebel capture cancellation and multiplayer remain open.

## Native unloading interaction (in progress)

AidSuccess Dev1 activated Pavlovo through a real capable AI escort and accounted
for all 127 town infected. Controlled nearby placement verified paused progress;
controlled engine deaths cleared the town and unloading resumed. The unchanged
180-second ledger reached delivery, support changed by the native population
scale, assets were removed and the town despawned after escort deletion.

The run is REJECTED: 22 of 23 assertions passed, but an immediate native task
state assertion failed. Zero matched engine errors; 19 campaign checks passed.
Exact inputs/logs are retained in native-campaign-aid-success-dev1-rejected.
Ultimate taskSetState queues taskUpdate via remoteExecCall while updating the
BIS task locally. The revised probe allows up to ten seconds for both stores
and records their initial/final values. Production remains unchanged; Dev2 is
running and the timing explanation remains subject to its evidence.

The fixture explicitly uses an invulnerable stationary AI escort, controlled
package placement and controlled infected deaths. Initial unloading can accrue
before the native distance loop activates the town; the ledger's complete
required total is retained and its remaining interval is checked after clearance.
This does not demonstrate player transport, combat, visible task/UI behavior,
multiplayer, or final task display retirement.

### Accepted Dev2 rerun

All 23 Aid checks and 19 campaign checks pass with zero matched errors on the
unchanged production PBO. Pavlovo again activates all 127 infected. Nearby
infected pause unloading, controlled clearance resumes it, and the ledger
completes its full 180-second requirement. Both native task stores report
SUCCEEDED. Town support changes from government 36.7469/Rebel 0 to
30.7228/6.0241, matching the native population-scaled reward for 166 citizens.
The package and pickup marker retire, the supply lock releases, rewards remain
stable, and the town despawns after escort deletion. HQ remains intact.

The Dev2 initial task snapshot already showed both stores updated. Thus this
rerun verifies eventual success but does not conclusively reconstruct Dev1's
failed immediate observation. Dev1 stays rejected. The bounded observation wait
matches Ultimate's queued task-store update; no production fix was made.

Evidence is frozen in `native-campaign-aid-success-dev2`, alongside rejected
Dev1. All four helper hashes match; 324 production inputs match byte-for-byte
and two differ only in checkout line endings, with frozen originals verified.
Eight collector tests and launcher parsing pass. Self-review confirms no timer,
reward, town roster or task-state replacement. Both test servers have exited.
This accepts the controlled native unloading interaction only; the player,
transport, combat, multiplayer and display-retirement limits above remain open.
