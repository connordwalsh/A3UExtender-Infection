# Town liberation: source contracts

The owner selected survivor rescue and defense with a walking infected horde.
This audit pins Ultimate 12.4.2 at `c7c8247672ed5e7d4aa317d47efb371c41de4e7d`;
the [44-file manifest](../../evidence/sprint-3/town-liberation-sources-12.4.2.json)
records the exact inputs. This is source evidence, not runtime acceptance.

## Native entry and ownership

`resourcecheck` evaluates towns every ten minutes while players are active.
A non-destroyed, non-skirmish town can join the Rebels when Rebel support is at
least 1.5 times government support. Population at least twenty and the configured
skirmish roll may replace that political flip with `townBattle`. The normal
caller searches same-side outposts within 3 km, then any same-side outpost;
without any outpost it calls `cityChangeSide` directly. Infection must replace
that source search with the approved nearby town/permanent-site walking policy.
The owner selected the peaceful political flip when no nearby eligible origin
can send a horde. Existing task claims or a player already in the town are not
an absent-origin result; those native refusal conditions remain distinct.

`townBattle` is server-only and scheduled. It rejects already defeated factions
and a Rebel player inside `max(200, town radius)` before creating anything. It
registers a `townBattle` task and adds the town and closest administration to
`townSkirmishes`. The town remains enemy-owned throughout the defense. A generic
major-capture controller cannot be reused unchanged: it rejects WEST targets
and would interpret WEST ownership as an already completed infected capture.

## Survivor and attack phases

Native creation puts a civilian leader beside a Rebel vehicle, initializes the
leader without replacing its equipment, and offers `flagaction`'s `townVIP`
action. `liberateVIP` rejects an undercover CIV rescuer, removes the action,
ends the ambient animation and joins the leader to the rescuer's group. The
mission detects that group change. Infection must use a verified human civilian
role; the native fallback to the Occupant official would create an infected VIP.
The selected civilian faction and WBK targeting/infection settings remain inputs.

Native recruitment allows 40 minutes. Incapacitation or leaving the town's
failure radius fails the rescue. Recruitment begins a three-minute preparation,
then a conventional mixed air/land force. Its allowance depends on population
and player scale. The owner-selected replacement is one finite walking horde
using shared active capacity, with actual paid births and gradual arrivals.
The full independent town infestation remains active during this mission, per
the owner's explicit town-population decision.
The owner selected physical horde arrival as the start of the ten-minute defense
clock. Marching time must not consume that countdown.

The original defense ends after ten minutes, at 30% remaining attackers, when
the survivor cannot fight/leaves, or when the overall mission expires. Its final
success expression omits the survivor condition; simultaneous survivor loss and
timer/force completion can therefore produce success. The infected adapter must
require a viable survivor at settlement, and must not award success for zero
spawned attackers or treat a waiting queue as defeated actors.

## Settlement and cleanup contracts

Success calls native `cityChangeSide`, changes nearby support, reduces Occupant
aggression, and grants player/commander rewards. Native HR and faction funds use
population and the `overallHRGain` multiplier. Early rescue failure applies
`[10,-10,town,false]` support. Failed defense applies nearby/local Rebel support
penalties plus `-4 * population * player scale` attack resources. A technical
cancellation must not silently grant those rewards or failure penalties.

Native cleanup has several shared owners: task metadata, `townSkirmishes`,
`bigAttackInProgress`, `forcedSpawn`, the joined VIP, effects/vehicles and attack
groups. The infected implementation needs exact ownership and interrupted-worker
recovery; it must never delete a player's group or release another attack's flag.
Post-mission corpses and groups should use the existing deferred cleanup contract.

The original decorative effects assume nonempty vehicle/building pools, damage
nearby buildings and create dead actors and fires. These are separate from the
defense objective. Any retained effects need checked classes, positions and
cleanup ownership rather than fallback infected crew or empty random selections.

## Validation required before integration

- Native entry/delegation, selected source distance/readiness/cooldown and the
  owner's pending no-source policy; duplicate and ownership-change rejection.
- Real human leader creation/recruitment, default WBK behavior, action delivery,
  failure radius, death/incapacitation and same-frame failure precedence.
