# Native Redux Extraction failure probe

`start-campaign-probe.ps1 -ExtractionLifecycle` extends the normal isolated
campaign startup/save checks. It calls the public server missionRequest with
RES and silent notification, without replacing selectors, scene factories,
ledgers, task endpoints, rewards or cleanup. No player is fabricated.

Thirteen checks require eligible nearby infected locations, public dispatch,
actual task registration, an eligible source, 2-6 healthy survivors and four
initialized infected guards, then native CREATED task state. Engine deaths of
all survivors must settle the task as FAILED with no rescue credit. The native
one-minute cleanup must remove tracked survivors/guards/groups and release the
spawn budget while preserving HQ. No task state or cleanup timer is forced.

Runtime evidence is pending. Five collector tests and launcher parsing pass.
This covers no player interactions, survivor delivery/success, multiplayer,
task retirement after the native 10-30 minute display period, or performance.
