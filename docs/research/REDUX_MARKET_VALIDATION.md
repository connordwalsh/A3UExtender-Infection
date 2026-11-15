# Valid black-market quote and background campaign regression

15 November 2026. The independent Redux fixes addon now resolves a valid
black-market-only vehicle quote before native vehiclePrice can incorrectly log
its missing HQ entry. Native blackMarketVehiclePrice still supplies the value
and discounts. Infection production code is unchanged.

The full native writer (PID 47868) and restarted reader (PID 54388) each pass
16 assertions. Both confirm that O_Heli_Light_02_dynamicLoadout_F lacks an HQ
entry, that its native black-market quote is 28800, and that vehiclePrice returns
the same amount. Parking slots, orphan correction, loot-crate reimbursement,
town/admin extras, dealer, HQ and save identity remain correct.

Each phase waits at least 75 seconds after its save/load assertions before
completion. Bazaar vendors and the native despawn queue run during that window.
No population, parking, crate-price or helicopter-price errors are recorded.
Both overall clean-log reports remain **failed** on the same five records:
SmartMarker startup, High Command's undefined leader (two records), and two
missing-object records. No error filter was relaxed. Both servers were stopped
after completion and full-log collection.

Infection PBO:
`b4b0c17e92a87e16020635ed4ebcd8ad1e28dd2ff78c5866c494ec23dd981085`.
Redux fixes PBO:
`416087574ccc11570d26ffb53e4590901db2677af957574409284bb4d8a9faff`.
Raw logs, reports, launch receipts, written synthetic save and companion manifest
are retained under `evidence/sprint-4/redux-companion-market-*`. Seven existing
collector/parser tests pass. The separate fix repository retains 15 focused
price checks, Altis delegation, and negative controls requiring the native
diagnostics/fallback for invalid prices.

The 75-second window is a targeted regression, not long-session performance or
client/JIP acceptance. No Computer Use or manual-install changes occurred.
