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
and the wrong phase. Launcher parsing passes. Runtime evidence is pending.
This does not establish player combat, capture, multiplayer or performance.
