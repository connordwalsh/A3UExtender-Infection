# Product backlog

The acceptance criteria and test requirements are in [PROJECT_PLAN.md](PROJECT_PLAN.md).

Liquidation selection, guarded capture, task settlement and public dispatch are
tracked in [LIQUIDATION.md](../research/LIQUIDATION.md). Dispatch Dev1 passes 37
focused checks, 764 combined checks and 11 actual missing-dependency checks. Earlier capture
and controller results remain recorded separately. Campaign acceptance is open.
[PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md) records the user's amendments.
Status is evidence-based; successful packing does not complete a gameplay story.

Current campaign checkpoint: merged PR 69 records native startup, save and
fresh-process reload passing 19 checks per phase with zero matched errors.
The subsequent native site probe passes 113 lifecycle checks over two visits each
to one town and six permanent-site categories, alongside the 19 campaign checks.
Seaport/base/airport rosters retain 4/20/32 queued defenders beyond 12 active.
See NATIVE_CAMPAIGN_SITES.md. The subsequent casualty probe passes 18 checks: four deaths reduce a native
factory garrison, four queued infected replace them, and the reduced roster
returns on revisit. A subsequent native save/restart run passes six writer and
ten reader checks, retaining that reduced factory roster. Connected-player,
player combat, full-map coverage, performance and release acceptance remain open.

Earlier mission integration checkpoint: merged PR 40 covers Supplies Seizure after 1228
combined checks and 67 role-spawn records. PRs 41/42 add Extraction scenes and the
Aid unloading ledger; PRs 44/45 add Elimination tracking and scenes. Public Aid
and Elimination are merged through PR 46 after their unchanged Dev3 rerun passed
1,427 checks and 67 role-spawn records. The earlier interrupted report is retained
and does not count as a pass. PR 47 adds
abandoned vehicle assets; PR 48 connects them to town visits, passing 36 focused
Altis-road checks and 11 actual missing-dependency checks. The Redux parking sweep passes 163 checks across 49 towns. Public Extraction and post-rescue disposition remain unfinished.
The separate large-creature diagnostic remains failed and is tracked separately.
No sprint acceptance gate is closed. The manual Dev9 installation is unchanged.

14 November amendment: [Mission redesign](MISSION_REDESIGN.md) records the
owner's six replacement categories for S4-1, S4-2, S4-3 and S5-3. The catalog now
targets infected exclusively; Destroy/Random are removed and Liquidation
supersedes requested competitive conquest. Delivery accepts HQ/permanent sites.
The removal and clearance-ledger increment passes 717 combined dedicated checks
and 11 checks without zombie dependencies. Clearance is now connected to the
Liquidation controller on this branch; public mission dispatch passes its focused checks.
The six-mission redesign and visual/connected-player acceptance remain open;
none of these stories is complete.

