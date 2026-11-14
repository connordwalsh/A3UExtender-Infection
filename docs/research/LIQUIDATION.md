# Liquidation Assignment

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

The combined regression is running. Task claim creation, automatic capture on
clearance, once-only rewards, timeout/interruption recovery, task removal and
mission-board/direct dispatch still need implementation. No active gameplay
flow creates a Liquidation claim yet, so the six-mission redesign is incomplete.


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
