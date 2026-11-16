# Redux HQ inventory validation

15 November 2026 local time (16 November UTC). Independent Redux Fixes now
defers the official mission's original HQ empty-inventory attribute until
simulation starts. It uses native explicit empty cargo, rather than retaining
supplies or suppressing errors. The narrowly guarded handler delegates other
missions, worlds, clients, runtime calls, getters and custom inventory to native.

The normal campaign helper runs without either startup trace or the inventory
retention control. Both new-campaign write and fresh-process reload pass all
19 checks, including separate 75-second background windows. Complete-log reports
contain zero records matching the existing case-insensitive error rules. No
error filter was relaxed. This does not certify every warning or asset defect.

Before JNA initialization, the new check confirms the deferred worker completed,
all four physical cargo categories are empty, and no containers remain. Thus
the result cannot be attributed to JNA clearing the crate later. Native campaign
startup, all six repaired parking slots, orphan reconnection, Curator's full
2874-addon set, dealer unlock, save identity, HQ, persistent town/admin extras,
and exact 1100 saved funds pass their existing assertions.

Infection PBO is unchanged:
`B4B0C17E92A87E16020635ED4EBCD8AD1E28DD2FF78C5866C494EC23DD981085`.
Redux Fixes PBO:
`CCFAEEB0245C8916327AAA179A7A111EC86080F1649EA1FB57D9E58F4374586E`.
Raw logs, reports, launch receipts, fix build manifest and the synthetic saved
profile are under `evidence/sprint-4/redux-companion-crate-*`.

The companion's six focused checks pass on Redux and Altis. Altis retains its
one expected native SmartMarker diagnostic, explicitly checked rather than
discarded. Its 34 evidence tests and Infection's eight campaign/parser tests
pass. The trace/control evidence remains separate in CRATE_STARTUP_TRACE.md.

Both full-campaign processes were stopped after verified identity checks.
No Computer Use, manual-install changes, connected clients, JIP, combat, or
long-session acceptance occurred. The bounded dedicated-server startup/save/
reload error check is now passing; player-facing and release gates remain open.
