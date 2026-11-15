# Review record

## 12 November 2026 â€” Sprint 0 foundation and test tooling

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

## 13 November 2026 â€” Registration scaffold

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

## 13 November 2026 â€” Foot garrison-line contract

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

## 13 November 2026 â€” Prepared infected combat bookkeeping

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

## 13 November 2026 â€” Server spawn reservation component

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

## 13 November 2026 â€” Full queued garrisons at six persistent sites

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

## 13 November 2026 â€” Infected road and field controls

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

## 13 November 2026 â€” Per-visit infected town patrols

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

## 13 November 2026 â€” Administration strongholds and survivor rescues

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

## 13 November 2026 â€” Routine infected foot reinforcement

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

## 13 November 2026 â€” Bounded infected roaming patrols

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

## 14 November 2026 â€” Town population selection checkpoint

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

## 14 November 2026 â€” Capture counterattacks and full town populations

Self-review covers paid foot response selection, source ownership/combat checks,
bounded staging, native distance activation and capture, partial/virtual garrison
adoption, once-only accounting, cancellation and stopped-controller recovery.
The town review covers the approved 400/200 shifted logistic with its unchanged
coefficient, independent population allowances, complete activation, bounded
outdoor placement/routes, ownership handoffs and native per-visit regeneration.
The owner's final clarification retains native conventions for interrupted
ownership changes; no special recapture refill or casualty reset is introduced.

Validation: all 464 combined dedicated checks pass, including 51 counterattack
and 67 town cases. The final focused town suite passes 78 checks and the final
dependency-absent suite passes 11. A 200-actor town and 21-actor neighbor coexist
with shared-budget actors; removal leaves no fixture actors, reservations or
controllers. All 49 pinned Redux populations agree with the selected curve and
the plotted artifacts. The native political ownership transaction and captured
town activation are exercised separately.

Two ownership-timing attempts were rejected because the fixture's local write
was superseded by the native public ownership transaction. The corrected fixture
uses native public writes, observes the current owner at handoff and passes in
both focused and combined runs. The earlier interrupted counterattack regression
remains incomplete evidence; the 453-check pre-handoff town regression is retained
as a separate earlier candidate, not substituted for the final 464-check result.

The strict collector records no engine/SQF Error records. Its 61 retained warnings
include dependency animations/final-function notices, a mission dependency notice
and 45 object-deletion messages. These are reviewed and preserved, not asserted
to prove animation quality. The final PBO and all 83 addon inputs match the build
manifest. Parser regressions, PowerShell syntax and whitespace checks pass.
Completed dedicated servers were stopped by verified owned profile/process IDs.

Integration decision: merge the counterattack and town increments. Synthetic
navigation and injected arrivals do not certify Redux travel, connected-player
visibility/JIP, saved campaigns, intercepted-message presentation or representative
crowded-town performance. Tactical support, strategic attacks, missions and
special creatures remain open. No campaign or sprint gate is closed. No Computer
Use, manual-client restart or Workshop publication was performed.

## 14 November 2026 - Tactical foot support

Self-review covers native selection and shared lock ownership, infected-only
registry filtering, direct constructor routing, bounded source/destination search,
both resource pools, exact birth/refund transactions, search and retreat rules,
arrival-gated capture, mixed-pool rejection and active/virtual garrison handoff.
Rebuilding review follows both installed client callbacks through sender validation,
server-computed cost, active-mission ownership and once-per-rebuild claims.

Final validation: 534 combined dedicated checks, 81 focused checks and 11 checks
without zombie dependencies pass. The combined result has no engine/SQF Error
records. Its 66 retained warnings comprise 16 startup/dependency notices and 50
object-deletion messages. All 96 addon sources and the candidate PBO match the
archived manifest. The three parser regressions, PowerShell parsing and whitespace
checks pass. Completed tactical servers were stopped by verified owned process
and profile identifiers.

The initial combined candidate failed the remote-context check: `spawn` preserves
the remote caller. CBA's local next-frame queue fixes the internal worker entry;
the final engine check observes remote ingress then local callback and worker.
A subsequent run was deliberately interrupted to correct a source-review defect
in the five-argument mission guard. The final fixture uses the installed
position-first signature. Earlier destination/search fixture corrections and
rejected evidence are documented in TACTICAL_SUPPORT_CONTRACTS.md.

Integration decision: merge the scoped tactical increment. The connected-player
positive relay, complete rebuilding mission, Redux movement, ordinary Invader
campaign behavior, multiplayer observation/JIP and saves are still unverified.
Strategic attacks and mission adaptations remain separate work. No sprint gate
is closed. No Computer Use, manual-client restart or Workshop publication occurred.

## 14 November 2026 - Strategic hordes and competitive conquest review

Source review covers native target weighting, town/permanent source eligibility,
walking bounds, resource credit scoped to a live horde, actual birth/refund
transactions, source loss, shared-cap queues, HQ/Petros interruption and
arrival-gated capture. The offscreen Invader transaction performs native capture,
new-owner garrison sizing, payment and already-paid roster insertion together.
Town population arrays are never overwritten with military idle timestamps.

Competitive review covers unavailable-race exclusion without ordinary fallback,
server/HC dispatch boundaries, inherited remote context, authoritative first
capture, deadline precedence, once-only native rewards, partial task registration
and child recovery when a parent stops before saving its launch result. The
native remote event fixture freezes loss before an immediate public Rebel retake.
Unrelated mission bodies were compared to the pinned 12.4.2 source; the AS body
and DES-through-end segment are unchanged after newline normalization.

