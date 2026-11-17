# Native Redux Extraction failure probe

`start-campaign-probe.ps1 -ExtractionLifecycle` extends the normal isolated
campaign startup/save checks. It calls the public server missionRequest with
RES and silent notification, without replacing selectors, scene factories,
ledgers, task endpoints, rewards or cleanup. No player is fabricated.

Thirteen checks require eligible nearby infected locations, public dispatch,
actual task registration, an eligible source, 2-6 healthy survivors and four
initialized infected guards, then native CREATED task state. Engine deaths of
all survivors must settle the task as FAILED with no rescue credit. The native
one-minute cleanup must remove tracked survivors/guards/groups and release the
spawn budget while preserving HQ. No task state or cleanup timer is forced.

Dev1 passes all 13 Extraction checks and 19 campaign checks. Five collector tests and launcher parsing pass.
This covers no player interactions, survivor delivery/success, multiplayer,
task retirement after the native 10-30 minute display period, or performance.


## Dev1 result (16 November 2026)

The public request selects Zelenogorsk and creates two healthy survivors plus
four initialized infected guards. Both native task stores record CREATED, then
FAILED after both survivor deaths. No rescue credit is awarded. The unchanged
one-minute cleanup removes all tracked actors/groups, releases the mission's
budget records and leaves Petros, HQ crate and flag intact. All 13 assertions
and the 19 campaign startup/save assertions pass with zero matched errors.

Evidence is in `evidence/sprint-6/native-campaign-extraction-dev1`: exact helper,
launch receipt, raw RPT, both reports and both build manifests. All 324 production
source inputs and helper hashes match. Production PBOs are unchanged. The exact
isolated server has exited. This samples the public request/failure/asset path
at one town; successful player extraction and multiplayer remain open.

## Successful Extraction validation in progress

The optional `-ExtractionLifecycle -ExtractionSuccess` probe uses the trusted
server AI release entry with an existing vanilla unit. It rejects that AI at the
public player entry, checks native recruit initialization, then places each
released survivor at HQ. Native ledger conversion must award incremental
manpower and recover inventory, keep the task pending while survivors remain,
and settle success with exact funds only after all survivors are resolved.
The normal delayed asset cleanup and stable rewards are checked. No task state,
reward endpoint, deadline or cleanup timer is replaced. Ten collector tests and
PowerShell parsing pass; engine validation is pending. This is not a player
interaction, travel, deadline, multiplayer or faction implementation test.

### Success Dev1 result (16 November 2026)

All 24 success checks and 19 native campaign startup/save checks pass with zero
matched errors. Two survivors join the trusted AI rescuer and receive native
recruit initialization. Controlled HQ deliveries increase manpower from 8 to
11 (factor 1.5), return four FirstAidKits, and award exactly 200 funds. The task
remains CREATED after the first delivery and becomes SUCCEEDED after the last.
The unchanged cleanup removes tracked actors/groups and releases the mission
budget; rewards remain stable and HQ remains intact. The isolated server exited.

`evidence/sprint-6/native-campaign-extraction-success-dev1` contains the raw RPT,
exact helper inputs, launch receipt, build manifests, strict reports and hashes.
Of 326 production inputs, 324 match byte-for-byte; two truck guard files differ
only in Git checkout line endings, with the frozen build sources verified
against the manifest. All four helper input hashes match. No production or
faction changes were made. Self-review confirmed the delivery assertion uses
the actual HQ marker, and the probe changes no native settlement or timer.
Player interaction, real escort travel, mixed rescue/death native outcomes,
deadline behavior, task display retirement and multiplayer acceptance remain
open. This result does not complete Sprint 6 or release acceptance.

## Mixed rescue/death native case

The optional `-ExtractionLifecycle -ExtractionMixed` test follows the same
trusted AI release and HQ delivery path for one survivor, verifies the mission
remains pending, then kills the remaining survivors through engine damage. It
requires native success only after all are resolved, one-survivor manpower and
money credit, inventory recovery and normal delayed cleanup. No production
controller, ledger, deadline or reward endpoint is replaced. Native execution
is pending; this is not player escort or deadline acceptance.

Mixed Dev1 is rejected: public dispatch selected outpost_27, but the controller
reported guard_initialization_failed before registering the task. Only three
checks ran, with task_registered failing; the mixed-outcome checks did not run.
All 19 baseline campaign checks pass and zero matched errors were recorded.
Preserved evidence: native-extraction-mixed-dev1-rejected. Source review shows
that the guard callback rejects units outside the source boundary, while guard
position search currently has no source-area constraint; this is a candidate
cause, not yet a proven diagnosis. Preserve the original failure when testing
that path. Do not count a successful different random location as its fix.

The targeted trace confirms the cause at outpost_27: a guard at
[3001.5,5352.5,0] had initialized successfully, the mission was not settled, and
inArea returned false. The unchanged callback rejected it. The compiled trace
receiver was verified. Evidence: native-extraction-guard-trace1.

Candidate correction: add an optional area constraint to the bounded outdoor
search and shared spawn transaction. Extraction passes its source marker as the
area without enabling garrison activation/tracking. Out-of-area candidates are
rejected before creation, and the transaction rechecks the final position.
The guard callback remains as a final check. Three engine search assertions
cover contained, outside, and missing areas. Native targeted and combined runs
are in progress; 70 repository evidence/tool tests pass. No manual install changed.

Corrected targeted Dev1 passes all 24 mixed Extraction and 19 campaign checks,
zero matched errors. The verified trace records all four initialized guards
inside outpost_27. One survivor is rescued and one killed; the task remains
pending after rescue, then succeeds with two manpower and exactly 100 funds.
Inventory recovery, delayed cleanup and reward stability pass. Frozen evidence
is native-extraction-bounds-dev1. The untraced public request run Mixed2 and
combined shared-spawner suite ExtractionBoundsFull are still running; this is
not yet acceptance of the complete regression or release gate.

Untraced public Mixed2 is rejected: selection chose outpost_9 and returned
no_safe_shelter before guard creation or task registration. Only three checks
ran; baseline 19 campaign checks pass with zero matched errors. This distinct
selection/scene failure is preserved in native-extraction-mixed-dev2-rejected.
The boundary fix at original outpost_27 remains verified; broader combined
regression is still running. Investigate availability selection rather than
silently retrying random locations and declaring the public case fixed.
