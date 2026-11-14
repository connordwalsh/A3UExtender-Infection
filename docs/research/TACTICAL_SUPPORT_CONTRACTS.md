# Tactical support follow-up audit

Baseline: Ultimate 12.4.2 at
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. The
[source manifest](../../evidence/sprint-3/support-sources-12.4.2.json) pins this
inspection. A foot-support prototype is now implemented on the tactical-support
feature branch; engine validation is in progress. This is not the complete Gate 3
route matrix or campaign acceptance.

## Selection and direct entry points

`initSupports` initializes shared support state, builds separate Occupant and
Invader registries, and builds target-location metadata. An infected policy must
retain that initialization and the native Invader registry. Only entries with
an empty asset array are removed by the native prerequisite check; types with an
empty prerequisite key can remain selectable despite empty vehicle pools.

`requestSupport` serializes selection, updates HQ knowledge, cleans historical
spend/strike records, accounts for target threat and recent damage, and applies
native weighting. Air targets have zero TROOPS weight. It releases the shared
call lock before calling `createSupport`, which independently acquires and
releases the same lock. A refusal must preserve that lock ownership; an adapter
must not clear another request's lock or strand it after failure.

The intended infected registry is a foot replacement for `QRFLAND`. Conventional
types need explicit exclusion at direct creation as well as automatic selection:
`AIRSTRIKE`, `ASF`, `CAS`, `TANK`, `CASDIVE`, `QRFAIR`, `QRFVEHAIRDROP`,
`QRFORBITAL`, `CARPETBOMBS`, `GUNSHIP`, `SAM`, `CRUISEMISSILE`, `ORBITALSTRIKE`,
`UAVAttack`, `ARTILLERY`, `MORTAR` and `HOWITZER`. `requestArtillery` selects only
AREA entries; an empty infected AREA selection must terminate without spending
or creating anything. This does not by itself guard direct strategic factories.

`rebuildAssets` bypasses `createSupport`: it directly spawns `SUP_QRFLand` or
`SUP_QRFAir`, with an attack-pool allowance and no caller prepayment. The side is
selected from the nearest enemy marker, so infected Occupants can reach both
branches. These direct constructors need an explicit foot-response route or
refusal; filtering the support registry alone cannot protect them.

Two mission callers retain an older five-argument `createSupport` form:
`RES_Deserters` and `RES_Refugees`. The current worker expects eight arguments
with the support type first and side second. The deserter condition also compares
the same troop count with half itself, rather than counting casualties. These
are mission-audit defects, not a reason to infer an undocumented old signature
or silently change ordinary Invader behavior in the support adapter.

## Payment and lifecycle

Normal `createSupport` prepays the estimate returned by a constructor. The later
`SUP_QRFRoutine` invokes a force factory and refunds estimate minus actual cost.
The direct rebuilding constructor calls do not include that prepayment step.
An infected implementation must own payment consistently for both entry forms,
using actual created actors and the supplied attack or defence pool. Passing
paid Infection actors through the native estimate/refund routine would produce
incorrect balances. Spend/strike telemetry still matters to native threat and
frequency limits even when payment is moved into actor creation.

Native QRFs last up to 1800 seconds, retreat at or below 25 percent fighting
strength, and begin a 600-second search window after reaching within 300 metres
of the estimated target. After that window they leave if no known enemy is
within 500 metres. These differ from `singleAttack`'s capture response: its
deadline is 2700 seconds and its retreat comparison is strictly below 25 percent.
A no-force QRF must still finish explicitly, including when all births are
refused by capacity or safe placement.

The native routine finds a persistent marker within 500 metres of the target,
requests `zoneCheck`, then sends surviving cargo groups through the native
return-to-base/garrison controller. An infected implementation needs arrival
guards and one owner for capture, optional garrison handoff and cleanup. Paid
attack-pool actors require a deliberate extension of the current defence-only
handoff contract. Tactical support must not inherit the capture adapter's rule
that every target is an enemy-owned marker: many calls defend an owned site or
search an arbitrary ground position.

## Required checks for the next increment

Exercise normal selection, direct creation and both rebuilding constructors;
ordinary and inactive-faction delegation; both resource pools; no source,
invalid targets, water/air targets and exhausted funds; delayed and partial
births; source loss, target loss, cancellation and stopped-controller recovery;
arrival/search expiry and the non-strict retreat threshold; exact refunds,
support telemetry, duplicate suppression and empty final controller state.
Keep actual native selection/lock behavior in the fixture where possible.
Redux travel, connected-player observation, full rebuilding missions and warning
wording remain separate campaign acceptance scenarios.

## Prototype implementation

The adapter keeps native initialization, target weighting, threat budgets and
shared call-lock selection. Infection's registry contains only QRFLAND; direct
conventional createSupport requests return no support. The two direct rebuilding
constructors both dispatch to the same foot worker. Ordinary factions and missing
dependency cases delegate to installed originals.

Each job selects a safe land source within 2 km, claims its native one-minute
idle period, and plans basic infected at 10 resources each. Planning respects
the caller's exact allowance, three native vehicle allowances, current funds
and a 64-actor ceiling. Actual births debit the selected pool; estimates populate
native spend/strike history without prepayment. Four-actor batches share the
non-town budget and stage at 15-second intervals for at most 600 seconds.

The worker uses native QRF search/retreat thresholds and an 1800-second lifetime
after its requested delay. Arrival and outstanding defenders guard native capture
requests. A final 60-second handoff window admits only arrived, paid groups into
eligible persistent garrisons. The shared adoption contract now accepts uniformly
paid attack or defence groups; mixed pools are refused. Cleanup owns only actors
still in the response context, waits for observers and refunds healthy births
once. Stopped workers use the same recovery path.

The dedicated fixture exercises real native initialization, support selection,
budget calculation and artillery exclusion. Ordinary constructor endpoints are
recorded, navigation is synthetic, and arrival/deadline changes are injected.
Focused and combined validation results will be recorded after completed runs.