Cleanup review separates campaign claims from deferred group deletion. Exact
retired group references preserve bodies and delete only empty local groups;
ordinary handlers cannot be removed by a remote callback request. Site cleanup
uses the same mechanism. Final fixtures wait for every handler they assert,
within their original deadlines, before deleting the campaign namespaces.

The first combined candidate exposed ten retirement failures. The replacement
was interrupted when the owner shut down the PC; neither is accepted. The final
reinforcement-focused candidate passes 50 checks, and the stacked conquest
candidate passes 45 focused checks plus 11 without zombie dependencies. All 117
production inputs and the PBO match the recorded Dev4 manifest. Three collector
parser regressions, PowerShell parsing and whitespace checks pass. The final combined
684-check run passes, including every required cleanup assertion. Its 176
recorded fixture/production hashes match the collected inputs. The completed
server was stopped by its verified process/profile identity.

The focused conquest log retains 18 warnings: 16 startup/dependency notices and
two native income notifications targeting the absent fixture commander. No
engine/SQF Error records occur in that focused report. These dedicated fixtures
do not certify player/commander reward delivery, real HC relay, message/UI
presentation, Redux travel, crowd performance, multiplayer/JIP or save/restart.
Town-liberation and other mission/convoy callers remain open. No campaign or
sprint gate is closed, and no Computer Use or manual-client update occurred.


The combined report retains 74 warnings: 16 startup/dependency notices, 56
object-deletion notifications and two absent-commander notifications. There are
no engine/SQF Error records. Integration decision: merge the reviewed strategic
and competitive increments in order. This is the tested stacked candidate; a
separate passing full Dev6 strategic-only run is not claimed. The next isolated
branch begins the owner-approved survivor-defense liberation adaptation.


## 14 November 2026 - Optional Zeus Enhanced manual launch

The manual launcher now accepts IncludeZeusEnhanced, adding the installed
Workshop mod 1779063631 to the existing dependency stack. This changes only the
optional launch list. PowerShell parsing and whitespace checks pass. The actual
visible client launch records Zeus Enhanced 1.15.1 (zen_main 1.15.1.36), Infection
and Chernarus Redux in its startup log. The sanitized receipt identifies the
immutable Dev9 artifact from the separate scene branch and its 208/11 isolated
checks. No Computer Use, gameplay, Zeus UI, compatibility or scene integration
acceptance is claimed. The user is testing this client manually.


## 14 November 2026 - Mission catalog removal draft

Owner decisions now replace all requested mission categories in Infection,
restrict combat requests to infected, remove Destroy/Random entirely, accept
HQ/permanent-site deliveries, fail interception on destination arrival, and
replace competitive conquest with straightforward Liquidation clearance.

Reviewed the first removal increment against Ultimate 12.4.2. Server rejection
precedes the request lock and native random selection. Client rejection precedes
the GUI's own random expansion. Four direct Destroy entry points are guarded,
and both menu definitions receive conditional hide/disable hooks. Ordinary
unselected campaigns delegate to the original functions. The original
competitive regression now uses the still-delegated LOG route instead of DES;
its historical pass is not claimed as evidence for this changed candidate.

Config/PBO packaging, exact production source/artifact hashes, fixture/collector
agreement for 13 new checks, three evidence-parser tests and whitespace checks
pass. Evidence: evidence/sprint-4/mission-catalog-removal-draft.json. Runtime
checks were NOT_RUN: the protected launch check detected the active Dev9 user
client, PID 52480, before mission installation or server start. Visual controls,
loaded config inheritance, direct/remote guards and ordinary campaign behavior
remain unverified at runtime. Keep this branch draft/unmerged and leave the
manual client's immutable build unchanged. Six replacement mission behaviors
remain open; the complete project goal and all unmet sprint gates remain open.


## 14 November 2026 - Catalog guards and clearance ledger review

Reviewed the full production diff against master. The UI patch now preserves
native dialog/control bases and declares the native GUI load dependency. Guards
run before request locking and random expansion, and direct Destroy endpoints
remain inactive only for a selected, dependency-ready Infection campaign.

Clearance tracking attaches after successful actor initialization, adds adopted
reinforcement obligations, counts real death once, and distinguishes live deletion
from defeat. Visit identity rejects stale callbacks. The predicate requires a
healthy active site, no pending roster or living actors, and settled native
garrison updates. It is read-only and does not yet implement Liquidation capture.

Dev3 passes 25 focused catalog checks and 717 combined checks; the unchanged
clearance implementation also passed 30 focused checks in Dev2. The actual Dev3
missing-dependency run passes 11 checks. No engine/SQF error records occur.
All 127 production files and the PBO match the build manifest. Reviewed retained
warnings: 16 startup notices, 53 object-deletion notices and two absent-commander
notifications in the combined run; seven startup notices without dependencies.
Rejected Dev2 and intermediate fixture evidence stays in the repository.

Integration scope is this reviewed foundation only. Six replacement lifecycles,
visual menus, connected-player/HC behavior, terrain, saves and full campaign
acceptance remain open. The source audit lists native category variants and
literal callers without claiming complete dynamic reachability. No Computer Use
or update of the user's immutable manual build was performed.


## 14 November 2026 - Liquidation target selector

Reviewed target family classification and the infected-only filter against
Ultimate 12.4.2. Native HQ distance/sorting is retained; military aliases cannot
bypass war level 3. Towns, permanent sites and native road controls are eligible,
field controls remain excluded, and no competing attack origin is required.
The selector does not create tasks, capture territory or award resources yet.