- Shared-cap births, bounded queue/debt, preparation and physical arrival,
  source interruption, no-force cancellation and full-town population coexistence.
- Real native task/territory/resource settlement exactly once; cancellation and
  worker interruption at each registration boundary.
- No leftover owned actors, groups, callbacks, task claims or attack flags;
  survivor/player groups and unrelated attacks remain intact.

Connected-player interaction, Redux travel/placement, longer defense pacing,
multiplayer/JIP and save/restart require separate evidence. The source selector
has the isolated results below; no full liberation mission or campaign/sprint
gate is accepted.

## Selector development checkpoint

`liberationSources` is registered for direct validation on this separate branch.
It accepts infected-held towns, excludes the target itself, preserves the native
nearby-player refusal and rejects existing skirmish/attack claims. Nearby towns
and all approved permanent source types use the existing walking-route,
ownership, cooldown, combat and observer checks. Selection has no task, actor,
resource or ownership side effects. It does not implement the pending political
fallback and is not connected to native mission dispatch.

The first selector candidate builds successfully and passes
[11 missing-dependency checks](../../evidence/sprint-3/liberation-selector-dependencies-absent.json).
Its [manifest](../../evidence/sprint-3/liberation-selector-build.json) records
118 production inputs. All [34 focused selector checks](../../evidence/sprint-3/liberation-selector-focused.json)
pass, including 23 selector cases and 11 startup checks, with no engine/SQF
Error records. All 118 source hashes match the candidate. The fixture exercises
all approved permanent origin types, duplicates/self-origin exclusion, source
ownership, combat/cooldown/activation, distant/disconnected routes, unrelated
attack claims, inactive/missing dependencies and selection without ownership or
resource side effects. Source review initialized both native recent-damage
histories before the first focused run.
The completed test server was stopped by its verified process/profile identity.
Nearby-player refusal with a connected player, survivor and full mission lifecycle,
native dispatch and the pending political fallback still require work.

## Human survivor development checkpoint

The second candidate adds server-owned human creation and exact-actor cleanup.
It uses the selected civilian template's registered VIP, Man or Worker role,
refuses nonhuman templates and infected role fallbacks, and uses native identity,
loadout, revive, interaction and recruitment functions. A failed placement creates
nothing; a partially initialized actor remains owned for recovery. Recruitment
does not make the rescuer's group eligible for mission cleanup. Observed survivors
defer cleanup, preserving the existing observer policy.

All [56 focused checks](../../evidence/sprint-3/liberation-survivor-focused.json)
pass: 23 source-selection cases, 22 survivor cases and 11 startup checks. The
[missing-dependency suite](../../evidence/sprint-3/liberation-survivor-dependencies-absent.json)
passes 11 checks. The [manifest](../../evidence/sprint-3/liberation-survivor-build.json)
records 120 production inputs. No engine/SQF Error records occur. Eighteen warnings
are retained: sixteen startup/dependency warnings and two native friendly-fire
handler deliveries whose fixture actors had already been deleted. The fixture
uses real human actors and native recruitment into an AI rescuer's group; it does
not certify a connected player's interaction, locality or UI. The three parser
tests and whitespace checks pass. Both completed servers were stopped by their
verified process/profile identities.

The controller, arrival clock, native entry and settlement remain unimplemented
at this checkpoint. The combined suite now declares 729 cases but has not been
run on this candidate; the previously accepted combined result remains 684.

## Arrival-clock and horde development checkpoint

The fourth candidate adds a liberation purpose to the existing major-horde
registration. Only a local, registered parent with a viable recruited survivor,
matching town/source and horde phase can launch it. Registration saves the parent
link atomically. Native population/player vehicle allowance becomes a finite
basic-infected queue, bounded by the existing 192-actor major ceiling. Actual
births cost ten attack resources and may use scoped temporary debt. Living
despawns retain Ultimate's refund. Shared capacity, cooldowns, combat checks and
safe walking origins remain in force; no campaign fixed charge is added.