| Story | Work | Status | Evidence / next check |
| --- | --- | --- | --- |
| S0-1 | Versions, dependencies, clean local and dedicated baseline | In progress | Local save/reload and isolated dedicated native startup/save/reload verified; dedicated runs pass 19 checks per phase with zero matched errors. Connected-player baseline remains open. |
| S0-2 | Prepared-class catalog and behavior | In progress | All 112 controlled behavior trials completed on 12.4.2; basic movement/targeting observed. Seven special deletion/locality cases and large-creature model errors remain unresolved; see BEHAVIOR_12.4.2.md. |
| S0-3 | Occupant impact map | In progress | 24 integration areas and 86 pinned source files mapped; remaining caller audit open. |
| S1-1 | Infection scaffold and dependency checks | In progress | Built and loaded; isolated dependency-present/absent checks passed. Campaign setup acceptance remains open. |
| S1-2 | Basic infected tier/group definitions | In progress | All 67 definitions spawned through Ultimate with valid side, equipment, identity and cleanup; site integration remains open. |
| S1-3 | Vehicle/template contract | In progress | Foot lines, six persistent site types, controls, towns, strongholds, routine repair, roaming and capture responses and tactical support avoid conventional pools in the 684-check suite; remaining mission/convoy routes remain open. |
| S2-1 | Occupied-site lifecycle | In progress | Isolated contracts cover six persistent types and transient controls/towns/administrations. Native Redux campaign forced activation, cleanup of tracked units/groups/assets and second visits pass for one town and all six permanent-site categories (113 checks). Overflow rosters are retained. Native factory casualty/refill/revisit passes 18 checks. Player proximity, capture and player combat remain open. |
| S2-2 | Foot patrols and road controls | In progress | Controls, towns and roaming pass 37, 67 and 39 dedicated cases within the 684-check suite. Towns preserve approved per-visit regeneration. Redux navigation, connected players and repeated patrol circuits remain open. |
| S2-2a | Population-based town infestations | In progress | The approved 10â€“200 logistic, complete activation, all infected-held towns and ownership handoffs pass 67 town cases within the 684-check regression; 78 focused and 11 missing-dependency checks also pass. See TOWN_INFESTATIONS.md. Redux navigation, connected players and performance remain open. |
| S2-3 | Capture and persistence | In progress | Queued defenders block capture; roster death/reentry contracts pass. Administration clearing uses the actual native ownership/support transaction, including after building destruction. Full campaign ownership/rewards/save/reload/recapture remain open. |
| S3-1 | QRF and attack routing | In progress | Capture-triggered foot counterattacks pass 51 cases in the 684-check regression, including native distance activation, paid arrival handoff, town population startup and cleanup. Tactical support passes 70 additional cases, including rebuilding policy and remote context. Strategic walking hordes pass 114 cases; the superseded competitive prototype is retired. Connected-player rebuilding, remaining missions and special creatures remain open; see CAPTURE_COUNTERATTACKS.md and TACTICAL_SUPPORT_CONTRACTS.md. |
| S3-2 | Garrison repair | In progress | Routine paid foot arrivals and virtual repair pass 39 cases in the 340-check suite: original queue priority, cooldown/combat/ownership, active limits, roster handoff and cleanup. Redux travel, nearby players and restart persistence remain open. |
| S3-3 | Conventional force disposition | In progress | Response source audit records remaining vehicle, support, task and payment contracts. Complete route disposition and Invader campaign regression remain open. |
| S4-1 | Complete mission classification | In progress | Liquidation covers all four native conquest entry points. Other replacement families and automatic-trigger classification remain open. |
| S4-2 | Mission eligibility and common objectives | In progress | Liquidation target, capture, controller and dispatch integration passes 764 combined checks, 37 dispatch-focused checks and 11 dependency-absent checks. Town liberation and the five other replacement families remain open. |
| S4-3 | Existing outbreak mission adaptations | Backlog | Survivor civilian configuration. |
| S5-1 | Central spawn budget | In progress | Sites, controls/towns/administrations, routine repair, roaming, capture responses, tactical support, strategic hordes and competitive conquest use the budget in the 684-check suite. Towns have separate non-transferable full-population allowances. Remaining response/mission callers, terrain/player validation and performance remain open. |
| S5-2 | Special roles and escalation | Backlog | Largest types restricted to declared events. |
| S5-3 | Two distinct outbreak mission patterns | Backlog | End-to-end solo and group evidence. |
| S6-1 | Chernarus Redux site sweep | Backlog | Fix reproduced defects only. |
| S6-2 | Faction interaction regression | Backlog | Survivor side decision and final faction composition. |
| S6-3 | Player-facing clarity | Backlog | First-hour usability evidence. |
| S7-1 | Dedicated multiplayer and JIP | Backlog | Two clients; headless support decision based on tests. |
| S7-2 | Performance and cleanup soak | Backlog | 90-minute representative session. |
| S7-3 | Campaign progression and saves | Backlog | New campaigns only; staged save fixtures. |
| S8-1 | Reproducible release candidate | Backlog | Clean-install and artifact/source matching. |
| S8-2 | User and maintenance documentation | Backlog | Verified behavior and override ledger. |
| S8-3 | Acceptance and handoff | Backlog | Traceability, defect closure, user sign-off. |
| V-1 | Abandoned, repairable, drivable vehicles | In progress | Asset helpers pass 42 focused checks; town adapter passes 36 Altis-road lifecycle checks and 11 dependency-absence checks; Redux parking passes 163 checks across 49 towns. Player driving, garage and saves remain open. See ABANDONED_VEHICLES.md. |

## Working session: 12 November 2026

Sprint goal: establish a reproducible baseline and verified integration contracts.
The public fork and planning PR exist. Installed/source versions are pinned.
A fresh unmodified local campaign reached HQ. The prepared-class diagnostic
mission now completes with the installed Bohemia tools and dedicated server.
Model/skeleton errors keep the large-creature candidates unaccepted. The
unmodified Redux dedicated mission also completed background initialization;
campaign creation and save/reload still require client participation.

Resolved product question: the owner approved vanilla stand-ins by default,
with optional mod support for authentic modern Russian/NATO equipment.

Manual testing resumed after the owner's explicit authorization. The first local
session ended without saving; a fresh campaign has now completed a manual
persistent save and its files are archived with hashes. Process-restart reload
restored the same campaign and resources. Dedicated campaign testing is next.
Computer Use mouse actions work in menus; game keyboard input requires owner
assistance, which is recorded rather than treated as a successful automated input.

The foundation/tooling self-review is in [REVIEWS.md](REVIEWS.md). No completed
sprint gate or sprint retrospective is recorded yet.

## Working session: 13 November 2026

The owner resumed development without Computer Use. Continue source inspection,
builds and isolated engine tests; manual campaign acceptance remains outstanding.
The latest client was launched for the owner's own testing and is not controlled
by this work. The 12 November template run completed before the halt with 83
passing checks, including all 67 roles and cleanup; its report is now collected
from the completed log. The interrupted behavior batch has 58 of 112 results and
does not count as a completed test. Registration work overlaps baseline research
using verified classes and pinned APIs; neither Sprint 0 nor Sprint 1 is accepted.

The first protected campaign override replaces infected virtual garrison vehicle
lines with foot groups. All 25 upstream preference rows, war tiers, ordinary
WEST/EAST delegation and real initial-roster consumers passed. Combined template,
unit and garrison checks total 94. This does not establish live site spawning.

Combat bookkeeping now passes 120 combined dedicated checks on the updated
Ultimate 12.4.2 installation; the missing-dependency case passes 11. Real rifle
kills avoid human unconsciousness and surrendered-human penalties. Resource,
garrison and postmortem transactions are once-only in the tested server-local
cases. Player credit, ACE and multiplayer remain open. The earlier zero-vehicle-
query assertion was invalid because Arma rejected its test replacement; the
current fixture corrects it and proves the counter works on ordinary controls.
See `docs/research/VALIDATION_CORRECTIONS.md`. No sprint gate is closed.

