# Native campaign casualty and queue probe

`Tools/dev/start-campaign-probe.ps1 -SiteCasualties` runs a separate opt-in
probe after normal campaign startup/save checks. It cannot be combined with
site-lifecycle or startup tracing modes. Production source and limits remain
unchanged. A fresh isolated profile protects manual campaigns.

The fixture selects the smallest eligible infected permanent garrison with at
least four queued defenders beyond the configured context limit. It activates
through native `forcedSpawn` and distance scheduling. Four living units receive
engine `setDamage 1`; actual Killed handlers update the native garrison and
budget. The fixture does not call those handlers directly or replace endpoints.

Eighteen checks require dispatch, distinct controllers, complete living/queued
accounting, four finalized deaths, the exact reduced roster, four new initialized
replacements, preserved ownership/accounting, living-unit cleanup, budget release
and the reduced roster on a second visit. The collector rejects missing or
duplicate checks, incomplete runs and engine/native errors across the whole log.
Five collector regression tests pass; the launcher passes PowerShell parsing.

Dev2 passes all 18 casualty checks and 19 campaign checks with zero matched
engine/native errors. This is not player combat, natural weapon damage,
corpse cleanup, capture, save/reload of these casualties, multiplayer or
performance evidence. Corpses remain under Ultimate's native postmortem policy.

## Rejected Dev1

All 18 behavioral assertions completed, but eight error records reject the run.
The fixture read the lazily initialized A3I_sites registry before first native
dispatch. The corrected wait reads it with an empty-map fallback, as the prior
site-lifecycle fixture already does. Production code is unchanged. Exact helper,
receipt, raw log and failed report are preserved under
`evidence/sprint-6/native-campaign-casualties-dev1-rejected`.

## Dev2 result

The corrected 16 November run selects factory_1: 12 active infected and four
queued from its native 16-defender garrison. Four engine deaths finalize and
remove the exact four role entries from the native roster. Four different,
initialized WEST infected replace them, leaving 12 living and zero queued.
After native distance cleanup, the second controller activates the reduced
12-defender roster. Both visits release their spawn budget and preserve the
reduced stored roster.

Evidence is in `evidence/sprint-6/native-campaign-casualties-dev2`, with exact
helper, receipt, raw RPT, both build manifests and both reports. All 324 production
source hashes and helper inputs match their receipts. Production PBOs remain
B4B0C17E92A87E16020635ED4EBCD8AD1E28DD2FF78C5866C494EC23DD981085 (Infection)
and CCFAEEB0245C8916327AAA179A7A111EC86080F1649EA1FB57D9E58F4374586E (Redux Fixes).
Sixteen campaign/site/casualty collector regression tests pass. The exact server
was stopped and its exit confirmed. No Computer Use or manual profile changes.
