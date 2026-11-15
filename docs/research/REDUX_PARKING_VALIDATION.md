# Full campaign validation of independent Redux parking corrections

15 November 2026. The independent A3U-Redux-Fixes candidate swaps the axes and
turns six known parking rectangles by 90 degrees without changing their ground
footprints. The owner authorized best judgment for reconnecting the orphaned
reso_13_vehicle_1 to existing resource_10. Source geometry guards preserve custom
missions; the repair runs before native marker association and is idempotent.

The real Redux campaign writer (PID 21624) and restarted reader (PID 56916)
each pass 13 assertions. Native startup creates exactly one parking slot in each
of the corrected areas at outpost_6 and resources 1, 2, 3, 7 and 10. The orphan
name and nonexistent resource_13 slot are absent. Native save/load also preserves
town/admin extras, dealer, HQ, save identity and the approved 1100-money crate
reimbursement total. Both isolated servers were stopped after completion.

Infection PBO:
`b4b0c17e92a87e16020635ed4ebcd8ad1e28dd2ff78c5866c494ec23dd981085`.
Redux fixes PBO:
`0111067ba349df53024d0ec0ce7baaf35254048b7c90bb166c513e6ded5fcf7d`.
Full RPTs, reports, launch receipts, written synthetic save and companion manifest
are retained under `evidence/sprint-4/redux-companion-parking-*`.

Both unchanged clean-log gates remain **failed**, on five writer and six reader records:
SmartMarker initialization, High Command's undefined leader (two records), and
two missing-object records. The reader additionally logs an unpriced
O_Heli_Light_02_dynamicLoadout_F during background activity at 16:06:45, after the
assertions finished at 16:06:09. This remains unresolved and is retained in the
whole-log report. Population, loot-crate pricing and parking-marker errors are
absent. The prior run had 11 records each; no filter was relaxed. Seven existing
parser/collector tests pass. Infection production code did not change.

The independent repository additionally retains 24 short vehicle terrain probes,
14 native-slot/guard checks and an Altis preservation check. These do not certify
all vehicle classes, driving, connected clients, JIP, long-session performance or
release readiness. Computer Use was not used and the manual install was untouched.