The liberation worker has no capture, handoff or second-task branch. A fighting
attacker physically entering the town marker records the first arrival timestamp.
Later batches and departures never reset it. The outcome evaluator permits
victory after 600 seconds from that arrival or the native 30-percent remaining
force threshold, counting queued actors as remaining. Zero births cannot win.
Survivor incapacitation or departure wins a simultaneous race against timer or
force completion; the native overall forty-minute mission limit is preserved.
Source/target loss, missing dependencies, stopped workers and force starvation
cancel without success or failure rewards. The shared watchdog retires child
claims and actors independently of the still-unimplemented parent controller.

Source review also found that excluding only basic infected would accept a
special creature hidden in a civilian role. Installed WBK configuration declares
or inherits faction `WBK_AI_ZHAMBIES` across its prepared creature families.
The [configuration manifest](../../evidence/sprint-3/liberation-wbk-role-sources.json)
records those inputs. Survivor selection now excludes that faction; a Smasher
role is rejected before any actor is created.

The final candidate passes [79 focused checks](../../evidence/sprint-3/liberation-horde-focused.json)
and [11 missing-dependency checks](../../evidence/sprint-3/liberation-horde-dependencies-absent.json),
with no engine/SQF Error records. The [build manifest](../../evidence/sprint-3/liberation-horde-build.json)
matches all 122 production inputs. The focused report contains real births,
native resource transactions, native human recruitment and cleanup. Arrival
positions and timer boundaries are injected, so walking travel, ten minutes of
actual defense pacing and player interaction remain NOT_RUN.

The first horde attempt exposed fixture defects: missing native `plusGarrison`,
counting a pre-existing human in the infected limit, and expecting spent resources
to remain spent after deliberately despawning a living attacker. The exact
floating-point deadline assertion was changed to sample one second before and
after expiry. These rejected attempts remain separate from accepted evidence.
The corrected third candidate passed 78 cases before the additional special-role
guard. The fourth candidate's [combined 752-case regression](../../evidence/sprint-3/liberation-horde-contract.json)
passes, including all 67 role spawns. All 122 production inputs, the PBO and all
184 collected fixture/production hashes match. No engine/SQF Error records occur.
The 86 retained warnings comprise sixteen startup/dependency warnings, sixty-six
object-deletion notifications, two absent-commander notifications and two native
friendly-fire handler targets already removed by the fixture. The completed
server was stopped by its verified process/profile identity.

## Remaining controller work

Native dispatch is not connected. The next controller must register exact town
and administration skirmish claims, create the task/survivor, detect recruitment,
retain the native three-minute preparation and own its horde/settlement workers.
The complete parent must validate survivor viability at settlement, deliver
native ownership/support/HR/fund rewards once, preserve unrelated claims and
recover interruption at each registration boundary. `cityChangeSide` sleeps
after changing ownership; it cannot be called as one unscheduled transaction.
That settlement boundary needs explicit recovery rather than an assumed atomic
native call. Task delivery and positive client locality remain separate tests.

Further native-source review confirms these controller boundaries:

- `taskUpdate` rejects a second active task of the same type. The controller must
  claim the `townBattle` type before asynchronous creation, including the native
  completed-task display interval, instead of allowing multiple same-type parents.
- `cityChangeSide` performs ownership, garrison reset, marker update, support,
  aggression and nearby-administration processing before its five-second pause;
  control deletion and tier checking follow the pause. A stopped worker must not
  repeat the earlier rewards simply to recover those later maintenance steps.
- Nearby administration capture must still use Infection's existing clear-first
  guard. Liberating a town is not permission to clear an uncleared stronghold.
- `resourcesFIA` and `citySupportChange` own native serialization flags. Their
  queued calls and native caps/currency notifications belong in the settlement
  audit; a report of final task state alone is insufficient reward evidence.
- `resourcecheck` combines the skirmish decision with unrelated income, radio,
  trader and victory processing. Any replacement must isolate the infected-town
  branch and preserve the rest of that pinned routine.

The owner subsequently approved the peaceful no-origin fallback. It is not yet
implemented by these helpers. Native decorative wrecks, damage,
effects and the survivor vehicle also remain part of the full mission audit.

## Parent controller development checkpoint

An isolated follow-on checkout adds direct local `startLiberation`, `runLiberation`,
`finishLiberation` and watchdog functions. They claim the native task type and
exact skirmish markers, create the human survivor/task, detect native recruitment,
retain three minutes of preparation and launch the linked horde. An ineligible
or busy source waits within the forty-minute overall deadline without stealing
another attack's slot. This draft is not connected to campaign dispatch.

