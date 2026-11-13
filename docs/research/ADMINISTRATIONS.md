# Infected administration strongholds

This increment implements the owner's decisions against Ultimate 12.4.2.
Uncleared strongholds regenerate their native defender roster on each visit.
Capture requires defeating every defender, including queued arrivals, even when
the administration building has been destroyed. Survivor rescues are optional
and have their own rewards. See [the pinned source contracts](ADMINISTRATION_CONTRACTS.md).

## Defenders and capture

The guarded creator replaces the human collaborator, stationary guards and
patrollers with approved basic infected on WEST. It preserves the native police
versus militia selection and inclusive randomized guard counts. The full roster
waits under the shared budget and arrives in batches through checked outdoor
positions. No occupied vehicle is created. The seventh site creator is kept on
the server; other factions and missing dependencies use installed originals.

Engine death events reduce a separate remaining-defender count once. Deleting a
living defender cannot satisfy the objective: it returns that role to the queue.
Body collection therefore cannot erase an unresolved death or fabricate a kill.
Shared cleanup closes the record before deleting actors, so ordinary despawning
does not requeue them. Ownership changes cancel waiting arrivals; interrupted
controllers use the same watchdog recovery as other sites.

Only a fully spawned and defeated roster, an empty queue, no living defender,
active simulation and unchanged infected ownership permit capture. The guarded
administration-removal entry point applies this predicate to native CAPTURE and
SILENT requests from nearby town/base changes. Building destruction preserves
its aggression cost once but leaves the clearing objective active. A ruined,
uncleared building can be revisited and cleared. Server LOADSTAT retains native
completed-site loading; remote clients cannot use it to bypass the guard.

Successful clearing calls the installed removal transaction to retain the
completed-building registry, Rebel ownership and native nearby support benefit.
Captives are not part of this predicate. Ordinary administrations delegate to
their original behavior.

## Survivor rescues and loot

Captives use the configured unarmed Rebel role and join the Rebel side explicitly.
Known buildings use validated native position indices. Other buildings use a
bounded list of their actual engine positions. Every placement requires a
supporting floor, headroom, wall clearance, spacing and the existing HQ/observer
exclusions. Missing geometry never falls back to the building center. Ruined
buildings receive no new captives or loot. Native loot selections, player scaling,
logistics callbacks and loot cooldowns are retained.

A server-validated player request claims one waiting captive. The rescuer must
remain alive, capable and within four meters during the five-second release.
Interrupted releases return the captive to waiting. A released survivor joins a
separate group, receives native Rebel initialization and flees toward the Rebel
side. Site cleanup no longer owns that survivor. After the native delayed escape
interval, a still-capable survivor gives one HR through the actual resource
function. Death, a repeated request or a failed release gives no reward. The
escape group then uses normal distance-based cleanup. The recurring rescue
handler removes itself when no jobs remain.

## Evidence and remaining work

The focused development run passed 47 checks before the final ruined-building
capture regression was added. Final combined regression results are recorded in
the accompanying sprint evidence and self-review; a focused pass alone is not a
campaign acceptance result.

The isolated fixture uses real infected, buildings, engine death/deletion,
native administration capture, Rebel initialization, escape orders and HR
updates. It records selected UI/logistics/cleanup/ordinary-route endpoints to
avoid starting unrelated campaign systems. It does not establish connected-client
action visibility, JIP, multiplayer ownership, Redux room geometry, actual
distance-despawner completion, or full mission success/failure behavior.

The administration mission still needs infected-specific wording and mission
integration. Destruction-triggered conventional responses are blocked here;
their replacement foot response belongs to S3. The native prisoner cooldown uses
absolute mission time, so restart persistence remains a save-adapter review item.
These limitations keep campaign and sprint acceptance open.
