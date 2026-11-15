# Product backlog

The acceptance criteria and test requirements are in [PROJECT_PLAN.md](PROJECT_PLAN.md).

Liquidation selection, guarded capture, task settlement and public dispatch are
tracked in [LIQUIDATION.md](../research/LIQUIDATION.md). Dispatch Dev1 passes 37
focused checks, 764 combined checks and 11 actual missing-dependency checks. Earlier capture
and controller results remain recorded separately. Campaign acceptance is open.
[PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md) records the user's amendments.
Status is evidence-based; successful packing does not complete a gameplay story.

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
| S0-1 | Versions, dependencies, clean local and dedicated baseline | In progress | Local save and process-restart reload verified with matching ID/resources; dedicated campaign open. |
| S0-2 | Prepared-class catalog and behavior | In progress | All 112 controlled behavior trials completed on 12.4.2; basic movement/targeting observed. Seven special deletion/locality cases and large-creature model errors remain unresolved; see BEHAVIOR_12.4.2.md. |
| S0-3 | Occupant impact map | In progress | 24 integration areas and 86 pinned source files mapped; remaining caller audit open. |
| S1-1 | Infection scaffold and dependency checks | In progress | Built and loaded; isolated dependency-present/absent checks passed. Campaign setup acceptance remains open. |
| S1-2 | Basic infected tier/group definitions | In progress | All 67 definitions spawned through Ultimate with valid side, equipment, identity and cleanup; site integration remains open. |
| S1-3 | Vehicle/template contract | In progress | Foot lines, six persistent site types, controls, towns, strongholds, routine repair, roaming and capture responses and tactical support avoid conventional pools in the 684-check suite; remaining mission/convoy routes remain open. |
| S2-1 | Occupied-site lifecycle | In progress | Six persistent types and transient controls/towns/administrations pass isolated spawning/cleanup/reentry checks, including full queued rosters and stopped-controller recovery. Redux campaign acceptance remains open. |
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
| V-1 | Abandoned, repairable, drivable vehicles | Backlog | Included in this repository by the latest user correction. |

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
