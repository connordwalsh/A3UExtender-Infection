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