The focused dedicated suite passes 22 checks (11 common plus 11 selection cases),
with 16 startup/dependency warnings and no engine/SQF error records. All 129
production inputs and the PBO match the recorded Dev1 manifest. The test server
was stopped by verified identity and its exit confirmed. This branch remains
draft while task, guarded capture, cancellation, rewards and cleanup are built.


## 14 November 2026 - Liquidation capture component

The Dev2 selector/capture increment passes 44 focused and 750 combined engine
checks, with no engine/SQF error records. All 133 production inputs and the PBO
match the manifest. The copied native permanent-site body reconstructs exactly
to pinned 12.4.2 after removing the ownership guard and restoring its include.
Native town, control and administration ownership paths share the same atomic
clearance check. Server-origin remote capture is exercised; connected clients
are not. Russian takeover freezes cancellation before delayed native effects.

The claim/task controller is separately drafted in PR #25. Review there found
and corrected an administration fault-propagation regression in this component:
an attempted native write failure must retain capture_failed, while clearance
rejection must remain retryable. This branch stays draft until the correction
and task integration are validated. The 750-check report applies to Dev2 and
does not claim coverage of that later correction or the mission controller.

The complete project, six replacement lifecycles, player rewards, UI, terrain,
saves and multiplayer acceptance remain open. No Computer Use was performed.


## 14 November 2026 - Liquidation controller focused review

Reviewed exclusive claims and native task registration, atomic capture linkage,
normal/difficult native CON_Outpost reward amounts, cancellation precedence,
once-only settlement and task retention. Capture workers remain independent
of the task loop; the watchdog retains their claim until delayed native flag
work finishes. The administration write-refusal fault is preserved so a broken
transaction cancels rather than timing out with a penalty.

Controller Dev3 passes 33 focused dedicated checks without engine/SQF errors.
The 21 retained warnings comprise 16 startup notices and five absent-commander
income notifications. All 139 production inputs and the PBO match its manifest.
The interrupted task-text fixture is retained, with installed function hashes
explaining the correction. The parent capture-only 750-check regression does
not establish a full combined controller pass. Keep this branch draft while
mission-board/direct dispatch, combined integration, connected rewards and
remaining campaign acceptance are completed. No Computer Use was performed.

The actual Controller Dev3 missing-dependency run also passes 11 checks, with
seven startup notices and no engine/SQF errors. All test servers were stopped
by verified process/profile identity, with exit confirmed.


## 14 November 2026 - Liquidation dispatch focused review

Reviewed all four native conquest entry points and their scheduler path. Active
Infection routes only to eligible infected targets, with no Russian legacy
fallback. Inactive/dependency-absent routes preserve native arguments. CON
requests retain HQ eligibility and busy-lock waiting while the exclusive claim
prevents duplicates. They never own or clear another request's shared lock.
Menu overrides preserve explicit widget bases and native actions. Seven retired
competitive helpers and 34 obsolete cases are removed; strategic hordes remain.

Dispatch Dev1 passes 37 focused checks with no engine/SQF errors and 16 retained
startup/dependency notices. All 138 production inputs and the PBO match the
manifest. Combined regression is in progress. Keep the stack draft pending its
result and actual dependency-absent validation. Connected reward receipt, visual
menus, multiplayer, saves and complete campaign acceptance remain open.


### Integrated Liquidation review result

Dispatch Dev1 passes all 764 combined checks, 37 focused dispatch checks and
11 actual missing-dependency checks. No engine/SQF error records occur. Reviewed
combined warnings: 16 startup/dependency, 50 object-deletion and five absent
fixture-commander notices; the dependency run retains seven startup notices.
The 138 production inputs and PBO still match the frozen candidate after testing.
Both isolated test servers exited. The user's manual build/profile remain intact.

Reviewed the full stack against master, including native capture transactions,
site-ledger guards, controller/cleanup settlement, four direct dispatch endpoints,
CON requests, menu inheritance, and obsolete competitive removal. The corrected
administration write fault is included in this integrated result. Integrate
PRs 24, 25 and 26 in order; their historical component evidence stays scoped to
its recorded candidates. No further production change was made during the run.

Connected-player reward delivery, visual tasks, multiplayer, save/restart,
Redux traversal and full campaign acceptance remain open. The other five mission
replacements are not represented as finished by this merge. No Computer Use.


## 14 November 2026 - Horde Interception foundation

Reviewed bounded route planning, initial faction/endpoint restrictions, source
safety and cooldowns, native HQ distance, land connectivity and exclusion of
spawn/destination overlap. Source search is independent of vehicle spawn aliases.
The 40-120 tuning follows the owner's authorization; it is not a performance
acceptance claim. Full formation staging and march remain unimplemented.

The budget retains existing shared/town behavior and adds a finite dedicated
interception domain. Only a live preparing owner reserves new slots; later phases
retire unused reservations, and living bindings cannot turn into shared capacity
if the owner disappears. Population domains cannot transfer into each other.

Interception Dev1 passes 78 focused checks (11 common, 23 shared-budget and 44
interception), 78 town-regression checks and 11 actual missing-dependency checks.
No engine/SQF errors. Focused warnings: 16 startup/dependency notices. Town
warnings: the same 16 plus four object-deletion notices. Missing dependencies:
seven startup notices. All 141 production inputs and the PBO match the manifest.
The first fixture failed before engine script termination became observable;
the corrected check records that timing and tests refusal after actual exit.
The failed report remains separate. No production fix was needed for that issue.

