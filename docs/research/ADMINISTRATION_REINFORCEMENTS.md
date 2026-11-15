# Persistent administration reinforcements

Status: 38 focused engine checks pass; combined regression rejected pending a
corrected integrated rerun. Normal
stronghold defenders still regenerate each visit. The owner approved persistent
extra survivors, permanent extra casualties, and a 50-metre stronghold arrival
boundary for Horde Interception.

## Native source findings

Pinned Ultimate 12.4.2 creates administration markers as ICONs in initZones and
explicitly leaves them out of markersX. saveLoop saves ordinary garrisons from
markersX, so adding roles to an administration namespace alone would not survive
a campaign save. The documented SERVER_GAME_SAVE/LOAD plugin events provide the
extension data map; loadServer emits the load event before the main save fields.
Native removeMilAdmin changes ownership and the completed-building registry but
does not clear a custom extra roster.

## Implementation

The renamed private siteExtraRoster helper selects Infection additions at both
towns and administrations. Administrations spawn their baseline and saved-extra
queues separately. Baseline deaths regenerate next visit; extra deaths use
native garrison accounting. Capture waits for both queues, both death ledgers,
and the native extra casualty updates, including after building destruction.

Live arrivals use their existing dedicated allowance and transfer both clearance
and administration defender obligations. Active live-deleted extras are replaced
as extras without erasing their saved role; native bookkeeping checks the exact
administration visit, independent of event-handler order. Cleanup of an inactive
or obsolete visit keeps the normal native deletion rules.

Interception endpoint selection now accepts actual registered administration
icons. The same 50-metre boundary drives route selection, preparation, first-entry
observation, death-event timing and both offscreen/live handoffs. Ordinary area
markers retain their original boundaries. Completed or unregistered strongholds
are not eligible endpoints.

registerPersistence attaches once through Ultimate's event wrapper. The tagged
A3I_administrationExtras field stores schema version 1 and marker/role rows.
Loading validates the entire payload before replacement, preserves unrelated
entries, ignores unknown markers and non-infected-owned sites, and is idempotent.
Ordinary campaigns and missing zombie dependencies leave save data untouched.
No native marker list is broadened and no core saveLoop override is introduced.

## Focused evidence

Twenty-seven cases cover actual administration icon routing, native task failure
inside 50 metres, offscreen and live additions, extra casualties, an unfit live
deleted actor's replacement, Ultimate's save/load event round-trip, duplicate
load protection, malformed data, inactive saving, revisit regeneration and
capture after clearing a ruined building. The test uses real actors/buildings
and native capture; fixture positioning injects arrival and does not establish
terrain travel. The save event round-trip is not full disk-save/campaign acceptance.

All 38 focused engine checks (27 administration-specific plus 11 common checks),
11 actual missing-dependency checks, packaging and three parser tests pass.
There are no engine/SQF errors. The focused run has 29 reviewed warnings: 16
startup/dependency notices and 13 object-deletion notices. The completed server
exited. All 167 production inputs and the PBO match the frozen manifest after
execution. Reports are `administration-extras-build.json`,
`administration-extras-engine.json` and `administration-extras-dependencies.json`
under `evidence/sprint-4`.

Artifact: `@Infection_AdminExtras_Dev1`, SHA-256
`7167260d29be448c293108adf49f77d7d7d2c28bdbd79b513e445306ccb6992d`.

The parent handoff component passed 1013 combined checks and merged in PR 32.
That different frozen candidate cannot certify this additional administration
implementation. The 1040-check AdminExtras Dev1 run completed with 1038 passing
checks and all 67 roles passing, but failed two interception task assertions.
It is retained as `administration-extras-combined-rejected.json`, not accepted.
There were no engine/SQF errors. The assertion read the native resource update
before its queued reward completed; the timeout assertion likewise read before
the queued task state/reward finished.

The fixture now waits up to five seconds for the expected native task state and
both resource pools, instead of a fixed 0.2-second sleep. Expected results and
production reward logic are unchanged. All 64 focused task checks then passed,
with no engine/SQF errors and 16 startup/dependency notices, recorded in
`administration-task-settlement-engine.json`. Diagnostic before/after snapshots
show CREATED becoming SUCCEEDED/FAILED and both pools reaching their expected
values. All 167 production inputs still match the frozen manifest.

The next combined gate will include the stacked arrival-owner and public-dispatch
changes after their focused checks pass. This diagnostic does not certify that
integrated candidate or establish full campaign acceptance.
