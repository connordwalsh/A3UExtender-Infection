# HQ crate startup diagnostics

The two remaining missing-object records are associated with the HQ crate's
backpacks being removed by the mission's Eden inventory attribute. This is a
diagnosis, not a production fix or campaign acceptance result.

Both runs use the official Redux mission, frozen Infection PBO
`B4B0C17E92A87E16020635ED4EBCD8AD1E28DD2FF78C5866C494EC23DD981085`,
and independent Redux fixes PBO
`9A9FB05FDE9935EB09E12D2E235EA43DEA753F704EFE2412C9D9B33C9D456836`.
They observe mission initialization without starting or saving a new campaign.
The helper changes the initializer's call context, so uninstrumented campaign
verification remains necessary for any eventual fix.

## Native-call observation

`evidence/sprint-4/crate-trace-dev1` records the installed
`BIS_fnc_initAmmoBox` through a wrapper that delegates the original arguments
and preserves its return. The native source is loaded from the installed game,
not redistributed. At time zero, HQ crate `IG_supplyCrate_F` has ID `2:8`.
Its two `B_TacticalPack_blk` containers have IDs `2:9` and `2:10`; eight vest
containers have IDs `2:11` through `2:18`. Immediately after the initializer,
the container array is empty. The two missing-object records then name exactly
`2:9` and `2:10`. The observation completes.

## Inventory-retention control

`evidence/sprint-4/crate-keep-dev1` uses the explicit test-only
`-TraceCrate -CrateKeepInventory` mode. It bypasses only the empty-string call
for `IG_supplyCrate_F`; other initializer calls delegate normally. The same
crate and backpack IDs are recorded, the bypass marker appears once, and neither
missing-object record appears. Observation and native background initialization
complete. The control leaves crate contents intact and is **not a candidate
production solution**.

The launcher rejects combining the two tracing modes or using inventory
retention without crate tracing. Normal campaign probes select the original
helper configuration and do not load these diagnostic overrides. Receipts
record mode flags, helper input hashes, packed helper hash, and production hashes.
Dev1 of the native trace predates the retention flag; its archived fixture
preserves that earlier wrapper exactly.

## Remaining work

Develop a narrowly scoped correction that still leaves the intended HQ cargo
empty. Validate positive and failure/edge cases, then repeat the uninstrumented
native campaign startup, save, restart, and reload checks. Connected-player,
JIP, and manual playthrough evidence are still outstanding. No Computer Use
was used in this investigation.