The S5-1 reservation component was pulled forward as a technical dependency of
S2 live sites. It passes 20 dedicated checks covering competing requests, global
and shared-context limits, setting reductions, binding/death/deletion/cancellation,
lease expiry and cleanup; the full regression suite totals 140. Production site
and mission callers are still unconverted, so global campaign cap enforcement is
not claimed. Sprint order/gates remain acceptance targets rather than completed
labels. No Computer Use was performed during this development session.

The owner chose to preserve full site garrisons and bring remaining infected in
gradually from safe positions. Six persistent site types now use the server
budget, bounded placement, queued arrivals, capture guards and normal distance
cleanup. All 194 combined dedicated checks and 11 missing-dependency checks pass.
Interrupted scripts are reclaimed automatically as well as on reentry. The 112
raw behavior trials also completed; seven special deletion/locality assertions
and large-creature model errors prevent blanket catalog acceptance. Towns,
controls, administrations, responses, missions and campaign/save gates remain open.

Road/field controls now use guarded server spawning, complete transient queues,
legacy accounting and local contender capture. All 231 combined dedicated checks
and 11 dependency-absent checks pass; the new 37 checks cover selection, active
limits, simulation, ownership races, reset timing and empty cleanup. The first
run exposed two incorrect test-count expectations; source-confirmed corrections
passed the next run. On-road classification is not terrain-accepted by this VR
fixture. The owner chose per-visit town patrol regeneration and infected
administration strongholds with survivor rescues. These are the next site tasks;
reinforcement, roaming, response, mission and campaign gates remain open.

Town patrols now preserve native per-visit regeneration and size/support/frontline
selection, with bounded outdoor routes and queued budgeted arrivals. All 264
combined dedicated checks and 11 dependency-absent checks pass. Thirty-one town
checks cover selection, skips, real actors, routes, retries, cleanup and reentry;
two new budget checks cover raising the server context limit. The first town run
exposed a cached-limit bug, now corrected. Site fixture observations were corrected
for deferred object deletion and follower regrouping; an oversized diagnostic
record also caused an explicitly rejected intermediate run. The final report is
complete, source-matched and has no SQF/engine Error records. Administration
strongholds are next: capture requires clearing even if the building is destroyed,
while rescues remain separate. No sprint or campaign acceptance gate is closed.

Administration strongholds now preserve native per-visit regeneration with a
full budgeted infected queue. Death accounting, destruction and nearby territory
changes cannot bypass clearing. Separate survivor releases validate the rescuer,
keep escaped actors out of site cleanup and reward only surviving escapes. All
301 combined dedicated checks and 11 dependency-absent checks pass, including 37
new administration cases. Actual native capture and HR functions are exercised;
client interactions, Redux buildings, save persistence and mission wording remain
open. The tested artifact matches all 57 addon source files. The owner permits
routine foot reinforcements while players remain nearby, subject to cooldown and
combat checks; S3 source review is underway. No Computer Use or client launch was
performed, and no sprint acceptance gate is closed.

Routine reinforcement now uses paid basic infected on foot, native garrison
deficits and cycle quotas, a 600-second target cooldown, combat checks and safe
source selection. Arrivals transfer into the active site's saved roster without
duplicating actors or exceeding its limit. Offscreen repair remains virtual.
All 340 combined checks and 11 dependency-absent checks pass; the 39 new cases
exercise actual actor/resource/death behavior and injected arrival races.
The artifact matches all 66 addon source files. Long-distance Redux travel,
connected-player cleanup, cooldown persistence and real Invader campaign behavior
remain unaccepted. Native roaming, QRF/attack and mission routes still need work.
No Computer Use or client launch was performed, and no sprint gate is closed.

Roaming requests now select bounded foot routes for infected sources while
retaining native vehicle behavior for other factions. All 377 combined checks
and 11 dependency-absent checks pass, including 37 roaming cases. The initial
test exposed an invalid waypoint-result bug and a missing fixture tier setting;
both were fixed before acceptance. The final route uses actual outdoor navigation
points without depending on a vehicle spawn marker. All 73 addon sources match
the tested artifact. A 27-file response audit records the next capture/support
work and its differing payment/task contracts. Campaign, Redux, multiplayer and
save gates remain open; no Computer Use or client launch was performed.


## Working session: 14 November 2026 - Tactical support integration

Tactical foot support now retains native selection/locks and telemetry while
paying for actual infected births. Direct rebuilding constructors use validated
server policy, once-per-rebuild claims and a local execution handoff. Both pools,
arrival/garrison transfer, search/retreat, refunds and stopped workers pass in
the final 534-check dedicated regression. The focused suite passes 81 checks and
the dependency-absent suite 11; all 96 addon sources match the tested PBO.

The combined run exposed inherited remote execution context in spawned scripts;
the handoff now enters CBA's local frame queue first. Source review also corrected
the exact legacy mission argument guard. Failed/interrupted candidates remain
separate from final acceptance evidence. The owner chose nearby walking origins,
later town recapture, towns and permanent sites as origins, and native temporary
resource debt for the next major-horde increment. That feature is on its own
branch and does not enter this tactical integration.

Connected-player rebuilding, Redux travel, ordinary Invader campaign behavior,
multiplayer, performance and saves remain open. No sprint gate is closed and no
Computer Use, manual-client restart or Workshop publication occurred.


## Working session: 14 November 2026 - Strategic and conquest integration