Keep PR 27 draft until formation, controller and dispatch integration are reviewed.
No public mission flow yet creates an interception job. Connected clients,
Redux travel, performance, saves and full campaign acceptance remain open.
No Computer Use or manual-build replacement occurred.


## 14 November 2026 - Interception formation component

Reviewed the six new server-only formation helpers, separate-budget ownership,
atomic post-initialization tracking, complete-roster departure, real-event death
accounting, stale serial refusal, and retirement of interrupted spawn batches.
The formation remains finite; no casualty-driven replacement is introduced.
The generic callback defaults to true for existing callers, and explicit paid
rollback suppresses the existing deletion refund to prevent double credit.

Dev1's weak movement assertion was replaced after a run recorded zero progress.
Prepared zombie classes issue their own startup doMove-to-self command. Dev2
allows native initialization to settle while hidden and issues destination
orders on release. Every tested group leader must now gain at least ten metres
toward the destination. Four leaders passed that assertion in the focused run;
this does not certify full Redux paths or combat pursuit/recovery.

Formation Dev2 passes 47 focused checks, including complete 40/120-member release
and cleanup, and 11 actual missing-dependency checks. No engine/SQF errors.
Focused warnings are 16 startup/dependency notices plus four object-deletion
notices; missing dependencies has seven startup notices. Three parser tests
pass. All 147 production inputs and the PBO match the recorded manifest.
Three fixture errors and one stationary-leader result remain rejected evidence.
The combined regression suite is still running and is not yet claimed passed.

PR 28 is stacked on draft PR 27. Keep task/controller ownership, first-arrival
observation, settlement, arriving-survivor handoff, requested/intel dispatch and
background Russian convoy separation open. Connected clients, performance,
saves and full campaign acceptance remain open. No Computer Use or manual build
replacement occurred.


### Formation follow-up review

Dev2's combined run completed 844 checks with two failures and no script errors;
it is rejected. Capture diagnostics traced one to a test reset of published
namespace variables without publishing the replacement. The corrected reset
and final spawner cleanup publish their values. Twelve repeated real remote
captures then pass. Production Liquidation code did not change. Diagnostic
logging stays in the isolated test addon and is absent from gameplay packages.

The second failure was a real stationary walker retaining a MOVE command.
Diagnostics verified life, simulation, ground contact, no enemy and no movement
lock, then observed renewed movement after reissuing the destination. Dev3's
new internal monitor checks ten-second movement intervals, respects native
pursuit and locks, skips adopted/player-controlled/nonlocal members, and retries
stationary march orders without teleporting or changing AI feature flags.
Retirement or owner termination removes its CBA handler. Initial one-time
startup ordering is no longer presented as a sufficient movement fix.

Reviewed the monitor, lifecycle changes, diagnostic evidence and test corrections.
Dev3 passes 85 targeted checks (including both formerly failing paths) and 11
actual missing-dependency checks. No engine/SQF errors. Targeted warnings are
16 startup/dependency notices and four object-deletion notices; absent dependencies
has seven startup notices. Three parser tests pass. All 148 production inputs
and the addon match the manifest after testing. Both servers have exited.

Dev3 full combined run is NOT_RUN. Keep PR 28 draft and repeat full regressions
on the next integrated task/controller/dispatch candidate. The 47-check Dev2
focused report remains historical and does not override its failed combined
report. Full-route travel, connected clients, performance, saves and complete
campaign acceptance remain open.


### Interception task outcome and retention review (PR 30)

Reviewed server/remote guards, exact job serial matching, once-only settlement,
first-entry precedence, event timestamps, deadline validation and cleanup. A
missing or non-finite deadline now fails closed instead of producing invalid
reward data. Task retention has its own callback so removal does not delete
arrival survivors. Repeated settlement and cleanup calls are idempotent.

Dev3 passes 45 focused task checks and 11 actual missing-dependency checks with
no engine/SQF errors. Three parser tests pass. The final fixture asserts native
registry/owner removal rather than BIS taskExists: installed engine source shows
that no-player dedicated deletion can retain ID. Production was unchanged for
that correction. Rejected timing, cleanup-index and taskExists assumptions are
preserved with diagnostic evidence. Warnings: 16 focused startup/dependency and
seven absent-dependency notices. All 154 production inputs match the artifact.

Formation/capture regression passes all 85 checks without engine/SQF errors.
Its 20 warnings comprise 16 startup/dependency notices and four object-deletion
notices. All 154 production inputs and the PBO still match the manifest after
testing; the isolated test server exited. Full combined suite NOT_RUN. PR 30
remains draft on PR 28; public task creation/dispatch, complete owner supervision
and arrival aftermath remain unfinished. No player reward receipt, player UI,
JIP, full-route travel, performance, saves or campaign acceptance is claimed.
No Computer Use or manual install/profile/save changes.


### Interception lifecycle follow-up (combined validation pending)

Internal task registration now creates the native briefing only for a released
formation, refuses duplicate/remote registrations and selects a walking-aware
travel limit. Independent supervision handles stopped preparation workers,
observer-safe visible cleanup and claim release after task/formation retirement.
Arrival survivors remain owned until the separate aftermath controller finishes.

Lifecycle Dev1 passes 62 focused checks and 11 actual missing-dependency checks,
with no engine/SQF errors; warnings are 16 and seven startup/dependency notices
respectively. Three parser tests pass. A native briefing representation fixture
error remains rejected evidence. Two additional success-path corpse/retention
checks await the combined run. Public launch/dispatch and arrival policy remain
unfinished; no campaign acceptance or Computer Use/manual-build change.
## 14 November 2026 - Background Russian supply traffic

