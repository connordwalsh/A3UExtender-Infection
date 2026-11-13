# Product backlog

The acceptance criteria and test requirements are in [PROJECT_PLAN.md](PROJECT_PLAN.md).
[PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md) records the user's amendments.
Status is evidence-based; successful packing does not complete a gameplay story.

| Story | Work | Status | Evidence / next check |
| --- | --- | --- | --- |
| S0-1 | Versions, dependencies, clean local and dedicated baseline | In progress | Local save and process-restart reload verified with matching ID/resources; dedicated campaign open. |
| S0-2 | Prepared-class catalog and behavior | In progress | All 112 controlled behavior trials completed on 12.4.2; basic movement/targeting observed. Seven special deletion/locality cases and large-creature model errors remain unresolved; see BEHAVIOR_12.4.2.md. |
| S0-3 | Occupant impact map | In progress | 24 integration areas and 86 pinned source files mapped; remaining caller audit open. |
| S1-1 | Infection scaffold and dependency checks | In progress | Built and loaded; isolated dependency-present/absent checks passed. Campaign setup acceptance remains open. |
| S1-2 | Basic infected tier/group definitions | In progress | All 67 definitions spawned through Ultimate with valid side, equipment, identity and cleanup; site integration remains open. |
| S1-3 | Vehicle/template contract | In progress | Foot lines, six persistent site types, controls, towns and administration strongholds avoid conventional pools in the 301-check suite; support/convoy routes remain open. |
| S2-1 | Occupied-site lifecycle | In progress | Six persistent types and transient controls/towns/administrations pass isolated spawning/cleanup/reentry checks, including full queued rosters and stopped-controller recovery. Redux campaign acceptance remains open. |
| S2-2 | Foot patrols and road controls | In progress | Road/field controls pass 37 checks and towns pass 31 within the 264-check suite. Towns preserve approved per-visit regeneration. Terrain navigation and repeated patrol circuits remain open. |
| S2-3 | Capture and persistence | In progress | Queued defenders block capture; roster death/reentry contracts pass. Administration clearing uses the actual native ownership/support transaction, including after building destruction. Full campaign ownership/rewards/save/reload/recapture remain open. |
| S3-1 | QRF and attack routing | Backlog | Foot responses, costs, timeout and cancellation. |
| S3-2 | Garrison repair | In progress | Routine paid foot arrivals and virtual repair pass 39 cases in the 340-check suite: original queue priority, cooldown/combat/ownership, active limits, roster handoff and cleanup. Redux travel, nearby players and restart persistence remain open. |
| S3-3 | Conventional force disposition | Backlog | Occupant-only changes; Invader regression. |
| S4-1 | Complete mission classification | Backlog | Manual and automatic triggers. |
| S4-2 | Mission eligibility and common objectives | Backlog | Success/failure/timeout/no-spawn outcomes. |
| S4-3 | Existing outbreak mission adaptations | Backlog | Survivor civilian configuration. |
| S5-1 | Central spawn budget | In progress | Six persistent site types and transient controls/towns/administrations use the budget in the 301-check suite, including runtime limit increases. Other callers, terrain/player validation and performance remain open. |
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
