# Native Redux SmartMarker guard validation

15 November 2026. The independent A3U-Redux-Fixes addon guards the unsupported
Old Man `["preInit"]` marker call only on Redux. It retains native handling of
real marker requests and other maps, and keeps function logging enabled.
Infection production code and the manual installation are unchanged.

The full native campaign writer passed all 16 assertions, including exact crate
valuation, six parking slots, the native helicopter quote, saved town/admin
reinforcements and a 75-second background window. The SmartMarker startup
message is absent. The overall clean-log report remains failed.

The read-only module snapshot records zero players, no commanderX object, and
an existing High Command scope synchronized only to HighCommandSubordinate.
This matches the isolated native empty-leader reproduction in Redux Fixes.
No artificial commander was added to make this campaign pass.

## Reporting correction

The campaign collector previously recognized `Error:` but missed uppercase
`ERROR:`. Its error matching is now case-insensitive and regression-tested.
The earlier market writer's preserved log contains six matching records under
the corrected rule, rather than the five reported by its original collector.
Old evidence is preserved unchanged; it already failed the clean-log gate.

The new writer records five errors: two High Command expression records, two
missing-object records and `BIS_fnc_activateAddons` reporting an invocation
outside mission initialization. The marker fix removes one error; the parser
correction exposes one previously missed error. These are distinct changes.

Tested Infection PBO:
`b4b0c17e92a87e16020635ed4ebcd8ad1e28dd2ff78c5866c494ec23dd981085`.
Redux Fixes PBO:
`fcaeae763453a67cb3c18a3980f2d01dbc02f5fb82a46edc66163451fb527034`.
Full logs, launch receipts, reports, synthetic saved profile and companion build
manifest are retained as `evidence/sprint-4/redux-companion-smart-*`.

The fresh-process reader also passes all 16 assertions and its 75-second window,
restoring town/admin extras, dealer, HQ, save identity and 1100 funds. It records
the same five remaining errors and no SmartMarker error. Both servers were
stopped after identity verification. Eight collector/parser tests pass.

Connected-player, UI, JIP, combat and long-session acceptance remain open.
No Computer Use was performed, and no sprint or release gate is closed.
