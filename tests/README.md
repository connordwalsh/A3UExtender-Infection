# Development checks

These tools are development fixtures and are not part of the playable Infection
release. Current evidence and limitations are in
[Sprint 0](../docs/research/SPRINT_0.md).

## Local unmodified campaign

Run `Tools/dev/start-local-test.ps1` with `-SteamLibrary` and
`-IncludeChernarusRedux`. The optional `-InfectionMod` is omitted for baseline
tests. It creates a separate profile under `.work/profiles/client` and starts the
visible client for manual testing. Use LAN hosting and create a new campaign.

For the dedicated control, run `Tools/dev/start-baseline-server.ps1` with
`-SteamLibrary`. It loads the six-mod acceptance stack and unmodified Redux
mission, with a separate `InfectionBaseline` profile and loopback port 2502.
Connect the baseline client to that local server and create a fresh campaign.
Mission initialization alone does not establish a completed campaign test.

## Prepared-class probe

Build with `Tools/dev/build-probe.ps1 -ArmaTools <installed Arma 3 Tools path>`.
The script validates the mission configuration with CfgConvert, then uses
FileBank to pack `tests/arma/infection_probe/catalog.VR` as a standalone mission.
Each build has fresh staging so stale output cannot count as a successful build.
The PBO is written to `.work/probe-missions/Infection_ClassProbe.VR.pbo`.

Run `Tools/dev/start-probe-server.ps1 -SteamLibrary <library>` to create an
isolated dedicated process bound to 127.0.0.1 on port 2402. It uses the four-mod
minimum stack, a VR test world, and its own profile. The script installs only
the uniquely named probe PBO under `Arma 3/MPMissions`. A hash receipt protects unrelated or
externally modified files from replacement. It never loads or writes an
Antistasi campaign save.

The mission logs only tagged diagnostic records under `[INFECTION_PROBE]`:

* Runtime version, world, dedicated flag, and process owner ID (not player ID).
* Relevant scalar/Boolean/string WebKnight globals after initial settings load.
* Candidate class existence, side, inheritance, model, movement skeleton, and
  contributing addons.
* One candidate at a time: actual type/side/locality, initialization marker,
  alive state, equipment, animation, and stored per-frame-handler count.
* Entity classes remaining three seconds after deletion, and final failures.

The presence of `WBK_AI_ISZombie` is checked without assuming its value is a
Boolean. The probe uses the prepared unit's own init handlers; it does not force
the marker or directly invoke an unverified AI API.

A completed smoke probe establishes only the recorded spawn/init facts. It does
not test melee damage, civilian targeting, AI waypoint compliance, capture,
save/load, JIP, headless transfer, or the absence of delayed cleanup leaks. Those
remain separate acceptance scenarios. Investigate every script error in the
full private RPT, even if the final smoke-failure list is empty.

The server stays running after the probe for inspection. Stop only the owned
probe process after collecting evidence; never terminate another Arma session.

The working fixture uses Arma's documented version-12 mission format. The earlier
incomplete hand-authored Eden fixture caused a repeated mission-load loop; it is
not used for the current evidence.

Collect a completed RPT with `python Tools/dev/collect-probe.py <log> <output.json>`.
The collector requires one start, one completion, and one config/spawn/deletion
record per candidate. Missing completion, duplicate/missing records, failed
checks, or engine errors produce a nonzero exit. `needs_review` distinguishes
passing smoke assertions accompanied by engine model/animation errors. Raw
logs and incomplete reports stay under `.work/`; only sanitized reports belong
in `evidence/`. This collector does not certify the behavior outside its scope.

