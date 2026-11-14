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
