# Review record

## 12 November 2026 — Sprint 0 foundation and test tooling

Scope: product decisions/backlog, pinned dependency inventory and source
comparison, isolated launch/build scripts, prepared-class smoke fixture and
evidence collector, and the proposed Occupant impact matrix. This review does
not accept the Infection gameplay addon or close Sprint 0.

Developer self-review, as authorized by the product owner:

* Inspected the authored tools and documentation. The inherited gameplay examples
  remain outside the test launch stack. Mod archives, profiles, raw logs and
  third-party extracted source are excluded from Git.
* CfgConvert and FileBank produced the working standalone fixture. The original
  incomplete Eden structure was replaced after a reproducible launch loop.
* All 14 prepared classes completed the dedicated spawn/init/equipment/deletion
  checks. Model/skeleton/attachment errors on the large creatures remain open;
  the report correctly requires review despite its passing smoke assertions.
* The collector rejected a real non-starting log as incomplete. It requires
  unique complete records and the full candidate set, and does not publish raw
  player identifiers or absolute local paths.
* Python compilation, PowerShell syntax parsing and Git whitespace checks passed.
  Launchers isolate profiles and protect the owned probe install with a hash
  receipt. Repeated starts are rejected instead of sharing the same profile.
* The matrix names source owners, proposed changes and acceptance scenarios;
  source paths/hashes are verified against the pinned checkout. Remaining caller
  audit, the signed S3 route disposition and complete S4 mission catalog are open.

Integration decision: the foundation/tooling can merge independently. Keep S0-1,
S0-2 and S0-3 open for the documented remaining evidence. No user acceptance,
clean gameplay certification or Workshop release is implied.

## 13 November 2026 — Registration scaffold

Self-review covers the unique addon/template registration, dependency facts,
67 prepared-class roles, isolated build scripts and contract fixture/collector.
No upstream function is overridden by this change. The real Ultimate loader and
creator completed 83 checks; the missing-dependency fixture completed ten checks.
Vehicle pools remain deliberately empty and their campaign consumers remain an
open implementation task. README and registration notes identify this limitation.
The latest full test completed before the previous halt; collection now includes
its completion record. Startup warnings are retained rather than hidden.

Integration decision: preserve this as a reviewable development scaffold. It
does not complete Sprint 1 or authorize a campaign/release claim.

## 13 November 2026 — Foot garrison-line contract

The narrow CfgFunctions override checks both Infection selection and runtime side
before replacing the virtual line builder. The installed Ultimate implementation
is retained under an alias for other factions and missing dependencies. It does
not edit shared preference arrays, create live AI, or invent vehicle placeholders.
The override ledger records the pinned source and remaining caller boundaries.

Validation: 94 isolated dedicated checks passed, including every inherited
preference at fixed and weighted tiers, no infected vehicle selector calls,
normal WEST/EAST delegation, malformed input, original initial-roster/ratio
consumers, and the 67 unit-spawn regressions. No SQF/engine error records were
detected; the previously recorded startup warnings remain. The build used a new
directory so the owner's running client retained its earlier addon unchanged.

Integration decision: this contract change is reviewable independently of the
remaining site, reinforcement, capture and save work. Those stories stay open.

Amendment: later inspection found the vehicle-query counter was not installed
in the 94-check run. Its zero-query assertion is withdrawn and superseded by the
corrected 120-check run, which observes five control calls and zero infected calls.
See `../research/VALIDATION_CORRECTIONS.md`; the older review is not silently erased.

## 13 November 2026 — Prepared infected combat bookkeeping

Self-review covers the guarded NATOinit override and direct original alias,
preservation of prepared-class handlers/AI/health/identity, Ultimate event and
resource contracts, and once-only kill/delete processing. Human revive and
surrender classification are omitted only for the three registered basic types.
An explicit spawner parameter preserves the upstream inactive-site exception.
Adapted source attribution is included in the built mod.

Validation: 120 dedicated checks passed on installed/source-matched Ultimate
12.4.2, including the 67 roles, corrected vehicle-query instrumentation, actual
rifle deaths, resource debits/refunds, garrison ownership races, postmortem events,
duplicate callbacks and complete fixture cleanup. Eleven missing-dependency
checks passed without the test endpoint addon. Endpoint observations do not prove
the campaign's actual task/support UI/economy behavior. Connected-player credit,
ACE, headless transfer, JIP and campaign integration remain unaccepted.

The first combat harness was rejected because it tried to reassign protected
functions; test-only config overrides now install the endpoints before compilation.
Three parser regression cases pass and unknown bare tokens remain invalid.
The collector retains startup warnings and rejects project function-override
failures. The full report records no engine/SQF error lines.

