# Liquidation Assignment

Current candidate: Controller Dev3 passes 33 focused and 11 missing-dependency
checks. The parent capture-only candidate passed 750 combined checks. Public
mission dispatch and a combined controller run remain pending. The sections
below retain the progression from selector draft to validated controller.

Owner-approved replacement for requested conquest missions. Targets are infected
towns and sites; clearing the assigned infected captures the location for the
Rebels. The former race-to-capture objective is superseded. Bases and airfields
remain restricted to war level 3. A Russian takeover cancels the assignment
without a penalty. The owner permits developer judgment using Ultimate's timers
and rewards as a starting point.

## Target selection draft

`liquidationTargets` uses Ultimate's `findIfNearAndHostile` distance/sorting rule
around Petros, then restricts candidates to infected ownership. The candidate
families are towns, administrations, outposts, seaports, factories, resource
sites, and native conquest-eligible road controls. Military bases and airports
join at war level 3; duplicate list membership cannot bypass that restriction.
Field controls retain their native exclusion from conquest selection. No nearby
attacking faction or horde origin is required for a clearance assignment.

The helper neither requests a task nor captures territory. Existing mission
dispatch is not connected to it yet. The 11 authored selection checks cover
families, duplicate lists, tier restrictions, ownership, distance, field-control
exclusion, missing dependencies and missing HQ. All 11 selection cases plus
11 shared cases pass in the isolated dedicated engine run. The report retains
16 startup/dependency notices and no engine/SQF errors. All 129 production
inputs and the PBO match the Dev1 manifest. Config/PBO packaging and three
parser tests also pass. See `evidence/sprint-4/liquidation-targets-focused.json`;
the older draft receipt records the earlier NOT_RUN checkpoint.

## Capture integration constraints

The parent branch supplies the site clearance ledger and read-only predicate.
Pending queued defenders, living assigned actors, healthy deleted actors,
missing/stopped controllers and pending persistent garrison updates cannot count
as clearance. A later visit uses its own ledger and native regeneration rules.

Native `markerChange` can capture a permanent site before its entire garrison is
dead, so an active Liquidation claim must guard that transition. Native town
politics can bypass `markerChange` through `cityChangeSide`; that route also
needs the full-clear guard while the assignment is active. Control and
administration transactions require explicit integration rather than assuming
all captures pass through one function.

Do not put the entire native capture function inside an unscheduled block:
`markerChange` contains sleeps in its aftermath, and `cityChangeSide` delays
maintenance by five seconds. The clearance recheck and actual ownership commit
must be atomic, with delayed work retained separately. A stale success check
must not allow a reinforcement arriving between the check and capture to vanish
or surrender. Preserve site QRFs, campaign support/resource changes, native
administration completion and the war-level restriction.

The remaining lifecycle includes task registration, success/timeout/cancellation,
once-only rewards, stopped-worker recovery, task deletion and ordinary-campaign
delegation. New mission text must not be attached to a legacy competitive task
that still launches an attack on Russian targets. End-to-end gameplay, saves,
connected clients and terrain travel remain unverified.


## Claim-driven capture component

Dev2 introduces an atomic ownership transaction shared by permanent-site, town,
road-control and administration capture. A pending claim requires the full
clearance ledger immediately before a Rebel ownership write, retaining military
war-level restrictions and the mission deadline. A real Russian capture freezes
cancellation before delayed effects; a same-frame Rebel retake cannot change it
to success. No rewards are issued by this component.

The permanent-site adapter retains the pinned native markerChange body except
for the include path and ownership transaction; a reconstruction comparison is
identical to the pinned source. Native QRF/resource/flag/notification handling
remains scheduled. Town capture preserves the native Rebel effects and schedules
the five-second maintenance independently of the caller. Existing control and
administration rules call the same transaction in their unscheduled capture
paths. Without a pending claim their ordinary capture behavior remains active.