Nearby infected towns and permanent sites can now launch one finite walking
horde, including later town recapture. Native temporary resource debt, shared
active limits, real arrivals, HQ/Petros outcomes and offscreen Invader territory
transactions are covered. Competitive races are unavailable without a ready
walking source and fail immediately on the first infected capture. A later
Rebel retake cannot reverse the loss.

All 684 combined dedicated checks, 45 focused conquest checks and 11
missing-dependency checks pass on the final stacked candidate. The PBO matches
all 117 production inputs; the report matches all 176 fixture/production hashes.
No engine/SQF Error records occur; 74 warnings are retained and reviewed.
Source review, parser regressions, PowerShell parsing and whitespace checks pass.
The completed dedicated server was stopped by verified process/profile identity.

The earlier failed retirement checks led to separate exact-group cleanup so
corpses no longer hold campaign slots. A later incomplete run ended when the
owner shut down the PC. Neither attempt is accepted as a passing regression.
The final source/fixture fixes and their focused checkpoints remain documented.

The owner chose survivor rescue and defense with a walking horde for infected
town liberation. Its separate branch has a pinned source audit and a nearby
origin selector; the no-nearby-origin political fallback is awaiting a decision.
Connected-player rewards/UI, real HC relay, Redux travel/performance, remaining
missions, special creatures, abandoned vehicles, multiplayer and saves remain
open. No sprint gate is closed and no Computer Use or manual-client update occurred.


## Working session: 14 November 2026 - Liquidation dispatch

The board and four conquest endpoints now route to infected-only Liquidation.
Russian takeover cancels without mission penalty. Native timer/reward judgment
is authorized. The 37-case focused run passes without engine/SQF errors; all
138 production inputs match Dispatch Dev1. Superseded competitive helpers and
34 old race cases are removed; strategic attacks remain unchanged. The combined
suite is running. Next: collect and review integrated evidence, validate actual
missing dependencies, then integrate the reviewed stack. No Computer Use or
manual-client update occurred; no sprint gate is closed.


Liquidation dispatch integration result: all 764 combined checks passed, with
no engine/SQF errors. The actual dependency-absent run passes 11 checks. Retained
combined warnings are 16 startup notices, 50 object-deletion notices and five
absent-fixture-commander notifications. All 138 production inputs and the addon
match Dispatch Dev1. Review supports merging the selector/capture, controller
and dispatch stack together; it does not close a gameplay or sprint gate.

The owner clarified Horde Interception's next increment: full horde activation,
separate temporary allowance, developer-tuned size, town/permanent-site endpoints,
arrival reinforcement/attack, and continued travel after Russian takeover.
The source audit records mission-board, intel and strategic convoy callers.
Interception implementation and its acceptance tests remain next work.


## Working session: 14 November 2026 - Interception foundation

Implemented endpoint/route planning and a separate preparing-horde budget on
codex/horde-interception. The owner-approved full-horde rule is distinct from
strategic attack queues. Initial tuning is 40-120 basic infected by war level.
Config/PBO and parser checks pass; focused engine validation is running. No task,
formation staging, march, arrival reinforcement/attack, reward or public request
integration is claimed yet. No Computer Use and no manual-build replacement.


Interception Dev1 focused result: 78 checks pass, including the existing budget
regression, 44 new route/allowance checks and actual 40/120-member creation under
full shared usage. The stopped-worker fixture now observes engine termination
before asserting refusal; the initial failed result is retained. All 141
production inputs match the build. Town regression is running. Task/march/
arrival settlement and public entry points remain unimplemented.


Foundation follow-up: the same Interception Dev1 artifact passes 78 town
regression checks and 11 actual dependency-absent checks, without engine/SQF
errors. All 141 production inputs remain unchanged. The user also confirmed
Russian supply convoys should remain background military activity without
player-facing assignments. PR 27 remains draft while formation, task lifecycle,
arrival handoff and complete dispatch are implemented and integrated.


## Working session: 14 November 2026 - Interception formation

The child branch codex/interception-formation adds complete hidden staging,
atomic whole-horde release, real-death/missing-member bookkeeping and exact
cleanup after interrupted construction. Formation Dev2 passes 47 focused and
11 actual dependency-absent checks. Both 40 and 120 members stage and release;
cleanup leaves no actor/group/budget residue. A movement defect found in Dev1
was corrected by waiting for prepared AI initialization and superseding its
startup movement order at departure. Every tested group leader now advances at
least ten metres toward the destination. Three fixture faults and the movement
failure remain recorded as rejected evidence, not accepted results.

All 147 production inputs match the candidate. Combined regression is running
because the initialization hook touches the shared spawn helper. Controller,
arrival handoff, task settlement, mission-board/intel dispatch and background
Russian convoy separation remain open. This increment does not close S4 or any
campaign acceptance gate. No Computer Use or manual-build replacement.


Movement follow-up: review strategic/capture-response walking groups for the
same prepared-class startup movement order. Their current source also assigns
group waypoints; the observed stationary-member failure is from the new
formation test, not proof that those separate controllers have failed a live
travel test. Track actual destination progress in their eventual travel checks.


Formation regression follow-up: Dev2's combined result is rejected: 842/844
checks passed, with remote Liquidation fixture ownership and stationary leader
failures. Diagnostics found the fixture overwrote published variables locally;
published resets fix its twelve remote trials. A second local spawner-reset
cleanup error is also retained. Production Liquidation code is unchanged.
The movement failure is real: a living walker kept its MOVE command but made no
progress until its destination order was reissued. Dev3 adds guarded periodic
recovery and explicit monitor cleanup. Targeted validation is running; the
component is not accepted as integrated and PR 28 remains draft.


