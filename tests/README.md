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