Python AST parsing, PowerShell syntax and Git whitespace checks passed. The
collector rejected a truncated run, a duplicate check and a protected-function
override; the fixture builder rejected rebuilding the addon used by the running
probe. Completed combat/dependency servers were then stopped by their exact
owned profiles; the separate behavior observation batch continues.

Integration decision: merge this scoped increment after the recorded checks;
continue S0/S1 and live site implementation. It is not campaign or release acceptance.

## 13 November 2026 — Server spawn reservation component

Self-review covers allocation before creation, atomic unscheduled mutations,
server-origin guards, shared context ceilings, partial grants, unique binding,
once-only release, closing/cancellation and expired leases. CBA settings are
server-controlled and do not activate the faction. Reducing a limit trims pending
slots in allocation order and preserves living actors. Internal records are
transient and are never broadcast or written to a save.

Validation: all 140 dedicated checks passed, including 20 new budget cases and
the complete combat/template/garrison regressions. Twenty competing requests
received exactly eight available slots. Deletion/cancellation assertions inspect
raw records before reconciliation, avoiding a misleading cleanup-only pass.
The expiry case waited 31 seconds and kept the existing bound actor. Eleven
dependency-absent checks also passed. No engine/SQF errors were recorded; existing
startup warnings remain. The first attempt's inherited-argument error correctly
failed its report and was fixed before acceptance. Python parser regressions
and Git whitespace checks passed.

Integration decision: merge the API component as a prerequisite for S2 callers.
S5-1 stays open for actual callers, spatial rules, cooldowns, special-creature
accounting and performance. No campaign-wide cap or multiplayer acceptance is
claimed by this isolated server proof.

## 13 November 2026 — Full queued garrisons at six persistent sites

Self-review covers the four guarded site entry points, narrow scheduler routing,
full-roster queues, budget preflight/binding, bounded terrain/geometry placement,
HQ and observer exclusions, capture guards, surrender bypass, asset handling,
distance cleanup, and recovery after stopped scripts. The owner explicitly chose
full garrisons with gradual arrivals. No virtual roster entry is consumed by a
refused spawn. Native death bookkeeping remains the saved-roster owner.

Validation: 194 dedicated assertions passed on Ultimate 12.4.2, including 36 site
checks, 17 placement/spawn checks, 21 budget checks and the earlier regression
suite. Six site types completed initial spawn, partial clear, cleanup and reentry.
The fixture observed later arrivals, movement, preserved moved loot, released
spawn places, ownership cancellation, duplicate suppression, automatic recovery
and empty final actor/group/budget/controller state. The missing-dependency run
passed 11 checks. No SQF/engine Error records were detected; startup warnings and
object-not-found messages are preserved. Source and PBO hashes matched the
recorded build. Python parser regressions, PowerShell syntax and whitespace
checks passed. Completed test servers were stopped by their exact owned profiles.

The first invalid-role branch exposed a real implementation error and was fixed.
Two asynchronous test assumptions were corrected to inspect the state at the
actual setting-change/script-stop boundary. A separate review check confirms
remote calls cannot remove another system's recurring handler. Earlier failed
runs are not counted as passing evidence.

The fixture records arsenal/logistics/worker/UI and original-route endpoints;
it does not certify those campaign effects. The 112 prepared-class observations
are also recorded with their seven special ownership/deletion failures and
large-creature model errors, not presented as a blanket behavior pass.

Integration decision: merge this scoped site increment. S2/S5 and all campaign
gates remain open for other site types, reinforcement/mission routes, actual
ownership/save cycles, Redux pathing, connected players and performance. No
Computer Use, client launch, Workshop publication or release claim is included.

## 13 November 2026 — Infected road and field controls

Self-review covers the guarded creator/scheduler, source-derived infantry weights,
transient role queues, safe budgeted creation, independent ownership versus
garrison-bookkeeping markers, capture predicates, calendar resets and shared
watchdog cleanup. Ordinary faction/dependency paths retain installed-file aliases.
No transport, static, UAV or mine pool is queried by the infected control path.

The control capture transaction requires actual spawned defenders, no pending
roles, no fighting defender still arriving or holding the radius, and a nearby
eligible Rebel/Invader. This prevents the upstream empty-spawn/remote-winner case.
Former vehicle crew roles become foot defenders. Generated controls keep the
120 campaign-minute reset, cancel stale ownership, defer while active, and handle
year/leap boundaries. Records remain transient, matching upstream's waiting script.

Validation: all 231 dedicated checks passed, including 37 new control cases and
all earlier regressions; the missing-dependency suite passed 11. No SQF/engine
Error records were detected. Twenty-seven warning messages are retained in the
main report. The tested PBO and all 40 addon source files match the build manifest.
Python parser tests, PowerShell parsing and whitespace checks passed. Completed
servers were stopped using their verified test-profile process IDs.