Formation checkpoint: Dev3 passes all 85 targeted capture/formation checks and
11 actual missing-dependency checks without engine/SQF errors. It recovers a
confirmed stopped member, preserves native pursuit and removes its monitor on
retirement or owner interruption. All 148 production inputs match the tested
artifact. The earlier artificial stop did not stop its actor and is retained
as rejected fixture evidence. Dev3 full combined suite is NOT_RUN; the earlier
Dev2 combined report remains rejected. Run the full suite on the next integrated
controller/dispatch candidate. No test servers remain running from this session.
Next implementation: server-owned task lifecycle and first-arrival settlement,
then survivor handoff, requested/intel dispatch and background Russian convoys.


Interception task checkpoint: Dev3 passes 45 focused task checks and 11 actual
missing-dependency checks without engine/SQF errors. First arrival fails the
task, Russia takeover continues, genuine full elimination uses event time,
settlement rewards occur once, and independent task retention preserves living
survivors. Invalid deadlines cancel without mission rewards/penalties. Three
parser tests pass. Capture/formation regression also passes all 85 checks
without engine/SQF errors. All 154 production inputs and the PBO match the
manifest after testing; the isolated test server exited. Full combined and
connected-player checks are still open. Keep PR 30 draft. Public creation,
owner supervision, arrival reinforcement/attack and board/intel dispatch remain
unfinished. Arrival capacity and offscreen-town persistence questions remain
pending. Background Russian convoys were separately merged in master PR 29;
that change is not yet integrated into this stacked interception worktree.
## Working session: 14 November 2026 - Background Russian supply convoys

Owner decision: automatic Russian supply convoys remain background military
activity and do not offer missions. The separate `codex/background-convoys`
branch implements that exact strategic path, preserving ordinary campaigns and
other native convoy entry points pending their replacement work. No private
campaign save or manual install is changed.

The first real destruction case exposed Ultimate's late cargo-killed handler.
Dev2 moves it before vulnerability/departure and tests both parked and departing
truck destruction. Rejected fixture/candidate evidence is preserved. Dev2 passes all 64 focused checks, 11 actual missing-dependency checks and three
collector parser unit tests. No engine/SQF errors occur. All 140 production inputs
and the PBO match the manifest; both isolated servers exited. Full combined
regression is NOT_RUN for this candidate.
Full catalog, driving, connected players, campaign resilience and sprint gates
remain open. See [background convoy details](../research/BACKGROUND_CONVOYS.md).


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


Town reinforcement checkpoint: the approved persistent extra roster is implemented
separately from the regenerated logistic population. Dev1 passes 88 focused town
checks and 11 actual missing-dependency checks, without engine/SQF errors. Tests
cover 203 simultaneous actors, one baseline/one extra casualty, native garrison
loading, a 202-actor revisit and clearance until the remaining extras die.
The corrected controller retention fixture is merged. Combined validation is
running on this same 160-input candidate. Live/offscreen horde adoption, hostile
arrival combat, public mission dispatch and full campaign saves remain open.


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


Offscreen arrival work: a separate feature branch adds the atomic survivor-roster
transaction while the parent combined suite remains frozen. It refuses observed
or live destinations, appends extras above capacity only after physical arrival,
and prevents duplicate additions/resource refunds. Twenty-three focused cases
are authored; engine execution awaits the current combined server. Packaging,
three parser tests and eleven actual missing-dependency checks pass. Public
calling paths, active adoption and administration arrivals remain unfinished.


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


Active interception arrivals: 59 focused offscreen/live handoff checks and 11
actual missing-dependency checks pass without engine/SQF errors. The 162-input
candidate preserves full shared queues, expands an in-progress town population,
accepts two arriving groups, retains adopted actors through old-owner cleanup,
and requires their deaths for clearance. Three parser tests pass. Run full
combined regression for the budget change. Administration persistence is now
approved; its extra queue, casualty/replacement accounting and capture guard
remain to implement. Public arrival ownership and dispatch are still unfinished.


Administration reinforcement work: the owner approved persistent survivors and
permanent casualties, plus a 50-metre interception arrival boundary. Inspection
found administration icons excluded from Ultimate's saved garrison list. This
branch adds a tagged native plugin save/load payload, separate extra spawning,
casualty/replacement accounting, guarded capture and actual icon endpoints.
All 38 focused engine checks (27 stronghold-specific and 11 common), eleven
actual missing-dependency checks, packaging and three parser tests pass without
engine/SQF errors. The 167-input candidate is unchanged after testing. Its full
1040-check combined regression completed with 1038 passing checks and 67 passing
roles, but two task assertions sampled queued native updates too early. The
failed report is retained. A bounded wait for the expected task state and both
resource pools passes all 64 focused task checks without changing production
reward logic. The corrected combined gate will cover the stacked arrival-owner
and public-dispatch candidate after focused verification. The parent's different
build passed 1013 checks and merged in PR 32. Full campaign save and sprint
acceptance remain open. See ADMINISTRATION_REINFORCEMENTS.md.

