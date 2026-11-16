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

Runtime result is pending. This is not player combat, natural weapon damage,
corpse cleanup, capture, save/reload of these casualties, multiplayer or
performance evidence. Corpses remain under Ultimate's native postmortem policy.

## Rejected Dev1

All 18 behavioral assertions completed, but eight error records reject the run.
The fixture read the lazily initialized A3I_sites registry before first native
dispatch. The corrected wait reads it with an empty-map fallback, as the prior
site-lifecycle fixture already does. Production code is unchanged. Exact helper,
receipt, raw log and failed report are preserved under
`evidence/sprint-6/native-campaign-casualties-dev1-rejected`.