Settlement separates success, early rescue failure, defense failure and technical
cancellation. The immediate Rebel branch of the pinned `cityChangeSide` is adapted
inside the atomic settlement, with its control/tier maintenance dispatched after
five seconds. It preserves native task/ownership/garrison/support/aggression and
HR/fund transactions, guards the native resource lock, and rechecks the survivor
before success. Existing stronghold capture guards remain in the path. Completed
paid liberation hordes retain the native sixty-second attack-release interval.

The 126-input Dev2 candidate passes 102 focused checks, including 23 parent
mission cases, and 11 missing-dependency checks. These exercise real task
metadata, humans/infected, resources and tier calculation; support/aggression
delivery uses the existing observed fixture endpoints. Preparation, arrival and
timer positions are injected. All production and focused-report input hashes
match, with no engine/SQF Error records. Three parser tests pass. Rejected
attempts exposed observation races: the fixture now waits for exact survivor
and original-group deletion and the queued native living-despawn refund before
asserting cleanup or resetting the next case. Assertions remain in place.

Source review after this checkpoint found that player rewards and the native HR
cap must use the war level after the town's delayed tier update. Dev2 pays before
that update. The passing Dev2 report did not cover that case; commit `42ccc0b`
retains the historical candidate and evidence.

## Reward-order correction

Dev3 completes the native tier check five seconds after capture, then performs
the once-only rewards. The pinned tier/preference/vehicle-update chain has no
suspending operations and runs in the watchdog's local transaction. Native
control cleanup remains scheduled because it waits for distant controls to
despawn. A busy faction-resource lock retains the mission until payment can
complete; task/actor retirement cannot discard an unpaid reward.

All [104 focused checks](../../evidence/sprint-3/liberation-controller-focused.json)
and [11 missing-dependency checks](../../evidence/sprint-3/liberation-controller-dependencies-absent.json)
pass on the [127-input candidate](../../evidence/sprint-3/liberation-controller-build.json).
All production, PBO and 190 focused-report input hashes match. The added case
starts with 250 HR, a tier-one cap of 200 and a capture that raises the native
tier to eight. Final HR is 251; paying under the old tier would have reduced it
to 200. The case also holds the native resource lock across the tier update,
then proves payment and repeated-settlement protection after release.

No engine/SQF Error records occur. Nineteen focused warnings are retained: sixteen
startup/dependency notices, two friendly-fire deliveries to deleted fixture
actors and one income message to the absent commander. The dependency-absent
report retains seven startup notices. Three parser tests, PowerShell parsing
and whitespace checks pass. Both focused servers were stopped by verified
process/profile identities. The [combined 777-case regression](../../evidence/sprint-3/liberation-controller-contract.json)
passes, including all 67 role spawns. All 127 production inputs, the PBO and all
190 collected inputs match. No engine/SQF Error records occur. Its 77 retained
warnings comprise sixteen startup/dependency notices, fifty-six object-deletion
notifications, three income messages to the absent commander and two friendly-fire
deliveries to deleted fixture actors. The completed server was stopped by its
verified process/profile identity.

The owner selected retention of the native wrecks, bodies, fire/building damage
and survivor vehicle. That scene is a separate implementation increment. Native
campaign entry with the approved peaceful fallback, connected-player rewards/UI, real
walking travel, defense pacing and full mission acceptance remain open.

## Retained scene: source audit and vehicle component

The owner approved retaining the native scene on 14 November. The next branch
adds a direct survivor-vehicle component; it is not connected to the parent
mission until the complete scene lifecycle owns its cleanup.

`liberationVehicleClasses` retains native category-then-class selection from the
Rebel template and its configured `vehiclesBasic` fallback for missing fields.
It excludes empty/malformed categories, missing classes, nonpublic classes,
aircraft, boats, static weapons and UAVs. `createLiberationVehicle` requires the
local, owned, live survivor. It prefers a safe nearby road, otherwise uses the
bounded outdoor search, and never substitutes a center or origin position when
that search fails. The parent records the vehicle immediately after creation.
No crew is requested. Native postmortem preparation, unlocked access and the
original survivor-group vehicle association are retained. Deletion does not
permit a repeated call to create a replacement vehicle.