The first run failed two fixture expectations that assumed a four-unit fireteam.
The pinned source actually contains six roles despite its four-man comment;
with the foot guard the correct total is seven. No production code change was
needed. The corrected fixture explicitly sets its tier mode and passed the full
run. The failed run is not accepted evidence.

Integration decision: merge this scoped control increment. The VR fixture checks
road selection with explicit road/frontline inputs and actual off-road routing;
it does not prove Redux road geometry, client notifications, wider roaming,
campaign saves or multiplayer. S2/S5 and all campaign gates remain open. The owner
subsequently approved per-visit town regeneration and administration strongholds
with survivor rescues; both remain future implementation work. No
Computer Use, client launch or Workshop publication was performed.

## 13 November 2026 — Per-visit infected town patrols

Self-review covers the guarded town creator/scheduler, source-derived selection,
shared transient patrol controller, bounded outdoor routes, retry deadlines and
ownership/cleanup boundaries. The owner's per-visit regeneration choice is
preserved. Normal towns use police pairs, frontline towns use tiered pairs and
ruined towns use approved basic infected on WEST. Patrols do not mutate the saved
town garrison or directly capture towns; native support/ownership callbacks remain.
The route helper preserves WebKnight combat/health behavior and uses checked
ground destinations, with no unchecked-center fallback.

The first run exposed a real shared-budget defect: an older ticket permanently
cached the lower server context setting. Tickets now retain their caller's
ceiling, so raising a server setting permits new capacity while an explicit
caller limit remains binding. Two budget regressions and the real town queue
exercise this case. An unsuccessful initial route search also has its own retry
deadline, avoiding two searches in the same controller pass.

Validation: 264 dedicated checks and 11 dependency-absent checks pass, including
31 town checks, both new budget regressions and all prior coverage. The strict
collector found no engine/SQF Error records and retained 32 warnings for review.
The tested PBO and all 43 source files match the manifest. Python parser tests,
PowerShell syntax and whitespace checks pass. Completed test servers were stopped
using verified owned profile IDs.

Two site fixture boundaries were corrected: flags become null on the next engine
frame, and a group follower may initially regroup away from the marker. The
revised test observes the living leader's approach before killing a defender;
the separate full-roster arrival and cleanup assertions remain. An intermediate
run reported all assertions passing but truncated an oversized diagnostic line;
the collector rejected it. Neither failed/incomplete-evidence run is accepted.

Integration decision: merge the scoped town increment. Repeated patrol circuits,
Redux pathfinding, post-casualty group movement, support/UI effects, campaign
saves, multiplayer and performance remain acceptance work. Administration,
reinforcement and mission routes remain unconverted. No sprint gate is closed,
and no Computer Use, client launch or Workshop publication was performed.

## 13 November 2026 — Administration strongholds and survivor rescues

Self-review covers the guarded administration creator/removal paths, server
dispatch, full transient roster, queued arrivals, engine-event death accounting,
ruined-building reentry, validated interior assets and once-only survivor release.
The owner's per-visit regeneration choice is preserved. Capture requires every
defender to be defeated even after destruction; optional rescues do not alter
the clearing predicate. Living deletions requeue instead of counting as kills.
Server completed-site loading remains available without a client bypass.

Validation: all 301 dedicated checks and 11 dependency-absent checks pass. The
37 administration cases include actual engine destruction/death, native capture,
Rebel initialization, escape orders and HR updates. Capture succeeds with an
unrescued captive and after a ruined stronghold is cleared. Repeated, interrupted
and dead-survivor releases cannot duplicate rewards. Cleanup and stopped-script
recovery leave no fixture actors, groups, reservations or recurring handlers.

The strict collector found no engine/SQF Error records and retained 43 warnings:
dependency animation/final-function notices, object deletion messages and a
mission dependency warning. The PBO and all 57 addon sources match the manifest.
Three Python parser tests, PowerShell syntax and staged whitespace checks pass.
Both completed servers were stopped by verified owned profile IDs. The earlier
focused 47-check pass is development evidence, not the final full-suite result.

Integration decision: merge this scoped stronghold increment. UI/logistics and
ordinary-route endpoints are recorded by the fixture; connected-player action
and JIP behavior, Redux rooms, true distance-despawner completion, mission wording,
destruction-triggered foot responses and cooldown persistence remain open. No
campaign or sprint gate is closed. No Computer Use, client launch or Workshop
publication was performed.

## 13 November 2026 — Routine infected foot reinforcement