Automatic interception aftermath is drafted in a separate feature branch. The
lifecycle supervisor now calls complete-group handoffs, retains observed actors,
and uses native capture decisions against fully spawned hostile garrisons.
Cleared administrations remain permanently cleared, per the owner's answer.
All 35 focused runtime checks pass after correcting deletion timing, observer
setup and missing native town data in the fixture. Both rejected reports are
retained; no production code changed during diagnosis. Packaging, three parser
tests and eleven actual missing-dependency checks pass. Combined regression and
public dispatch remain unfinished; see INTERCEPTION_AFTERMATH.md.

Horde Interception creation and dispatch are now drafted in a separate branch.
The actual 40-120-member formation is prepared before public task registration;
requests, direct calls, scheduler routing, both menu labels and convoy-route intel
use the new mission. Russian automatic supplies remain background activity.
Packaging, three parser tests and eleven actual missing-dependency checks pass.
All 36 focused runtime checks pass, including the actual 40-member horde while
both shared slots are reserved. The rejected first report preserves the fixture's
incorrect shared-versus-total capacity assertion; production code is unchanged.
The integrated 1089-check regression is the next gate; parent regressions remain
separate. See INTERCEPTION_DISPATCH.md for scope and open acceptance work.


Integrated interception checkpoint: InterceptionDispatch Dev1 passes 1089 combined
checks and 67 role spawns without engine/SQF errors. All 177 inputs and the PBO
match the tested manifest. Administration persistence, automatic arrival aftermath
and public mission dispatch can integrate together through PR 35. The earlier
1040-check fixture failure remains rejected evidence. Connected play, travel,
actual campaign save/load and sprint acceptance remain open; see REVIEWS.md.

Friendly delivery prerequisite: the owner confirmed the native HQ radii, actual
Rebel-held permanent-site boundaries, and exclusion of cleared administrations.
A read-only destination helper and 25 specific cases are drafted. Packaging,
three parser tests and eleven actual missing-dependency checks pass; 36 focused
engine checks remain NOT_RUN while the parent integrated regression is active.
Supplies Seizure and Extraction controllers/public dispatch remain unfinished.
See FRIENDLY_DELIVERY.md.

Friendly delivery checkpoint: all 36 focused checks and 11 actual missing-
dependency checks pass without engine/SQF errors. All 178 inputs and the PBO
match the frozen manifest; completed servers exited. HQ and the six approved
site types are covered. Supplies and Extraction mission controllers remain
unimplemented. The owner corrected Extraction to wait until all survivors are
rescued/killed or the deadline, then succeed only if at least one was rescued.

Extraction ledger drafted to honor all-survivors-or-deadline settlement. Dev1
passes packaging, three parser tests and 11 missing-dependency checks. Focused
run rejected: 41/42 checks pass, but EntityDeleted object/array handling causes
two script errors and misses the deletion flag. Fix and retest; see
EXTRACTION_LEDGER.md. Public Extraction missions remain unimplemented.

Extraction ledger Dev2 corrects the observed EntityDeleted argument shape. All
42 focused checks, 11 actual missing-dependency checks, packaging and three
parser tests pass without engine/SQF errors. The 182-input manifest and PBO match
after execution; both servers exited. PR 38 can integrate the internal ledger.
Its public mission/controller/rewards remain open. Survivor disposition after
rescue (manpower pool or usable AI) is awaiting owner input.

Supplies Seizure asset work: declared faction service-truck pools with vanilla
fallbacks, safe empty creation and neutral native capture/resource handling are
drafted. Packaging, three parser tests and 11 missing-dependency checks pass.
The 35-check focused report remains rejected because its despawner retention
check accidentally called the test stub. Wire the actual native function and
repeat. Full mission creation, objectives, rewards and dispatch remain open.
See SUPPLIES_SEIZURE.md. Ownership-after-spawn policy awaits owner clarification.

Supply-truck fixture correction: all 35 focused checks now pass using the real
native vehicle despawner. All 184 production inputs and the PBO remain unchanged;
11 actual missing-dependency checks and three parser tests also pass. No engine/
SQF errors; completed servers exited. The owner confirmed recovery continues if
Rebels or Russia capture the truck settlement. Eligible source-location types
await clarification. Task/controller/dispatch remain unfinished.

15 November Supplies Seizure controller: 43 focused engine checks and 11 actual
missing-dependency checks pass, with no engine/SQF errors. The 194-input build
creates an actual truck/task, preserves recovery across ownership changes,
settles delivery/destruction/deadlines once, retains captured trucks and defers
unsafe cleanup. Source policy is now confirmed: fuel only in towns, all three
truck roles at permanent sites. A captured permanent source itself can satisfy
delivery. Add an explicit test of that clarified case before integration.
Public dispatch/menu/caller coverage remains unfinished.

## Supplies Seizure controller checkpoint: 15 November 2026

The controller passes 45 focused engine checks and 11 actual missing-dependency
checks. Capturing its permanent source site completes recovery in place, with
once-only rewards and the usable truck registered for saving. Towns provide fuel
trucks only; all six conventional permanent-site types permit the three approved
service roles. Public dispatch and combined regression remain open.

## Supplies Seizure integration: 15 November 2026

Supplies Seizure creation, settlement, retained usable trucks, captured-source
delivery and public logistics dispatch pass 1228 combined engine checks and 67
role-spawn records. Focused dispatch, actual absent-dependency and parser checks
also pass. No engine/SQF errors; warnings are classified in SUPPLIES_SEIZURE.md.
The manual installation is unchanged. Visible menus, connected driving/rewards,
real terrain travel, HC/JIP and campaign disk saves remain open. Extraction
scene and Humanitarian Aid ledger drafts are separate increments, outside this
combined build. No sprint acceptance gate is closed.