References: Bohemia's [startup parameters](https://community.bistudio.com/wiki/Arma_3:_Startup_Parameters),
[server configuration](https://community.bistudio.com/wiki/Arma_3:_Server_Config_File),
and the installed Addon Builder `-help` output.
# Controlled encounters

Build with `Tools/dev/build-probe.ps1 -ArmaTools <tools> -Mode Behavior`, then
start with `Tools/dev/start-probe-server.ps1 -SteamLibrary <library> -Mode Behavior`.
This uses a separate localhost server on port 2602 and the `InfectionBehavior`
profile. The build copies the verified candidate list from the catalog fixture.
The eight scenarios cover a movement waypoint, passive INDEP/EAST/CIV targets,
a CIV-class survivor joined to INDEP, empty/occupied offroads, and an armed INDEP
rifle opponent. CIV relations and WebKnight settings remain at their defaults;
WEST/INDEP and WEST/EAST are explicitly hostile. The rifle opponent receives
target/fire orders; other targets cannot fire or navigate away.

The server runs one encounter at a time, samples state each second, and deletes
its test actors between trials. Counts include corpses and vehicle crews. A
24-entity guard or leftover objects/groups aborts the batch to prevent one trial
from contaminating another. These are short observations, not campaign acceptance.
Joining clients get an observation camera; visual inspection remains a separate
manual test. `collect-behavior.py <rpt> <json>` rejects incomplete/aborted batches
and always marks the observations as requiring review.

`start-local-test.ps1 -ConnectLocalPort 2502` connects the isolated visible client
to the dedicated baseline; use port 2602 for the encounter observer. The option
uses Arma's documented `-connect`/`-port` startup parameters and only accepts a
localhost destination.

Fixture correction: the initial encounter batch stopped after its first combat
trial because its entity query excluded dead units. The corpse retained a group.
The corrected query includes dead entities, and occupied crew are removed through
`deleteVehicleCrew` before deleting the vehicle. The catalog cleanup query was
strengthened at the same time; its original report only counted living leftovers.
References: [entities](https://community.bistudio.com/wiki/entities),
[deleteVehicle](https://community.bistudio.com/wiki/deleteVehicle),
[startup parameters](https://community.bistudio.com/wiki/Arma_3:_Startup_Parameters).

# Infection registration checks

Build the addon with `Tools/dev/build-infection.ps1 -ArmaTools <tools>`.
Build and launch a probe with the existing scripts' `-Mode Template` or
`-Mode Dependencies` option. Template uses port 2702 and the full required stack;
Dependencies uses port 2802 and deliberately omits WebKnight/IMS. Both load the
development addon, use isolated profiles and never start an Antistasi campaign.

The template probe exercises Ultimate's actual faction loader, group compiler,
version validator and unit creator. It checks all 67 roles, equipment/side/init,
asset resolution, activation guards and post-deletion cleanup. The dependency
probe checks the missing-patch case without attempting to spawn missing classes.
Collect with `collect-template.py <rpt> <json> --dependencies present|absent`.
The collector requires all expected checks exactly once and preserves startup
warnings separately. These checks do not establish safe campaign vehicle routing.

The full template fixture also checks the infected garrison-line override using
all upstream preferences, fixed/weighted tiers, ordinary side delegation and
Ultimate's initial-roster/ratio functions. The current suite also exercises combat
initialization, damage observation, real rifle impacts, resource/garrison death
and deletion accounting, atomic spawn reservations, setting changes and cleanup.
A passing current full run requires 534 checks; the
dependency-absent run has 11. The installed Ultimate header must report 12.4.2.
The full fixture uses a separate test-only addon that records task/support/
aggression and original-init dispatch endpoints, and wraps the real vehicle
selector to count calls. It is never packaged in the gameplay mod or loaded by
the ordinary client launcher. Read `docs/research/COMBAT.md` for the boundary
between real engine work and recorded campaign requests.
Use `build-infection.ps1 -BuildName <unique-name>` and
`start-probe-server.ps1 -InfectionMod <that-build-directory>` to test a new build
without overwriting one used by an open client. The builder rejects a directory
referenced by a running Arma client/server.

The template fixture builder likewise rejects its test addon while it is in use.
The collector rejects missing/duplicate checks, malformed records, script/engine
errors and rejected attempts to override protected A3A/A3I functions. Run the
parser regression with `python -m unittest discover -s tests -p test_evidence_parser.py`.

Budget checks use the real CBA server-setting API with persistence disabled and
restore the prior values. They test twenty competing requests, shared-context
ceilings, real prepared-unit bindings and Killed/Deleted release, cancellation,
and a 31-second lease-expiry wait. A preflight read validates remaining capacity
immediately before creation. See `docs/research/SPAWN_BUDGET.md`.

The placement and six-site modules exercise real geometry, basic infected,
flags/crates, budgeted batches, native roster changes, duplicate requests,
simulation states, cleanup/reentry and interrupted-controller recovery. The
test addon records arsenal filling, logistics, resource-worker behavior and
original-route dispatch. A remote recovery-call check protects an unrelated
recurring handler. This is not a live campaign, UI, client-camera, terrain or
performance acceptance test. See `docs/research/SITE_SPAWNING.md` and
`evidence/sprint-2/` for the tested build and exact boundary.

The control module adds 37 checks for road/field role selection, actual off-road
controller routing, queued arrivals, legacy costs, capture eligibility, ownership
races, interrupted cleanup and the generated-control calendar reset. VR supplies
no real roads, so road roster branches use explicit classification inputs. The
fixture does not certify Redux road geometry, broad roaming or client notifications.
See `docs/research/ROAD_CONTROLS.md` and `evidence/sprint-2/control-contract.json`.

For focused population and town-lifecycle checks, build the Template fixture with
`-Suite Towns` and collect its log with `--dependencies present --suite towns`.
The 78 checks include all 49 terrain population inputs, a simultaneous 200-actor
town and 21-actor neighbor, independent town allowances, geometry, simulation,
cleanup, ownership handoffs and the installed political ownership transaction.
They do not certify Redux navigation, connected-player observation or representative
performance. See `evidence/sprint-2/town-infestation-ownership-focused.json`.

For tactical support, build with `-Suite Tactical` and collect with `--suite tactical`.
All 81 focused checks pass, including the real native selector/lock, direct QRF
constructors, both resource pools, rebuilding policy, remote execution context,
search/retreat thresholds, garrison handoff and stopped-controller recovery.
The final 534-check full report is `evidence/sprint-3/tactical-contract.json`.
The relay's connected-player positive path, full rebuilding mission and Redux
travel remain unverified; synthetic navigation and injected arrivals are explicit.
