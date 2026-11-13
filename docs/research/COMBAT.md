# Prepared infected combat bookkeeping

This increment implements the I04 contract against Ultimate 12.4.2. It does not
make the campaign's site, support or mission routes ready. See the
[override ledger](OVERRIDES.md) for upstream hashes and scope guards.

`A3A_fnc_NATOinit` delegates to the installed original for ordinary units,
unselected Infection, missing dependencies and other sides. The infected branch
requires the Infection Occupant selection, WEST campaign metadata, an
`loadouts_occ_` role, and one of the three approved prepared basic classes.
This deliberately excludes arbitrary WEST units, unregistered WebKnight units
and special creatures until their own spawn policy exists.

For a local managed unit the adapter sets Ultimate's resource pool, site marker,
spawner and no-human-incapacitation metadata, installs its own three handlers
once, and emits Ultimate's existing server AI-init event. It preserves
WebKnight's handlers, health, AI and prepared identity. Implicit persistent
garrisons inherit their site's simulation state; an explicit spawner argument
retains Ultimate's existing exception to that rule.

| Event | Implemented behavior |
| --- | --- |
| Damage | Observe Rebel attacks for the existing site contact report, throttled to one update per 30 seconds. Return no damage value, leaving other damage handlers authoritative. No human revive handler is installed. |
| Death | Run Ultimate postmortem and garbage-queue registration once; remove spawner status; charge only unpaid legacy units. Preserve recent-damage records and normal combat support/aggression requests. Do not interpret an unarmed infected as a surrendered human or launch human AI reactions. |
| Garrison death | Remove one matching virtual roster entry and request the normal zone check only while the site still belongs to the infected side. |
| Live deletion | Refund a surviving prepaid attack/defence unit once. Preserve a surviving persistent garrison entry. Remove an unfit unit from its owned garrison and charge its unpaid legacy resources. |
| Corpse deletion / repeated callback | Do not refund, debit or remove a second roster entry. |

The player-credit and captive-breaking code follows Ultimate's original combat
path, but no connected human player was part of these tests. That path remains
unaccepted. The adapter also preserves Ultimate's optional ACE last-damage-source
fallback; it does not establish ACE Medical compatibility.

## Engine evidence

The [combat build](../../evidence/sprint-1/combat-build.json) completed
[120 checks](../../evidence/sprint-1/combat-contract.json) on an isolated dedicated
VR server. This includes the prior loader, 67 prepared roles and garrison checks,
plus 24 combat/init/cleanup checks. The real engine created and killed/deleted
the units, processed rifle impacts, ran CBA events, updated enemy resources and
the virtual roster, and queued corpses through Ultimate's postmortem function.
All three basic types died from rifle fire without entering human unconsciousness.
No test entities or groups remained after cleanup.

The test-only `A3I_test_contracts` addon records support, aggression, zone-task,
human-reaction and original-init dispatch requests before functions are compiled.
It also counts vehicle selection while delegating to the actual installed
selector. Thus these results verify the requests sent to those endpoints, not
their campaign UI/economy effects or complete ordinary-faction AI initialization.
The harness is built into `.work/probe-addons`, separately from the gameplay
addon, and is loaded only by `-Mode Template`.

The [missing-dependency run](../../evidence/sprint-1/combat-dependencies-absent.json)
passed 11 checks with Ultimate/CBA and no WebKnight/IMS or test endpoint addon.
Both fixtures verify the installed `[12,4,2]` patch version. The full run had
no recorded SQF/engine errors. Existing dependency/startup warnings remain in
the reports and are not counted as resolved.

The [validation corrections](VALIDATION_CORRECTIONS.md) explain the rejected
first combat harness, the earlier vehicle-query assertion and the report parser
fix. No interrupted or malformed report is used as passing evidence.

Still required: connected-player credit, ACE on/off combat, headless locality
transfer, JIP, real site capture/economy effects, full campaign death/cleanup,
multiplayer and save/reload. Only server-local ownership has been exercised.
