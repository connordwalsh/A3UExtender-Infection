# Native casualty save and restart probe

Use `start-campaign-probe.ps1 -CasualtySave -Phase Write` with a fresh isolated
instance, collect and stop that exact server, then use the same instance with
`-CasualtySave -Phase Read`. This mode excludes other diagnostics.

Write runs the existing 18-check casualty/replacement/revisit probe, then invokes
Ultimate's native saveLoop again. Six additional checks require a valid casualty
result, completed save, unchanged campaign identity, the exact reduced garrison
in native save data, exact live funds and a test receipt. The earlier temporary
crate has been deleted, so the main test receipt now expects the later save's
actual funds rather than the earlier crate reimbursement. No funds are changed.

Read uses the normal native campaign loader and ten additional checks. It
compares the loaded roster and ownership to the receipt, activates the saved
site through native distance scheduling, requires only the reduced roster to
spawn, then checks cleanup, budget release and unchanged roster. The receipt is
never used to write or restore garrison data.

Seven collector tests reject missing/duplicate/incomplete/error-bearing evidence
and the wrong phase. Launcher parsing passes. The completed Dev1 passes all six write and ten read assertions.
This does not establish player combat, capture, multiplayer or performance.


## Dev1 result (16 November 2026)

The writer repeats all 18 casualty/replacement/revisit checks at factory_1, then
passes six save assertions. Native save data contains the exact reduced roster
of 12 from the original 16, retaining the actual 1000 funds after removal of the
earlier temporary price-test crate. The process exits before the reader starts.

The fresh reader passes all ten persistence assertions: native load restores the
same campaign, ownership and reduced roster, and native distance scheduling
spawns exactly 12 valid infected. Cleanup releases the budget without changing
the saved roster. Both phases also pass 19 campaign checks, including the
75-second background window, with zero matched engine/native errors.

Exact fixtures, launch receipts, raw logs, reports, build manifests and synthetic
writer save files are in `evidence/sprint-6/native-campaign-casualty-save-dev1`.
Both helper receipts and all 324 production source inputs match. The production
PBOs remain unchanged from the prior native casualty test. Twenty-three relevant
collector regression tests pass. Both isolated processes have exited; no Computer
Use, manual campaign changes or other faction work occurred. This establishes
persistence for this sampled factory garrison, not every location or war tier.
