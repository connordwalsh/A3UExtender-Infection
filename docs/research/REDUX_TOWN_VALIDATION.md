# Chernogorsk population validation

## Scope

Dedicated `ReduxTowns` fixture uses native Redux city data/initialization and the
real scheduler, town creator and infected patrol controller. Chernogorsk has a
native population of 1,176 and the approved logistic curve requests 200 infected.
Two visits check full activation, living managed WEST units, dry in-boundary
recorded spawn positions, observed movement, entity/group cleanup and a clean
revisit. Current positions outside the marker are diagnostic: earlier batches
can already walk while later batches spawn. This is not a confinement contract.

The fixture runs only on chernarusredux, independently of the VR full suite.
It does not change production. Dev1 packages the 262-input master source at
078b6c0; all source and PBO hashes were verified. The manifest is preserved as
`evidence/sprint-6/redux-towns-build-dev1.json`.

## Rejected attempts

The first report is rejected. Its movement measurement incorrectly used
_forEachIndex inside apply. Its current-location boundary check also conflated
spawn placement with later walking. The corrected fixture uses a forEach index
and validates the recorded spawn position, retaining outside current positions
as diagnostics. Subsequent observation records show valid inside spawn locations
followed by outside current locations. Production did not change.

The second report is rejected despite all 26 in-game checks passing: movement
arrays exceeded Arma's log-line limit, so two records were truncated. The final
fixture logs the moved count, maximum displacement and group route counts,
with outside-position diagnostics bounded to three units.

## Acceptance limits

A passing result establishes the isolated two-visit contract only. It does not
establish player visibility, full street navigation, combat, HC/JIP, save/load,
whole-map density, representative frame rate or a 90-minute soak. Another test
server runs concurrently, so frame-rate samples are diagnostic only. Manual
Dev9 remains untouched; no Computer Use was used.

## Accepted result

`redux-towns-dev1.json` passes all 26 checks with no engine/SQF errors. The two
visits activated 200 living infected in 25.851 and 24.332 seconds. During the
20-second observations, 190 and 186 units respectively moved over one metre;
all 17 groups had four recorded patrol points. Both visits retired their
entities, groups and budget records. This does not show every unit completing
a route or remaining within the town after spawning.

The 16 retained startup notices match the existing dependency baseline: one
character-addon warning, one animation configuration warning, eight missing
animation notices and six final-function overrides. The successful run does not
resolve those dependency notices. Three evidence-parser tests and whitespace
checks pass. The completed server was stopped by exact identity. The production
manifest/PBO match was rechecked after collection.