## Extraction scenes and Humanitarian Aid ledger: 15 November 2026

Extraction's infected-only town/base/outpost/airfield sources and sheltered 2-6
survivor factory pass 35 focused engine checks. Humanitarian Aid's 180/90-second
unloading ledger and ownership cancellation pass 37 after correcting deletion
versus destruction timing. Both increments pass actual missing-dependency and
parser/build checks. Their reports retain precise build identities and rejected
historical evidence. Public Extraction and Aid tasks, interactions and rewards
remain unfinished; Extraction's post-rescue disposition awaits owner input.

## Elimination controller checkpoint: 15 November 2026

The public Elimination draft names the primary type in a static search area,
uses other approved special types among its basic/special escort, and keeps the
hunt active across settlement capture. Dev2 passes 40 lifecycle and 11 actual
missing-dependency checks; Dev1 passed 38 public-dispatch checks. All 236 Dev2
production inputs match the packaged artifact. Combined integration, connected
combat/rewards, terrain, HC/JIP and performance remain open. No sprint acceptance
gate is closed and the manual installation remains unchanged.


## Extraction release prerequisite: 15 November 2026

The guarded release interaction is implemented on codex/extraction-release.
Dev2 passes 89 combined ledger/scene/release checks and eleven dependency-absence
checks. See [EXTRACTION_RELEASE.md](../research/EXTRACTION_RELEASE.md). Public
mission dispatch, rewards, post-delivery disposition and connected-player
acceptance remain open. This is not completion of the Extraction mission.

## Extraction controller and public requests: 15 November 2026

Draft PR 52 supersedes the release-only checkpoint and includes PR 51. All owner
decisions on disposition, deadlines and guards are implemented in the candidate:
2-6 sheltered survivors, four basic managed guards, guarded release, incremental
manpower/inventory delivery, all-resolved or deadline settlement, native rewards
and undelivered squad cleanup. Commander requests, five legacy rescue routes and
civilian offers route to Extraction. Dev4 passes 150 combined Extraction checks,
11 missing-dependency checks and three parser tests; all 287 inputs/PBO match.
The full cross-system regression is running in the isolated ExtractionFull
profile. Connected players, conversations/actions, HC/JIP, saves and campaign
acceptance remain open. No sprint gate is closed. Manual Dev9 is unchanged.

## Remaining campaign entrypoints: 15 November 2026

Rescue route audit adds the sixth endpoint, RES_Shipwreck (43 focused checks and
11 missing-dependency checks). Destroyed infected towers no longer dispatch
repair crews or rebuild through REP_Antenna (30 catalog checks and 11 dependency
checks). Gang storyline/assault routes stay native. DealerUnlock skips the intro
while retaining normal native intel/progression triggers, real trader/stock and
save fields (28 focused checks and 11 dependency checks). Source/PBO manifests
match each separate candidate. Rejected attempts remain documented.

All increments remain draft pending combined integration and connected-player,
terrain, network and save acceptance. Manual Dev9 is unchanged; no sprint gate
is closed. Longer survivor-defense and Extraction regressions are still running
on their previously frozen builds, which do not include these later increments.

Parent-controller checkpoint: real native task registration, human rescue,
preparation, linked horde, capture/reward/failure transactions and interruption
cleanup pass within 104 focused checks; the missing-dependency suite passes 11.
Source review corrected rewards to follow the native five-second tier update,
including its effect on the HR cap. The 127-input candidate and all 190 focused
report inputs match. The combined 777-case regression passes with no engine/SQF
Error records, including all 67 role spawns. Its 77 retained warnings are reviewed
in TOWN_LIBERATION.md; the completed server was stopped by verified identity.
The owner chose to retain the native mission scene and survivor vehicle; that
work and campaign dispatch remain open. The owner subsequently selected peaceful
joining when no nearby eligible horde origin exists; the isolated dispatch branch
is implementing that decision. No Computer Use or manual-client update occurred.

Campaign-dispatch checkpoint: the approved peaceful fallback and native townBattle
entry pass within 124 focused checks and eleven missing-dependency checks on a
130-input candidate. The source comparison preserves the remaining resourcecheck
body. All 196 focused inputs match, with no engine/SQF Error records. Busy claims
and missing navigation/HQ data cannot trigger a free political capture. The
parent controller's separate 777-case regression is incorporated; combined
dispatch regression and an actual campaign economy cycle remain NOT_RUN.


## Working session: 15 November 2026 - Survivor-defense integration

Integrated the earlier controller, retained scene and campaign-dispatch branches
with the current six-category mission redesign and parked-vehicle adapter on
codex/liberation-integration. The retired competitive request path remains
retired. The scene/dispatch integration builds, three parser checks pass, and
all eleven actual dependency-absence checks pass. Dev2 has 293 verified source
inputs. The focused engine suite is running; its expected 249 checks include
scene assembly and the parent controller, which were previously NOT_RUN.
No source-level merge is treated as runtime acceptance. Connected recruitment,
visible effects, Redux walking routes, pacing and campaign saves remain open.

15 November combined integration review: CampaignIntegration Dev1 passes
1,806 isolated checks and 67 roles, with 322 source/PBO identities verified and
no recorded engine/SQF or native Antistasi Error-level records. Earlier rejected
Extraction evidence is retained. This supports source integration, not sprint
or release acceptance; native Redux startup defects, connected players, JIP,
full mission playthroughs and performance remain open. See CAMPAIGN_INTEGRATION.md.

