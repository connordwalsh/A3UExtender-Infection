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
| S1-3 | Vehicle/template contract | In progress | Foot garrison-line checks pass in the corrected 120-check suite; site/support/convoy callers still need tested bypasses. |
| S2-1 | Occupied-site lifecycle | Backlog | All used site types, cleanup and reentry. |
| S2-2 | Foot patrols and road controls | Backlog | Urban/rural paths and bounded cleanup. |
| S2-3 | Capture and persistence | Backlog | Capture/reload/recapture at four site types. |
| S3-1 | QRF and attack routing | Backlog | Foot responses, costs, timeout and cancellation. |
| S3-2 | Garrison repair | Backlog | Ownership, cooldown, player proximity and cap. |
| S3-3 | Conventional force disposition | Backlog | Occupant-only changes; Invader regression. |
| S4-1 | Complete mission classification | Backlog | Manual and automatic triggers. |
| S4-2 | Mission eligibility and common objectives | Backlog | Success/failure/timeout/no-spawn outcomes. |
| S4-3 | Existing outbreak mission adaptations | Backlog | Survivor civilian configuration. |
| S5-1 | Central spawn budget | In progress | Server reservation/binding core passes 20 budget checks within the 140-check suite; production callers, spatial rules, pacing and performance remain open. |
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
