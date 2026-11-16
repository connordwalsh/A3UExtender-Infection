# Native campaign site lifecycle probe

The current probe extends the normal Redux new-campaign save test with two visits
to each of seven categories: town, resource, factory, outpost, seaport, military
base and airport. It is opt-in through
`Tools/dev/start-campaign-probe.ps1 -SiteLifecycle`; tracing modes are rejected
when this option is used. The production Infection addon is unchanged.

After normal campaign creation, save checks and the background window, it selects
the smallest eligible native roster/population in each category. Targets must
be infected-held, currently despawned, not already forced, and more than 2,500
metres from HQ. Population, ownership, garrisons and spawn limits are not replaced.

Activation adds a target to Ultimate's `forcedSpawn` array. Ultimate's running
distance loop then invokes its scheduler and the registered Infection creator.
The test does not directly call the creator or replace campaign endpoints.
Removing only that target from `forcedSpawn` lets native distance processing
disable and despawn it. No artificial player or commander is introduced.

Each visit checks native dispatch, a distinct controller, full roster accounting
(living actors plus queued defenders), valid initialized WEST infected, retirement
of the tracked units and groups, released spawn-budget records, and unchanged
saved roster. It additionally checks retirement of the tracked flags, crates and
civilian actors. Towns must activate their full population; permanent sites may
retain defenders queued beyond the live configured context/shared limits (12
per context by default; 24 is only the context ceiling). The second
visit repeats the same checks. All 113 expected checks must appear exactly once.
Timeouts and whole-log engine/native errors fail the result.

Factory and resource markers share the Resource controller; seaports and
outposts share Outpost. The probe records the requested category separately from
that expected controller type, preserving native dispatch coverage for each.

The collector is `Tools/dev/collect-campaign-sites.py`. Its regression cases
reject missing and duplicate checks, incomplete runs, and extra error records.
Its default requires all seven categories. Use `--coverage basic` only to
recollect the preserved earlier two-category run; that log fails all-category
validation rather than silently inheriting the larger coverage claim.
Results are archived separately from the normal 19 campaign checks.

This is not a player-proximity test: Ultimate's civilian town spawner uses actual
players and is not activated by this forced-spawn request. It also does not prove
combat, capture, JIP, two-client ownership, vehicle driving, full-map coverage or
representative performance. These remain separate plan gates.

## Earlier two-category Dev1 result

The completed 15 November 2026 local-time run passes all 29 lifecycle checks and
the existing 19 native campaign startup/save checks. Both reports find zero
records under the unchanged engine/native error matcher. Olsha activates all
21 infected on both visits; the native `resource` marker activates all eight
saved defenders on both visits. Each visit retires its tracked units and groups,
releases budget reservations and preserves the saved roster. Each return creates
a new controller. This eight-defender sample does not exercise overflow queues.

Raw log, exact helper snapshot, launch hashes, companion build manifest and both
reports are in `evidence/sprint-6/native-campaign-sites-dev1`. Infection PBO is
unchanged at `B4B0C17E92A87E16020635ED4EBCD8AD1E28DD2FF78C5866C494EC23DD981085`;
Redux Fixes is `CCFAEEB0245C8916327AAA179A7A111EC86080F1649EA1FB57D9E58F4374586E`.
Thirteen campaign/site/parser regression tests pass. The server was stopped after
checking its exact executable and profile. No Computer Use or manual-install
changes occurred; no broader sprint acceptance gate is closed.

The seven-category expansion adds coverage rather than extending this earlier
29-check result by inference. Its evidence will be recorded separately.

## Rejected seven-category Dev1

The first expansion incorrectly used the 24-unit ceiling as the active context
setting. At the seaport, the real budget correctly admitted 12 living defenders
and retained four queued entries, preserving all 16. The fixture nevertheless
waited for 16 simultaneous actors and failed its combined readiness/accounting
check. This is a test defect, not evidence of a production spawn failure.

The run was stopped and preserved under
`native-campaign-sites-all-dev1-rejected`, including exact fixture and receipt.
The corrected fixture reads and logs both live settings. No production code or
budget setting is changed to satisfy the test. The smaller earlier Dev1 never
exceeded 12 actors at its permanent resource site; its bounded result remains
distinct from overflow validation.
