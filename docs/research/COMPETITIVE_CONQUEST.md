# Competitive conquest prototype

The owner chose two rules on 14 November 2026: an infected conquest race is
unavailable if no nearby infected town or permanent site can send a walking
horde; if that horde captures the objective first, the mission fails immediately.
There is no downgrade of an unavailable race to a normal capture mission.

The [pinned source audit](../../evidence/sprint-3/competitive-sources-12.4.2.json)
covers native request selection, direct/HC scheduling, ordinary conquest,
competitive conquest, task metadata and reward accounting. The native competitive
constructor chooses an airbase, launches two/four/six waves, and leaves the task
open after the rival side captures the site. Those are the integration points.

This separate branch contains a prototype under isolated validation. Conquest selection keeps
ordinary-faction frontlines and adds nearby infected town origins. An unavailable
infected frontline is removed from both competitive and fallback ordinary lists.
Existing ordinary missions outside those frontlines remain available. Unrelated
mission case bodies retain the pinned native source, with installed aliases for
inactive templates/dependencies and explicitly requested non-conquest missions.

Infected competitive jobs stay on the server, claim one CON task, launch one
shared-budget horde and record the first native capture event. A local-frame
handoff clears remote execution context before the worker. Native CON rewards,
penalties and time limits remain; cancellation and interrupted startup grant
neither. The horde owns its actors and cleanup, while the CON controller owns
the task and reward transaction. An explicit parent token links them for recovery
if the CON worker stops before receiving the horde launch result.

Source review preserves native remote capture events: the server verifies actual
ownership and records the first result atomically, then settles on a local frame.
A caller cannot manufacture a capture by submitting an unverified winner. The
polling recovery checks the deadline before ownership, matching the event path.
Native task metadata also owns cleanup if startup stops between registration and
the controller's local registration flag. The separate retired-group fix from
PR #16 is included.

Configuration conversion, packing and three collector parser regressions pass
for Dev3, which also passes [11 missing-dependency checks](../../evidence/sprint-3/competitive-dependencies-absent.json).
Its [manifest](../../evidence/sprint-3/competitive-build.json) pins the artifact.
The first Dev4 focused run passed 43 of 44 checks, with no engine/SQF Error records.
Its deadline fallback check observed the controller's settled flag before Ultimate
applied the queued FAILED task state. The fixture now waits for that required task
state as well, within the same deadline; production outcome logic is unchanged.
The native remote capture case also injects an immediate same-frame retake and
records the first result before polling could conceal an event failure. The
revised focused fixture declares 34 mission cases plus 11 common checks. Its
retake injection initially used a local-only ownership update after native
public capture; the observed owner reverted to WEST while the task correctly
remained failed with no reward. Publishing the injected retake, as native
ownership changes do, establishes the intended GUER owner and retains failure.
A separate observation wait now includes the controller's completed batch and
remaining queue, rather than sampling immediately at the second actor's debit.
The assertions and deadlines remain intact; rejected attempts stay unaccepted.
Required
checks include no-origin/no-route/cooldown rejection, no ordinary downgrade,
request/scheduler delegation, remote-context handoff, real births/costs,
immediate first-capture failure, same-frame retake, success/timeout rewards,
duplicate requests, interrupted workers and empty final task/group/budget state.
Connected-player UI, actual HC relay, Redux missions and persistence remain open.
Native income notifications addressed to the absent fixture commander produce
null-target warnings; the collector retains those warnings. Commander/player
reward delivery is not claimed by these dedicated checks.

## Passing focused checkpoint

The [45-check focused report](../../evidence/sprint-3/competitive-focused.json)
passes on the [117-input Dev4 candidate](../../evidence/sprint-3/competitive-validated-build.json),
with no engine/SQF Error records. The same production candidate passes
[11 missing-dependency checks](../../evidence/sprint-3/competitive-dev4-dependencies-absent.json).
The first native remote capture is observed as `lost_race` inside its event,
before polling; an immediate public retake leaves FAILED and grants no reward.
Both success reward levels, timeout/cancellation, duplicate/refused requests,
server dispatch, real bounded births/refunds, partial registration and child
recovery pass. The full stacked 684-check regression is running before integration.