Source findings for the remaining scene work:

- Native `spawnVehicle` creates a driver and turret crew even when its caller
  immediately deletes them. The empty survivor vehicle avoids that transient
  crew path and its potential infected-role fallback.
- Native `createDeadSoldier` creates a civilian group and a blood object but
  returns only the corpse. The caller also stores body arrays inside another
  array. The new scene must retain exact corpses, original groups and blood
  objects so interrupted setup and ordinary cleanup can retire all three.
- `createFire` returns a particle source and a light, with object-bound JIP
  setup. `damageBuilding` may return a nested fire array, a smoke object or a
  null object and assumes a nonempty roof-intersection result. Scene ownership
  must flatten/validate those effects and handle buildings without a roof hit.
- Building destruction is linked through the native `BuildingChanged` event.
  `repairRuinedBuilding` requires both the original building and its linked
  ruin; it returns false for ordinary partial damage. Cleanup cannot assume
  that calling it restores every building. Record initial damage and the exact
  changed buildings, preserving pre-existing damage and protected site objects.
- The native survivor vehicle has no `ownerSide` initialization; `VEHdespawner`
  treats that as Rebel ownership and leaves it. Wrecks instead pass through
  `AIVEHinit` with the attacking side, including capture/damage/resource events.
  These are distinct lifecycle and economy contracts to preserve or explicitly
  adapt. The direct vehicle component does not certify collection or saving.

The [129-input Dev2 candidate](../../evidence/sprint-3/liberation-vehicle-build.json)
passes [116 focused checks](../../evidence/sprint-3/liberation-vehicle-focused.json)
and [11 missing-dependency checks](../../evidence/sprint-3/liberation-vehicle-dependencies-absent.json).
The twelve vehicle cases cover category filtering, malformed inputs, remote/foreign
creation refusal, unavailable placement, real usable empty creation, an actual
EntityCreated audit for temporary crew, placement/ownership, idempotence and
deletion. All production/PBO and 193 focused-report input hashes match. No
engine/SQF Error records occur. The 23 focused warnings comprise sixteen startup
notices, four object-deletion messages, two friendly-fire deliveries to deleted
fixture actors and one absent-commander income message. Seven startup notices
remain in the dependency-absent report.

The first focused attempt was rejected after a test setup tried to copy an
undefined optional template value. The fixture now copies only defined fields;
the candidate's production code did not change. Three parser tests and whitespace
checks pass. Both completed servers were stopped by verified identity. The scene
component is still unconnected, its combined regression is NOT_RUN, and no
bodies, wrecks, fires or building-damage implementation is claimed yet.

## Retained scene: fire ownership and cleanup

The next component owns every particle source and light immediately after
creation, refuses unsafe placement and defers retirement while an observer is
nearby. It is still separate from the parent mission's scene lifecycle.