Self-reviewed the complete production diff against master and pinned Ultimate
12.4.2 source. The new override handles only active Infection, Invader-source,
Supplies/attack-pool convoys. Its scheduler path is server-owned; ordinary and
legacy convoy calls delegate with unchanged arguments. The supply adaptation
retains native strategic effects and vehicle/logistics behavior while omitting
player tasks, route/objective revelation and personal mission rewards/penalties.

The early truck-destruction case revealed and reproduced an inherited native
race. Dev2 registers cargo destruction before vulnerability/departure and targets
only its tracked cargo while still attached. Both parked/departing destruction,
normal and captured delivery, real logistics loading, a queried zero-capacity
vehicle, force cost, duplicate exclusion, cleanup handoff and completed workers
pass in the isolated engine fixture. Fixture-only errors and the test kart's
engine error remain in rejected evidence; the collector was not relaxed.

Accepted evidence: 64 focused checks, 11 actual missing-dependency checks, three
parser unit tests, no engine/SQF errors. Reviewed 16/7 collector startup notices
and the additional native truck animation-source notice. All 140 production
inputs and the PBO match Dev2; isolated test processes exited. Integrate this
scoped feature through PR 29. No Computer Use or manual installation update.

Full combined regression, driving, connected UI/rewards, native despawner behavior,
real-hour timeout, interruption handling, HC/multiplayer, saves and the full
mission catalog remain unaccepted. No sprint gate is closed by this checkpoint.


Integrated lifecycle regression checkpoint: the frozen 159-input candidate
completed 955 combined checks, with one failed success-retention assertion and
no engine/SQF errors. That report remains rejected. A 64-check focused diagnostic
then reproduced the exact failure state: outcome won, formation retired, four
native corpses, retained task/claim, zero budget counts, but native task state
still CREATED. After its queued update, the same values remain and state becomes
SUCCEEDED. The fixture now waits explicitly for that native state; production
code did not change. All 64 focused checks pass without engine/SQF errors.
The combined run has 80 reviewed warnings: 16 startup/dependency notices, 59
object-deletion notices and five absent-fixture-commander notification targets.
The focused run has 16 startup notices.
All 159 production inputs and the PBO still match the manifest. Both test servers
exited. A clean combined rerun remains required before integration; do not treat
the rejected combined report as passed. The town-extra branch will include this
fixture correction before its combined validation. Arrival capacity/offscreen
persistence/casualty decisions are now resolved: extras exceed normal capacity,
persist to the next visit, and stay dead when killed. Handoff remains unfinished.


## 14 November 2026 - Integrated interception and town extras review

TownExtras Dev1 passes all 965 combined dedicated checks and all 67 role-spawn
records, without engine/SQF errors. The focused town run passes 88 checks;
the actual missing-dependency run passes 11; three parser tests pass. All 160
production inputs and the PBO match the frozen build manifest after testing.
The combined server exited. Its 81 warnings were reviewed: 16 startup/dependency
notices, 60 object-deletion notices and five absent-fixture-commander notification
targets. The earlier 955-check failure remains rejected historical evidence.

Self-review covered owner/serial guards, dedicated population accounting,
queued baseline/extra separation, native casualty/save roles, task state and
retention, observer-safe retirement and source/target ownership races. Integrate
foundation PR 27, formation PR 28 and controller PR 30 through combined PR 31.
This is component acceptance, not a completed Horde Interception player mission
or sprint gate. Public mission creation/dispatch, active/hostile arrival aftermath,
connected players, terrain, full campaign saves and remaining mission families
are still unfinished. Offscreen arrival transaction work is isolated in PR 32.
No Computer Use or manual installation/profile changes.


Offscreen arrival review: all 34 focused engine checks pass, including physical
arrival guards, observer refusal, an above-capacity permanent garrison, three
survivors saved after a real casualty, native corpse retention, duplicate
prevention, resource neutrality and complete cleanup. Eleven actual missing-
dependency checks and three parser tests pass. No engine/SQF errors; the focused
run has 16 reviewed startup/dependency warnings. All 161 production inputs and
the PBO match the tested manifest. Both isolated servers exited. The helper has
no public caller yet; active/hostile/administration handoff and dispatch remain
unfinished. Keep PR 32 draft for continued integration. Its full combined run
is NOT_RUN; the parent candidate's 965-check report is separately identified.

## 14 November 2026 - Live and offscreen interception handoff review

LiveArrivals Dev1 passes all 1013 combined engine checks and all 67 role-spawn
records, plus 59 focused handoff checks, 11 actual missing-dependency checks and
three parser tests. No engine/SQF errors were recorded. All 162 production inputs
and the PBO match the immutable manifest after execution. The completed server
exited. Its 85 reviewed warnings consist of 16 startup/dependency notices,
64 object-deletion notices and five missing-fixture-commander notification targets.

Self-review covered exact owner/serial and ticket guards, garrison mutex handling,
duplicate prevention, preservation of physical actors, removal from the old horde
owner before cleanup, native casualty persistence, town allowance expansion and
closed permanent-site arrival capacity. The ordinary shared spawn queue and paid
reinforcement rules remain independently exercised by the combined regression.
PR 32 can integrate this component. It does not complete Horde Interception:
automatic arrival handling, hostile combat and public dispatch remain open.
Administration persistence and the owner's 50-metre boundary are isolated in
draft PR 33 and cannot claim this different candidate's regression result.
No Computer Use or manual installation/profile changes.


