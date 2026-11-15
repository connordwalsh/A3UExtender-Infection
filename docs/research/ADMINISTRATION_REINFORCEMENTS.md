# Persistent administration reinforcements

Status: implementation drafted; focused engine validation pending. Normal
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

## Planned focused evidence

Twenty-seven cases cover actual administration icon routing, native task failure
inside 50 metres, offscreen and live additions, extra casualties, an unfit live
deleted actor's replacement, Ultimate's save/load event round-trip, duplicate
load protection, malformed data, inactive saving, revisit regeneration and
capture after clearing a ruined building. The test uses real actors/buildings
and native capture; fixture positioning injects arrival and does not establish
terrain travel. The save event round-trip is not full disk-save/campaign acceptance.

Packaging and three parser tests pass. Engine execution is pending the parent
combined regression. The full 1013-check parent run uses a different frozen build
and cannot certify this additional administration implementation. Public mission
dispatch and hostile arrival ownership are still unfinished.