Self-review covers the guarded patrol and mixed-cycle adapters, native deficit
and quota selection, cooldown/combat rules, original queue priority, land-only
source eligibility, bounded paid spawning, atomic arrival and context transfer,
and observer-aware cleanup/recovery. The non-Infection mixed-cycle lines match
the pinned source after removing the explicitly documented adapter and include
changes. Other factions retain their installed patrol alias.

Validation: all 340 dedicated checks and 11 dependency-absent checks pass. The
39 reinforcement cases cover virtual and live repair, costs, exhausted resources,
ownership changes, partial arrival, destination-cap pressure, once-only adoption,
native garrison death/reentry, deadlines and stopped-controller recovery. The
fixture uses a synthetic connected road graph and observes movement separately
from injected arrival positions. It does not certify completed long walks.

Rejected development attempts exposed an empty preprocessed test body, sampling
before asynchronous refunds arrived, and an arrival injection that left a follower
at its origin. The corrected fixture explicitly verifies complete arrival and
retains a partial-arrival refusal case. Scheduled route caching also keeps native
path searches out of the atomic commit. These corrections and the complete
regression suite pass together on the final candidate.

The strict collector records no engine/SQF Error records and retains 46 dependency
startup and object-deletion warnings. The PBO and all 66 addon files match the
recorded manifest. Parser regressions, PowerShell syntax and whitespace checks
pass. Completed test servers were stopped by verified owned profile IDs.

Integration decision: merge this scoped repair increment. Redux navigation,
connected-player observation/cleanup, restart persistence and actual Invader
campaign behavior remain acceptance work. Native roaming, QRF/attack, mission
and other positive garrison-update paths are still unconverted. No campaign or
sprint gate is closed; no Computer Use, client launch or Workshop publication
was performed.

## 13 November 2026 — Bounded infected roaming patrols

Self-review covers mixed-faction selection, the infected source/cooldown policy,
actual outdoor navigation endpoints, bounded route search, shared native patrol
count, partial budgeted creation, cyclic foot waypoints and observer-aware
cleanup/recovery. Infected seaports supply land patrols. Ordinary seaport boat
eligibility is exercised separately, and the ordinary vehicle-patrol body matches
the pinned original after the documented include/dispatch/selector changes.

Validation: all 377 combined dedicated checks and 11 dependency-absent checks
pass, including 37 roaming cases. The fixture observes real movement, delayed
budgeted arrivals, legacy death cost, saved-roster neutrality, source/route loss,
timeout, interrupted creation and once-only patrol-count release. Navigation uses
a synthetic road graph and selection uses AI observation anchors. This does not
certify actual players, full walking circuits or Redux geometry.

The first run failed on a real position-return bug in the route helper and an
omitted fixture tier setting. Both were corrected before the focused 47-check
pass. Review then identified the native navigation helper's vehicle-spawn redirect;
the final candidate uses the actual outdoor points, and the combined suite proves
that a missing vehicle spawn marker cannot invalidate that foot route.

The strict collector records no engine/SQF Error records and retains 47 dependency
startup/object-deletion warnings. All 73 addon sources and the PBO match the
manifest. Parser regressions and PowerShell syntax pass. Two trailing-space lines
are intentionally retained inside the otherwise unchanged upstream vehicle-patrol
body; the whitespace check excludes that known end-of-line condition. Completed
servers were stopped by their verified profile/process IDs.

Integration decision: merge this scoped roaming increment. Redux travel,
connected-player cleanup, real Invader vehicle behavior, restart persistence and
performance remain acceptance work. The next response audit records 27 pinned
source files and identifies separate mixed-factory/support payment owners and
no-force task/cleanup gaps. No campaign or sprint gate is closed. No Computer Use,
client launch or Workshop publication was performed.

## 14 November 2026 — Town population selection checkpoint

Self-review confirms that `getCityData` stores population at index 0, distinct
from vehicle count and both support fields. The approved one-per-three ratio
replaces size/support/frontline count scaling and produces exact rounded totals,
including partial final groups. Selection rejects invalid population data and
non-infected ownership. Basic role selection and per-visit lifecycle remain intact.

All 46 focused checks pass without engine/SQF Error records; 35 are town checks.
The initial standalone attempt lacked campaign fixture globals and is rejected.
The corrected fixture tests real casualties, queues, ownership and cleanup with
four actors, and large-town roster calculations without spawning hundreds. The
PBO and all 80 addon sources match the archived manifest; Python parser checks,
PowerShell syntax and whitespace checks pass. The completed server was stopped.

This is not dense-spawn acceptance. Activation policy awaits the owner's answer;
the original active caps, pacing and routes still apply. Keep this feature branch
unmerged until the remaining spawning work is implemented and verified. It is
stacked on the paused counterattack feature, whose full regression is incomplete.
The user's manual client was not controlled or restarted. No Computer Use occurred.