## 14 November 2026 - Integrated Horde Interception dispatch review

InterceptionDispatch Dev1 passes all 1089 combined dedicated checks and all 67
role-spawn records, plus 36 focused dispatch checks, 11 actual missing-dependency
checks and three parser tests. Parent components separately pass 38 administration
and 35 aftermath checks; the corrected native task settlement fixture passes 64.
No engine/SQF errors occurred in the accepted runs. The combined run has 93
reviewed warnings: 16 startup/dependency notices, 72 object-deletion notices and
five missing-fixture-commander notification targets. All 177 production inputs
and the PBO still match the frozen manifest. The completed combined server exited.

Self-review covered validated/idempotent administration save payloads, persistent
extra casualties, 50-metre administration arrival, complete-group adoption,
observer-safe retirement, native hostile capture guards, permanently cleared
administrations, server authority, creation claims, request locks and real route
intel. Integrate PRs 33 and 34 through PR 35 against master. Historical rejected
reports stay committed; the task assertion corrections did not change rewards.
Upstream intel-body trailing whitespace is deliberately preserved; aggregate
diff whitespace checks report those lines and a fixture EOF blank line.

This completes the source implementation of Horde Interception's requested
entry points and arrival aftermath, with isolated engine evidence. It does not
prove connected menus, HC/JIP, Redux travel, disk campaign saves, stochastic intel
outcomes, one-hour aftermath or full campaign/release acceptance. No sprint gate
is closed. No Computer Use or manual installation/profile changes.


## 14 November 2026 - Friendly delivery predicate review

Delivery Dev1 passes 36 focused engine checks, 11 actual missing-dependency
checks, packaging and three parser tests. No engine/SQF errors; 16 startup
notices reviewed. All 178 production inputs and the PBO match after testing;
both servers exited. Review covered current ownership, all six site lists,
HQ references, rotated marker geometry, excluded sites and read-only behavior.
This helper has no public caller and changes no rewards or assets; focused
coverage is appropriate without repeating the parent full suite solely for it.
PR 35 separately passed 1089 combined checks and 67 role records. PR 37 may
integrate this prerequisite. Actual delivery missions and campaign acceptance
remain open. No Computer Use or manual installation/profile changes.


## 14 November 2026 - Extraction survivor ledger review

The owner's all-survivors-or-deadline rule passes 42 focused engine checks in
ExtractionLedger Dev2, with 11 actual missing-dependency checks, packaging and
three parser tests also passing. No engine/SQF errors; 16 startup/dependency
notices reviewed. All 182 production inputs and the PBO match the manifest.
Both completed test servers exited. Dev1's failed deletion-event report remains
committed; Dev2 fixes the actual object/array mismatch without weakening tests.

Review covered exact actor ownership and serials, duplicate/stale records,
real deaths versus live deletion, first-rescue continuation, mixed outcomes,
deadline totals, independent ticking, concurrent ledgers, and handler cleanup
without deleting survivors or touching another owner's state. The ledger has
no public mission caller yet. PR 38 may integrate this tested prerequisite;
it does not complete Extraction tasks, rewards or connected rescue interactions.
No Computer Use, manual-install changes or sprint-gate completion.


## 14 November 2026 - Supplies Seizure truck assets review

SupplyTrucks Dev1 passes 35 focused engine checks, 11 actual missing-dependency
checks, packaging and three parser tests without engine/SQF errors. Sixteen
startup notices reviewed. All 184 production inputs and the PBO match after
execution; both servers exited. The rejected first report remains committed:
its vehicle-retention assertion accidentally called the existing stub. The
corrected fixture calls separately compiled native VEHdespawner; production is
unchanged. Native GetIn capture, destruction and deleted-vehicle handlers are
exercised, with resource pools unchanged and no theft-support callback.

Self-review covered configured pools and vanilla fallbacks, creation authority,
compiled campaign data, safe positions, empty crew, neutral ownership before
events, unlocked service trucks and preservation of captured Rebel vehicles.
The helpers have no public mission caller yet. PR 39 may integrate these assets;
full Supplies Seizure creation/controller/rewards/dispatch, optional mod packs,
ACE, player driving, garage, disk saves and campaign acceptance remain open.
No Computer Use, manual-install changes or sprint-gate completion.


## 15 November 2026 - Abandoned town vehicles review

The town adapter preserves native parking attempts, road filtering, civilian
visit activation, native boats/traffic, claim behavior and save eligibility.
The approved mix is local to each placement; shared faction pools are never
modified. Review added an explicit server-local scheduled worker guard and
canonical visit-record validation. The independent cleanup monitor handles
normal and interrupted workers, exact serial/tag ownership, claimed assets,
nearby observers, occupants, attached/towed assets and moved-vehicle handoff.

AbandonedTowns Dev2 passes 36 focused Altis-road engine checks, 11 actual
missing-dependency checks, packaging and three parser tests. Native GetIn,
neutral salvage and the actual delayed VEHdespawner execute in this fixture.
No engine/SQF errors; 16 reviewed baseline startup notices. All 262 source
inputs and PBO match the manifest; both vehicle servers stopped. Dev1 evidence
is retained. Boat and driven-traffic branches are preserved in source but gated
out of this fixture. Redux, connected driving, optional packs, HC/JIP, towing,
garage and disk saves remain open. No sprint acceptance gate is closed and the
manual Dev9 installation remains untouched.