The focused dedicated suite passes 44 checks: 11 common, 11 selection and 22
capture cases. It exercises actual native site ownership effects, server remote
calls, political town capture, road controls and the administration completion
registry using controlled campaign records. No engine/SQF errors occur. The
fixture fixes its garrison preference tier rather than testing preference
regeneration; connected players, visual UI and complete missions remain untested.
Two rejected fixture runs are retained: missing native initialization values and
premature retirement of the spawner namespace caused errors despite true
assertions. The corrected result is `liquidation-capture-focused.json`.

The combined Dev2 regression passes all 750 checks with no engine/SQF errors.
All 133 production inputs still match its manifest. Task claim creation, automatic capture on
clearance, once-only rewards, timeout/interruption recovery, task removal and
mission-board/direct dispatch still need implementation. No active gameplay
flow creates a Liquidation claim yet, so the six-mission redesign is incomplete.


A later controller review found that the new administration wrapper returned
false before preserving the older `capture_failed` fault when the native
transaction attempted but did not change ownership. PR #25 restores that fault
only after a real attempted write; blocked clearance does not create a fault.
Its dedicated controller case checks cancellation without penalty. Keep this
component draft until that correction and task integration are validated.


## Task controller draft

A separate controller branch adds CON task registration and an exclusive target
claim, the requested title/briefing, automatic capture after full clearance,
polled cancellation/timeout handling and once-only settlement. The native
CON_Outpost baseline supplies 90/45-minute limits and normal/difficult rewards:
600/800 faction money, 250/450 per-player money, 10/20 player and commander
score, and 100/200 commander money. Native support and infected resource timing
effects are retained. Timeout retains native penalties; Russian takeover, missing
dependencies, broken site actors and interrupted workers cancel without mission
rewards or penalties. Native consequences of losing territory still apply.

Capture runs in an independent owned worker. Stopping the task loop cannot stop
its delayed native flag handling; the watchdog waits for both workers before
retiring the claim. Completion/failure uses native average 20-minute task
retention, while cancelled tasks retire promptly. Cleanup reads native task
metadata, including interruption between registration and its local flag.

The 21 controller cases are authored but NOT_RUN. Packaging, 139 production
hashes and three parser tests pass for Controller Dev2. The parent's combined
capture regression is still running; this worktree has not started another
server. Mission board/legacy endpoints remain unconnected, and the six-mission
redesign, connected-player rewards, saves and campaign acceptance remain open.


## Controller focused validation

Controller Dev3 passes 33 dedicated checks: 11 common and 22 controller cases.
They cover the native registered task and requested text, exclusive claims,
blocked clearance/despawn, automatic permanent-site/town/administration capture,
normal and difficult rewards applied once, normal/difficult timeouts, Russian
cancellation without mission penalty, dependency/site failure cancellation,
stopped-worker recovery, partial registration, missing task metadata, remote
internal-call rejection and complete fixture cleanup. An actual flag capture
remains alive after terminating its parent task loop, finishes its native
markersChanging lock, and settles once.

This candidate restores the older administration capture_failed fault only if
the native write was attempted and failed; ordinary clearance refusal remains
retryable. Its targeted controller case passes and cancels without penalty.
The initial controller fixture halted on a wrong task-description type
assumption. Installed Arma source shows literal texts stored as arrays; the
corrected assertion and source hashes are recorded in native-task-text-api.json.
The production build was unchanged during that fixture correction.

All 139 production inputs and the PBO match Controller Dev3. The focused report
contains no engine/SQF errors and retains 21 warnings: 16 startup notices and
five native income notifications targeting the absent fixture commander.
The earlier capture-only Dev2 passed 750 combined checks; a combined run of
the complete controller candidate has not been run. Actual player/commander
reward receipt, visual tasks, terrain, save/restart and multiplayer remain open.
Mission-board and direct legacy dispatch are the next integration work.

The actual Controller Dev3 missing-dependency run also passes 11 checks, with
seven startup notices and no engine/SQF errors. All test servers were stopped
by verified process/profile identity, with exit confirmed.