15 November native Redux persistence spike: full new-campaign initialization,
native saveLoop and process-restart loadServer restore the tested town/admin
extras, dealer and HQ state (9 write + 10 read assertions). Both clean-log gates
fail on recorded native/terrain errors; no sprint gate is closed. See
NATIVE_CAMPAIGN_SAVE.md and retained full RPTs. The owner approved the separate
A3U-Redux-Fixes repository. Connected-player acceptance remains open.

15 November Redux companion validation: the independent population lookup fix
removes all 49 repeated-load population errors from each full campaign phase.
Native save/restart/reload assertions still pass (9 write, 10 read). Clean-log
gates remain failed with 14 writer and 11 reader error records, including the
previously recorded marker, no-player initialization and pricing defects.
No sprint/release gate is closed. See REDUX_COMPANION_VALIDATION.md.

15 November loot-crate valuation: owner approved configured-price reimbursement.
The independent Redux fix passes full native save/restart/reload with a real
crate: 1000 live funds + 100 crate value = 1100 saved/restored funds. Both phases
pass 11 assertions; both clean-log gates remain failed on 11 unrelated records.
See REDUX_CRATE_VALUATION.md. No Infection production code changed.

15 November parking compatibility: the independent Redux fix restores six native
vehicle slots without expanding their footprints and reconnects the orphan to
resource_10 under owner-authorized judgment. Full native write/restart/read each
pass 13 assertions. Clean-log gates still fail on five writer/six reader records:
startup/object errors plus a later helicopter-price error in the reader. No
population, loot-crate-price or marker errors remain. See
REDUX_PARKING_VALIDATION.md. Client/JIP/performance and release gates remain open.

15 November black-market fallback: the independent Redux fix preserves the native
28800 helicopter quote without the false missing-HQ error. Full native write and
restart/read pass 16 assertions each, including 75-second background windows.
Both whole-log reports still fail on five startup/object records; no pricing,
population or parking errors occur. See REDUX_MARKET_VALIDATION.md. Long-session,
client/JIP and release gates remain open.

15 November SmartMarker lifecycle guard: native write/restart/read pass 16
assertions per phase with 75-second windows and no Old Man marker startup error.
Read-only campaign state confirms absent commanderX and HC synchronization to
its subordinate only. The collector now catches uppercase ERROR records too;
five remaining records include a previously missed addon-initialization error.
The earlier market log contains six under the corrected rule (old reports are
preserved). See REDUX_SMART_VALIDATION.md. Clean-log and release gates stay open.

15 November High Command deferral: the independent Redux fix waits for a
synchronized commander, then invokes native HC. Eight focused lifecycle checks
cover late leaders, duplicate scheduling and deleted scopes; ready-leader and
Altis checks pass. Full native write/restart/read pass 17 assertions per phase
and 75-second windows. Missing-leader errors are gone; two missing-object records
and an addon-init error still fail clean-log acceptance. See
REDUX_HC_VALIDATION.md. Connected-player/UI/JIP and release gates remain open.

15 November Curator activation: bounded diagnosis proves both late requests are
for already-active addon identities. The independent wrapper returns the current
set for those redundant Redux server requests while preserving native handling
elsewhere and for new/malformed requests. Uninstrumented campaign save/reload
pass 18 assertions each and 75-second windows; all 2874 Curator addons remain
available. Only two missing-object error records still fail the clean-log gate.
See REDUX_CURATOR_VALIDATION.md. No client or release gate is closed.

15 November HQ inventory correction: complete-mission traces identify the two
missing objects as HQ crate backpacks removed by the early Eden attribute.
Independent Redux Fixes defers that exact empty-cargo request until simulation
starts. Native uninstrumented write/restart/read now pass 19 assertions per
phase, including empty physical HQ cargo before JNA and 75-second background
windows, with zero records under the unchanged error matcher. Six native
delegation checks pass on each of Redux and Altis; 34 companion evidence tests
and eight campaign/parser tests pass. See REDUX_CRATE_VALIDATION.md. This closes
the bounded dedicated-server startup/save/reload error check, not the broader
baseline, connected-player, JIP, manual playthrough, performance or release gates.

16 November native site expansion: seven categories pass two complete visits
(113 checks), alongside 19 native campaign checks and zero matched errors.
The rejected Dev1 fixture and corrected Dev2 evidence are retained separately.
No production limits were increased. Full roster accounting includes queues;
combat-driven replacement, full-map coverage and multiplayer remain open.

16 November native casualties: corrected Dev2 passes 18 checks and 19 campaign
checks with zero matched errors. Four killed factory defenders stay removed;
four queued defenders replace them and the reduced roster survives a revisit.
The rejected fixture initialization error is retained separately. See
NATIVE_CAMPAIGN_CASUALTIES.md. Player combat, casualty save/reload, capture and
multiplayer remain open; no production changes or other faction work occurred.

16 November casualty persistence: native save and fresh-process load retain the
reduced factory_1 roster (16 minus four deaths = 12). Six write and ten read
checks pass alongside 19 campaign checks per phase and zero matched errors;
the writer also repeats all 18 casualty checks. See NATIVE_CASUALTY_SAVE.md.
This is a sampled permanent-garrison result, not broad progression, combat,
multiplayer or release acceptance. Production source is unchanged.
