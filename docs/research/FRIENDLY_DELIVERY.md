# Friendly delivery destinations

Status: location helper passes all 36 focused runtime checks (25 specific cases
and 11 common checks).
Packaging, three parser tests and eleven actual missing-dependency checks pass
without engine/SQF errors. This does
not implement Supplies Seizure or Extraction and is not wired into public requests.

The owner approved a shared destination policy: Rebel HQ, plus Rebel-held bases,
outposts, airfields, factories, resource sites and seaports. Towns, controls and
permanently cleared administration strongholds are excluded. HQ preserves native
distances: trucks within 100 metres of posHQ; survivors within 50 metres of the
respawnTeamPlayer marker. Permanent sites use their actual marker boundary.

deliveryDestination is an internal server-local read-only predicate. It returns
the qualifying marker or an empty string, rechecking current ownership and valid
area geometry on each call. Inactive sites can qualify; a spawner or active guard
is not required. Missing HQ data does not invalidate other qualifying sites.
Null/dead subjects, unknown delivery categories and invalid marker geometry fail.
Mission owners must still validate the exact mission-owned truck or survivor,
handle arrival/death/deletion timing, retain delivered trucks, and settle rewards
once. This helper does not award resources, transfer ownership or delete assets.

The owner corrected Extraction settlement: reaching safety with the first
survivor does not finish the task. Every survivor must be resolved as rescued or
killed before early settlement; otherwise it stays active until the deadline.
At settlement, one or more rescues means success and zero means failure. The
eventual controller needs a per-survivor ledger and must distinguish native
deletion from actual rescue or death; this location helper alone is insufficient.

The native reference is pinned Ultimate 12.4.2 commit
c7c8247672ed5e7d4aa317d47efb371c41de4e7d:
`core/functions/Missions/fn_LOG_Ammo.sqf` uses a 100-metre posHQ test, while
`core/functions/Missions/fn_RES_Refugees.sqf` uses a 50-metre HQ-marker arrival
test. Their original mission outcomes are not adopted here: destroying a truck
cannot substitute for the requested Supplies Seizure delivery.

The 25 specific fixture cases cover both HQ radii, all six permanent site lists,
actual ownership changes, enemy sites, exclusions, ellipse and rotated rectangle
geometry, invalid marker shapes/sizes, missing HQ, living-subject requirements,
absence of mutation and entity/group cleanup. With common loader/activation checks,
the focused suite expects 36 checks. These are controlled VR geometry and object
checks, not transport missions, live map travel or multiplayer delivery acceptance.

Frozen artifact: @Infection_Delivery_Dev1, 178 production inputs, SHA-256
52b4f1bc57351c236cb27045dd2430b4c88986cc8e40b4fb3f4f141da839026c.
All 178 inputs and the PBO match after focused runtime testing. Reports are
delivery-build.json, delivery-dependencies.json and delivery-engine.json under
evidence/sprint-4. Both completed servers exited. Sixteen startup/dependency
notices were reviewed; no engine/SQF errors occurred. Self-review covered
current ownership, actual marker geometry, HQ references, invalid inputs and
absence of mutation. The parent candidate separately passed 1089 combined checks
and 67 role spawns in PR 35. The read-only helper has no public caller yet;
that result is not claimed as a combined run of this 178-input candidate.