### Redux parking validation follow-up

Unchanged AbandonedTowns Dev2 passes 163 checks across all 49 towns initialized
by Ultimate on installed Chernarus Redux. It created 110 cars and completed all
bounded deletion checks without leftover entities/groups. All 262 inputs and
PBO still match. Sixteen reviewed baseline notices, no engine/SQF errors. The
first full sweep is retained as rejected (15 premature cleanup assertions), and
a deliberately interrupted diagnostic records the engine-deletion boundary.
The corrected fixture waits for both controller retirement and object deletion,
with a five-second limit and no forced cleanup before the assertion. Native
parking attempts may yield zero cars when every candidate is unsafe; Nadezhdino
was such a case in the accepted sweep. No placement fallback or extra attempt was
added. The server exited. Driving, horde navigation, boats/traffic, towing, garage,
saves and full campaign acceptance remain open. README/backlog/override records
now distinguish current mission implementations from the retired conquest race.
## 14 November 2026 - Liberation component review

The draft branch contains nearby source selection, native human survivor
creation/recruitment/cleanup, a parent-owned walking horde and an arrival-based
outcome evaluator. Review checked local-only parent authority, atomic child
linkage, unchanged default capture behavior, actual paid births, temporary debt,
native living-despawn refunds, queued force accounting, first arrival, survivor
failure precedence, source loss and stopped/orphaned child cleanup. The survivor
guard now excludes prepared special creatures as well as basic infected using
the installed WBK faction declaration. Cleanup retains the rescuer's group.

All 79 focused checks and 11 dependency-absent checks pass on the 122-input
candidate. Production and collected fixture hashes match. Three parser tests
pass. Rejected fixture attempts and the evidence limitations are recorded in
TOWN_LIBERATION.md. The combined 752-case regression passes with no engine/SQF
Error records; all 122 production and 184 collected input hashes match. Its 86
startup/dependency, object-deletion and absent-target warnings are retained and
reviewed in the research record. The completed server was stopped by verified
process/profile identity. The PR stays
draft: the parent controller, native settlement/dispatch, pending no-origin
decision, connected-player interaction and full mission acceptance remain open.

## 14 November 2026 - Liberation parent controller review

Review covers task-type exclusion, exact skirmish claims, native recruitment,
preparation, parent/child interruption, unrelated attack preservation, survivor
failure precedence and once-only territory/reward settlement. Cleanup retains
the rescuer's group and pre-existing administration claims. Rejected fixture
attempts now await the actual owned actor/group deletion and native despawn
refund, instead of treating registry removal as completion of queued work.

Source review found that native city capture updates the war tier before paying
the townBattle reward. The first controller paid too early. The correction keeps
the five-second delay, completes native tier calculation before payment, and
defers payment safely when the resource lock is busy. A real native HR-cap case
proves 251 final HR instead of the incorrect old-tier cap of 200.

All 104 focused checks and 11 missing-dependency checks pass, with no engine/SQF
Error records. The PBO and all 127 production/190 collected focused inputs match.
Nineteen focused warnings and seven dependency-absent startup notices are retained
and classified in TOWN_LIBERATION.md. Three parser tests, PowerShell parsing and
whitespace checks pass. The combined 777-case regression passes, including all
67 role spawns and the actual native HR-cap correction. All 190 collected inputs
still match. Its 77 warnings are classified in the research record; no engine/SQF
Error records occur. The completed server was stopped by verified identity.
This draft remains unmerged: scene construction, campaign entry with the now
approved peaceful fallback, and connected-player/full-mission acceptance remain open.

## 14 November 2026 - Survivor vehicle component review

The owner's retained-scene requirement is recorded. Its first component filters
native Rebel-template categories to usable public ground vehicles, creates no
crew, owns the exact object at birth and refuses unsafe/changed placement. Source
review records the separate native wreck, corpse/blood, fire and building-repair
contracts still needed for the full scene.

All 116 focused and 11 missing-dependency checks pass on the 129-input candidate.
The PBO and all 193 focused inputs match; no engine/SQF Error records occur.
The actual EntityCreated monitor observed no transient crew. The rejected first
fixture and retained warnings are explained in TOWN_LIBERATION.md. Three parser
tests and whitespace checks pass. Completed servers were stopped by verified
identity. The scene remains unconnected and unaccepted as a full mission feature;
Redux placement, collection/garage/save behavior and its remaining assets need work.

## 14 November 2026 - Scene fire component review

The first engine attempt exposed that particle sources and lights cannot hold
ownership tags. The corrected server registry retains the original record and
array references. Same-name copies cannot claim them. Creation records each
object before setup, and cleanup handles a partial pair without leaking the
remaining emitter. One persistent presentation callback retains all native
particle/light settings for later-joining clients, correcting the native
same-JIP-identity replacement pattern. The callback accepts only server origin.

All 129 focused checks and 11 missing-dependency checks pass on Dev4. All 132
production inputs, PBO and 197/159 collected input hashes match. No engine/SQF
Error records occur; the retained 21/7 warnings and the rejected first attempt
are documented in TOWN_LIBERATION.md. Three parser tests, PowerShell parsing
and whitespace checks pass. Completed servers were stopped by verified identity.
The component remains unconnected; client/JIP visuals, observer-positive tests,
the remaining scene assets and full mission acceptance are still open.

## 14 November 2026 - Scene corpse component review

The component uses validated native scene roles, with only basic WBK types.
Exact bodies, blood objects and original civilian groups are retained before
later setup. Creation/killing is unscheduled; the installed basic WBK scripts
refuse already-dead actors. Cleanup checks ownership, defers near observers and
retires original groups without targeting unrelated corpses or live members.

