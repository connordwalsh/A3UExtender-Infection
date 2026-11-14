# Town liberation: source contracts

The owner selected survivor rescue and defense with a walking infected horde.
This audit pins Ultimate 12.4.2 at `c7c8247672ed5e7d4aa317d47efb371c41de4e7d`;
the [31-file manifest](../../evidence/sprint-3/town-liberation-sources-12.4.2.json)
records the exact inputs. This is source evidence, not runtime acceptance.

## Native entry and ownership

`resourcecheck` evaluates towns every ten minutes while players are active.
A non-destroyed, non-skirmish town can join the Rebels when Rebel support is at
least 1.5 times government support. Population at least twenty and the configured
skirmish roll may replace that political flip with `townBattle`. The normal
caller searches same-side outposts within 3 km, then any same-side outpost;
without any outpost it calls `cityChangeSide` directly. Infection must replace
that source search with the approved nearby town/permanent-site walking policy.
The owner has been asked whether the no-nearby-source case should retain the
political flip or leave the town infected; that decision remains pending.

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

The political fallback when there is no nearby origin still awaits the owner.
No fallback is implemented by these helpers. Native decorative wrecks, damage,
effects and the survivor vehicle also remain part of the full mission audit.

## Parent controller draft (not runtime accepted)

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

The draft adds seventeen mission checks, bringing focused declarations to 96.
They exercise real task metadata, humans/infected, resources and tier calculation;
support/aggression delivery uses the existing observed fixture endpoints.
Preparation, arrival and timer positions are injected. The 126-input Dev2 candidate
builds and the parser/whitespace checks pass, but these new mission checks are
NOT_RUN while the earlier candidate's combined regression occupies the test port.
Do not treat this paragraph as mission or campaign acceptance.
