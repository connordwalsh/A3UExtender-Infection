# Liquidation Assignment

Current candidate: Dispatch Dev1 passes 764 combined dedicated-engine checks,
37 focused dispatch checks and 11 actual missing-dependency checks. All 138
production inputs and the PBO match its recorded manifest. No Computer Use was performed; visual menus, connected
players, save/restart and complete campaign acceptance remain open.

## Approved behavior

Requested conquest missions become infected-only clearance assignments at towns,
administrations, outposts, seaports, factories, resource sites and native
conquest-eligible road controls. Military bases and airfields require war level
3. Native field controls remain excluded. Selection retains Ultimate 12.4.2's
HQ range and sorting; an attacking faction or nearby horde origin is unnecessary.

The task uses the requested title and briefing. Clearing the assigned infected
captures the location for the Rebels, including towns without sufficient
political support. A Russian takeover cancels without mission rewards or
penalties, even if Rebels immediately retake the location. Native consequences
of losing territory still apply.

The owner authorized judgment using Ultimate's existing timers and rewards.
The CON_Outpost baseline supplies normal/difficult 90/45-minute limits,
600/800 faction money, 250/450 per-player money, 10/20 player and commander
score, and 100/200 commander money. Native support and infected-resource timing
effects are retained. Timeout uses native penalties. Dependency loss, broken
site actors and interrupted workers cancel without mission penalties.

## Capture and task lifecycle

A site visit records obligations for queued and live defenders. Killed events
count once; live deletion is not kill credit. Healthy active controllers, no
pending defenders or garrison updates, and zero outstanding obligations are
required. A later visit follows its native regeneration rules.

Exclusive CON claims precede task registration. Permanent-site, town, road-control
and administration ownership paths recheck clearance atomically immediately
before the ownership write. Military restrictions and deadlines are rechecked.
A foreign takeover freezes cancellation; a later retake cannot turn it into a win.
Without a pending claim, ordinary capture rules remain active.

The permanent-site adapter retains the pinned native markerChange body apart
from its include and guarded ownership transaction. Native flag, QRF, support,
resource and notification work remains scheduled. Town maintenance retains its
five-second delay independently of the caller. A failed administration write
retains the capture_failed fault; blocked clearance remains retryable.

Capture workers are independent of the task loop. The watchdog waits for both
before retiring the claim, and settlement is once-only. Success/failure tasks
use native average 20-minute retention; cancellations retire promptly. Native
task metadata remains authoritative after interrupted registration.

## Requests and direct callers

The mission board's CON request waits for an existing native request lock,
preserves the Petros leader gate and notifications, and selects an eligible
infected location. Its atomic CON claim prevents duplicates without taking
ownership of the shared request lock. Stopping a waiting request cannot clear
another request's lock. Remote/unscheduled calls enter a local scheduled context.

All four native conquest entry points (ordinary, competitive, zombie and military
administration) route to this controller while Infection is active. Scheduler
calls stay on the server; registered HC relays accept only server-origin calls.
Ineligible Russian targets never fall back to legacy human missions. Ordinary
campaigns and missing-dependency configurations retain native delegation.

Modern and legacy conquest buttons receive the Liquidation title and tooltip
when Infection is active; their native bases and actions remain intact. Loaded
config inheritance is tested; visual rendering has not been tested. The seven
superseded competitive helpers and their 34 obsolete cases are removed. Strategic
hordes are separate and remain unchanged. The other five replacement categories
still delegate to native implementations until their behavior is completed.

## Evidence and limits

- Capture Dev2: 44 focused and 750 combined checks. Its two rejected fixtures are
  retained; missing native setup and premature namespace cleanup caused errors.
- Controller Dev3: 33 focused and 11 actual missing-dependency checks. It fixes
  administration write-failure propagation. An interrupted fixture's task-text
  type assumption was corrected against installed native function source.
- Dispatch Dev1: 37 focused checks (11 common plus 26 dispatch cases), no engine
  or SQF errors, 16 retained startup/dependency notices. It covers real task
  creation through all endpoints, server scheduler routing, duplicate requests,
  remote context, foreign locks, unavailable targets, military tiers, ordinary
  delegation, menu config inheritance and cleanup.

See evidence/sprint-4/liquidation-dispatch-focused.json and
liquidation-dispatch-build.json. The exact loaded addon SHA-256 is
c1fc2038f75de98ef269d91523c668959ee36ab19bb12030da69f46f6bc232b4.
The integrated combined run passes all 764 checks with no engine/SQF errors.
Its 71 retained warnings comprise 16 startup/dependency notices, 50 object-deletion
notices and five notifications targeting the absent fixture commander. The actual
missing-dependency run passes 11 checks with seven startup notices and no errors.
Both isolated servers were stopped and their exits verified. The reports are
liquidation-dispatch-combined.json and liquidation-dispatch-dependencies.json.
Earlier component evidence remains separate from this integrated result. Fixtures use controlled campaign records and notification
hooks. Actual player/commander reward receipt, visual UI, HC/client connections,
Redux travel, performance, saves and complete missions remain unverified.