The 135-input Dev5 candidate passes 147 focused and 11 dependency-absent checks.
All production/PBO and 201/163 collected input hashes match. Actual human and
basic-infected bodies, blood and groups are created/deleted; the body case does
not alter infected resources or active budget. No engine/SQF Error records occur.
The rejected fixture assumptions, corrected native detection/loadout checks and
23/7 retained warnings are documented in TOWN_LIBERATION.md. Three parser tests
and whitespace checks pass; completed servers were stopped by verified identity.
Parent integration, combined regression, observers, client presentation and long
duration body behavior are still open. The owner explicitly selected abandoned
wrecks with no infected resource effects; that policy is recorded for the next
component and is not claimed implemented by the corpse checks.


## 14 November 2026 - Abandoned scene wreck review

Neutral ownership is established before capture handlers can run. The adapter
requires compiled skin maps, creates no crew, owns the object at birth and
preserves claimed or in-use vehicles. Real native capture/destruction/deletion
checks show no infected resource effects or civilian-theft support penalty.
The rejected uncompiled fixture and corrected map preparation are documented.

Dev7 passes 170 focused and 11 missing-dependency checks, with no engine/SQF
Error records. All 138 production/PBO and 205/167 collected inputs match. The
21/7 warnings are classified in TOWN_LIBERATION.md. Parser tests and whitespace
checks pass; completed server exits are verified. Building restoration follows
the owner's new native-cleanup decision. Parent integration, combined regression,
player vehicle interactions and full mission acceptance remain open.


## 14 November 2026 - Temporary scene building review

The component excludes pre-existing damage and protected/occupied buildings,
records original transforms/doors before damage, tracks the exact native ruin,
and restores partial damage as well as collapsed houses. Only owned temporary
ruins leave the native persistence list. Interrupted cleanup retains ownership
until restoration is observed; deleted originals are not replaced.

Dev8 passes 195 focused and 11 missing-dependency checks. All 141 production/PBO
and 210/172 collected inputs match. No engine/SQF Error records; 31/7 retained
warnings and rejected investigation/fixture runs are documented. Preparation
state and its clock are now published atomically after a diagnostic run exposed
an intermittent preparation check failure. Parser, PowerShell and whitespace
checks pass. Completed server exits are verified. Terrain, connected observers,
save/load, full scene construction and combined regression remain open.


## 14 November 2026 - Roof effects and native smoke review

The exact native smoke anchor owns its three local effects; actual deletion
retires all three even after a partial child deletion. Roof effects use a
checked geometry hit, and repeated decoration cannot multiply owned effects.
Native damage and smoke/fire/collapse distributions remain in the helper.

Dev9 passes 208 focused and 11 missing-dependency checks. All 143 production/PBO
and 213/175 collected inputs match. No engine/SQF Error records; 31/7 warnings
are classified in the research record. Parser and whitespace checks pass;
completed server exits are verified. Full scene construction/parent integration,
client/JIP/terrain behavior and combined regression remain open.


## 14 November 2026 - Draft scene integration source review

Reviewed task reservation before scheduled construction, survivor/source/expiry
cancellation, interrupted-parent cleanup and claim release ordering. The complete
cleanup preserves native survivor-vehicle retention. The fixtures now wait for
real construction and cleanup, including a parent stopped during construction.
Dev11 packages with 145 matching production inputs and a matching PBO. Three
parser tests and whitespace checks pass. Engine validation is NOT_RUN while the
owner tests Dev9; no current combined-regression or campaign acceptance is claimed.
## 14 November 2026 - Liberation campaign dispatch review

Review verified the infected-only skirmish insertion and preserved original
resourcecheck control flow outside that branch. The source-comparison report
matches the pinned native body after the declared adaptations. Ordinary
factions delegate to the original functions. The direct mission entry cannot
force a distant source or receive a political fallback.

All 124 focused checks and eleven missing-dependency checks pass on the 130-input
candidate. Native peaceful ownership/garrison/tier changes occur without mission
rewards. Existing claims, busy attacks, invalid/insufficient support, destroyed
towns and missing navigation/HQ state do not grant a capture. All production/PBO
and 196 focused input hashes match; no engine/SQF Error records occur. Retained
warnings are classified in TOWN_LIBERATION.md. Three parser tests and whitespace
checks pass; completed servers were stopped by verified identity. The separate
parent 777-case regression is incorporated, but this dispatch candidate's combined
regression, actual campaign economy cycle and connected-player behavior remain
NOT_RUN. No Computer Use or manual-client update occurred.
## 15 November 2026 - Combined Aid and Elimination integration review

The current Elimination branch includes the complete Aid controller branch.
Review preserved both mission families' registration, native aliases, scheduler
routes, menu labels and test endpoints. Frozen Dev3 passes 1,427 combined engine
checks, 67 role-spawn records and eleven actual dependency-absence checks; all
254 source/PBO hashes match. No engine/SQF errors, with 16 baseline startup,
70 object-deletion and ten null-fixture-commander notices reviewed. The completed
server exited. The first interrupted Dev3 run is not a pass; rejected Aid runs
remain retained. The accepted combined run uses the corrected Aid timing fixture.

This supports integrating PR 46 and its included PR 43 commits. It does not
certify connected player rewards, visible menu behavior, campaign progression,
terrain, saves, performance or a sprint gate. Manual Dev9 remains unchanged.
