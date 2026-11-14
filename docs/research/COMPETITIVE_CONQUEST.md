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

This separate branch contains an unvalidated prototype. Conquest selection keeps
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

Configuration conversion and packing passed for the initial prototype; subsequent
review edits still need rebuilding. All runtime cases are **NOT_RUN**. Required
checks include no-origin/no-route/cooldown rejection, no ordinary downgrade,
request/scheduler delegation, remote-context handoff, real births/costs,
immediate first-capture failure, same-frame retake, success/timeout rewards,
duplicate requests, interrupted workers and empty final task/group/budget state.
Connected-player UI, actual HC relay, Redux missions and persistence remain open.