The first candidate failed three effect checks. Arma's special effect objects
cannot store ownership variables, as confirmed by the engine test and the
[setVariable reference](https://community.bistudio.com/wiki/setVariable?useskin=vector).
Dev4 instead keeps the exact parent record and effect-array references in a
server registry. Foreign records, including a different record with the same
name and copied object references, cannot create or remove its effects.

The native light helper also sends three persistent calls with the same object
as JIP identity. Later calls replace earlier ones according to the
[remoteExec contract](https://community.bistudio.com/wiki/remoteExec).
`applyLiberationFire` now applies the particle class and all three light settings
in one server-issued, object-bound call. Its callback rejects ordinary local
calls and calls originating from nonserver clients. Connected-client rendering,
hosted play and actual joining-client delivery remain NOT_RUN.

The [132-input Dev4 candidate](../../evidence/sprint-3/liberation-effects-build.json)
passes [129 focused checks](../../evidence/sprint-3/liberation-effects-focused.json)
and [11 missing-dependency checks](../../evidence/sprint-3/liberation-effects-dependencies-absent.json).
The thirteen new effect cases exercise real networked particle/light creation,
exact ownership, remote mutation refusal, same-name foreign-record refusal,
multiple pairs, deletion, idempotence and a partial-creation cleanup state.
All 132 production inputs, the PBO, 197 focused-report inputs and 159
dependency-report inputs match their recorded hashes. No engine/SQF Error
records occur. The focused log retains 21 warnings: sixteen startup/dependency
notices, two object-deletion notifications, two friendly-fire deliveries to
deleted fixture actors and one message to the absent commander. The dependency
report retains seven startup notices. Three parser regressions, PowerShell
parsing and whitespace checks pass. Both completed servers were stopped by
verified process/profile identity. The rejected first attempt is not counted.

The combined scene regression and observer-positive/client presentation tests
are NOT_RUN. Bodies, wrecks, building changes and parent integration remain open.
The owner subsequently selected abandoned wrecks with no infected-army resource
effects. The wreck adapter must preserve that rule through capture, destruction
and cleanup.

## Retained scene: corpses, blood and original groups

The body component preserves native faction-then-role selection from civilian,
Rebel and Occupant scene categories. It validates prepared scalar-base roles,
rejects missing/malformed definitions and excludes WBK special-creature classes.
Array/weighted base-class definitions are skipped because the safe-position
check and native creation must use the same body. The baseline civilian, FIA
Rebel and Infection categories resolve to 2, 7 and 6 roles respectively.

Creation records the original civilian group, corpse and blood object before
later initialization can fail. The body is killed in the same unscheduled call
as creation. The installed basic walker/middle/runner AI exits for an already
dead unit; the runtime case observes a basic infected corpse remaining dead
without a WBK AI marker or active-infected budget ticket after three seconds.
This is not long-duration reanimation or client-behavior acceptance.

Cleanup retires only those exact objects and original groups, defers near an
observer, rejects remote/foreign cleanup and recovers a partially registered
group. It does not collect unrelated nearby bodies. No conventional infected
combat initialization or resource charge is attached to these scene corpses.

The [135-input Dev5 candidate](../../evidence/sprint-3/liberation-bodies-build.json)
passes [147 focused checks](../../evidence/sprint-3/liberation-bodies-focused.json)
and [11 missing-dependency checks](../../evidence/sprint-3/liberation-bodies-dependencies-absent.json).
Its eighteen body cases use actual native civilian/FIA definitions and a basic
WBK corpse. They exercise role filtering, blocked placement, ownership, blood,
unchanged supplied equipment, unchanged resource/budget totals, cleanup and
partial registration. All production/PBO and 201/163 report-input hashes match.
No engine/SQF Error records occur. Twenty-three focused warnings are retained:
sixteen startup/dependency notices, four object-deletion notifications, two
friendly-fire deliveries to deleted fixture actors and one absent-commander
message. Seven startup notices remain in the dependency-absent report.

The first body fixture was rejected: it omitted native optional-mod detection
variables required by the FIA loader and incorrectly expected FIA scene bodies
to carry rifles. Native FIA loadouts receive weapons later through living-unit
initialization; the native scene does not do that. The corrected fixture uses
the pinned detection expressions and verifies the supplied uniform, weapon
slot and map. Production code did not change between these attempts. Three
parser tests and whitespace checks pass. Completed servers were stopped by
verified identity. Bodies remain separate from the parent until scene lifecycle
integration; combined regression, observer/client behavior, looting and long
duration play remain NOT_RUN.


## Retained scene: abandoned wreck accounting

The owner selected abandoned vehicles with no infected resource effects. Scene
wrecks retain native class weighting, repairable damage, empty fuel, capture,
logistics, and the scene's lock/overturn chances. No crew is created. Civilian
initialization installs the native handlers, then ownership becomes neutral
within the same unscheduled call. The native skin initializer cannot accept
an unknown faction directly. Neutral ownership also avoids the civilian-theft
support penalty. A readiness guard requires compiled civilian skin maps before
creating any vehicle.

Cleanup deletes only exact, unclaimed scene vehicles away from observers. Rebel
capture transfers the vehicle out of scene cleanup; living occupants, attachments
and attached ropes defer deletion. This component does not implement general
abandoned vehicles throughout the campaign.

The [138-input Dev7 candidate](../../evidence/sprint-3/liberation-wrecks-build.json)
passes [170 focused checks](../../evidence/sprint-3/liberation-wrecks-focused.json)
and [11 dependency-absent checks](../../evidence/sprint-3/liberation-wrecks-dependencies-absent.json).
All production/PBO and 205/167 collected input hashes match. The 23 new cases
exercise actual empty vehicle creation, repair/refueling, native AI GetIn capture,
neutral destruction accounting, exact deletion, capture retention, occupied and
attached cleanup refusal, and no infected-resource or town-support changes.
No engine/SQF Error records occur. The 21 focused warnings comprise sixteen
startup notices, two friendly-fire deliveries to deleted actors, two object
deletion notices and one message to the absent commander. The dependency report
retains seven startup notices. Three parser tests and whitespace checks pass.
Both completed test servers were stopped and their exits verified.

Dev6 was rejected because the fixture used uncompiled civilian animation/variant
arrays. Native vehicle initialization stopped before neutralization, exposing
the normal civilian capture penalty. The corrected fixture applies the pinned
compileMissionAssets map conversion; production refuses that incomplete startup
state before creating anything. Its EntityCreated monitor was also corrected
to accept the engine's object event argument.

Full native EntityKilled wiring, player driving, rollover physics, random lock
UI, towing, garage/save behavior, connected observers and combined regression
remain NOT_RUN. Accounting checks stabilize simulation after checking initial
vehicle state. These components remain unconnected until the full scene owns
its creation and cleanup. The owner selected native temporary building damage
restoration; the building component is next.


## Retained scene: temporary building damage and restoration

The owner selected Ultimate's temporary cleanup behavior. The component owns
only pristine, enterable houses that it changes. Existing damage, ruins, hidden
objects, antenna/administration objects, permanent-site areas, HQ proximity and
occupied houses are excluded. Exact record/entry references prevent a copied
record from claiming another scene's building.

A server BuildingChanged handler retains the exact original/ruin pair after
Ultimate's native event and excludes temporary scene ruins from the permanent
destroyedBuildings save list. Unrelated destruction stays in that list. Cleanup
waits for model transitions and for nearby observers/actors to leave. It invokes
native repair for an actual ruin and explicitly clears ordinary partial damage,
which the native helper does not repair. Original world position, direction,
up vector and the native scene door animation phases are restored. The next
tick verifies the model and deletion before retiring ownership and the handler.
If another system deletes the original house, cleanup does not create a replacement.

The [engine investigation](../../evidence/sprint-3/liberation-building-investigation.json)
confirmed native partial-repair refusal and asynchronous collapse/repair on two
vanilla houses. The accompanying mission run failed one preparation-state check;
its old fixture did not capture the values. Code review identified publication
of the prepare phase before its clock was written. That transition is now an
unscheduled transaction, and the check records the actual phase and timestamps.
The corrected run observes the full 180-second preparation interval.

The [141-input Dev8 candidate](../../evidence/sprint-3/liberation-buildings-build.json)
passes [195 focused checks](../../evidence/sprint-3/liberation-buildings-focused.json)
and [11 dependency-absent checks](../../evidence/sprint-3/liberation-buildings-dependencies-absent.json).
The 25 building checks exercise real partial damage, collapse/ruin events,
position/door restoration, protected/occupied refusal, exact ownership, native
save-list separation, unrelated damage preservation and external deletion.
All production/PBO and 210/172 collected input hashes match. No engine/SQF Error
records occur. The 31 focused warnings comprise sixteen startup/dependency
notices, twelve object-deletion notifications, two friendly-fire deliveries to
deleted fixture actors and one message to the absent commander. Seven startup
notices remain in the dependency report. Parser, PowerShell and whitespace
checks pass. Both completed server exits are verified.

The first Dev8 fixture was rejected because the preceding selector test had
emptied the factory-marker list. Moving a marker without restoring its factory
membership did not represent a protected site; the resulting early damage also
invalidated later refusal/door checks. The fixture now sets and restores the
actual factory list. Production code and addon did not change between Dev8 runs.

These are dynamic vanilla-house contracts in VR. Terrain-placed Redux houses,
connected observers, client appearance, saving/loading an active scene and the
combined regression remain NOT_RUN. Roof effects, the complete scene builder
and parent lifecycle integration remain open. Native smoke source/config cleanup
has been inspected separately; it is not yet a tested scene feature.
