# Attack and support integration contracts

Research baseline: Ultimate 12.4.2, commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. The
[27-file source manifest](../../evidence/sprint-3/response-sources-12.4.2.json)
records the files behind this audit. This is source evidence for S3-1/S3-3.
The [capture-response increment](CAPTURE_COUNTERATTACKS.md) implements the
`singleAttack` route; other adapters below remain open. The
[tactical support follow-up](TACTICAL_SUPPORT_CONTRACTS.md) adds direct rebuilding
constructor and legacy mission-caller findings.

## Entry points and lifecycle owners

| Trigger / entry | Observed contract | Required infected treatment |
| --- | --- | --- |
| `markerChange` -> scheduled `singleAttack` | Rebel capture computes a defence allowance with a 0.6 location cap, converts it to a vehicle count and adds estimated support-spend/strike entries. `singleAttack` calls the mixed factory, attempts `zoneCheck` and ends on capture, defeat or 2700 seconds. | Server-owned foot response; preserve the native ownership transaction and caller accounting. Do not debit both the estimate and each created actor. No-force outcomes must end promptly. |
| `chooseAttack` -> `wavedAttack` | Sets forced spawning, creates a defence task, launches mixed waves and independently adds aircraft and artillery. Defeat also requests a minefield. Rewards, task state, attack flags and cleanup belong to the caller. | Adapt the complete infected wave lifecycle; replacing only the mixed factory leaves air/indirect-fire/mine paths active. Refused waves must not produce free defence rewards or a stranded task. |
| `attackHQ` | Requests UAV support, mixed troops and artillery; monitors the original Petros object, then resolves rewards, task and HQ/major-attack flags. | Preserve explicit terminal states and cleanup. Spawn exclusion around HQ must remain distinct from a legitimate force approaching it. |
| `townBattle` | Calls the mixed factory with militia/police modifiers inside a larger battle/task lifecycle. | Audit and adapt its battle outcome together with foot creation, not just its vehicle pool. |
| `ultimate/REINF/simpleAttack` | Returns the mixed factory's four-field result directly; its default side is Invaders but callers may pass another side. | Preserve the return contract and clarify which caller owns each returned group's cleanup. |
| `requestSupport` -> `createSupport` | Serializes support requests, updates HQ knowledge, validates target/threat/resources and weights registered support classes. `createSupport` returns a support name or an empty string. | A narrow infected allowlist and bounded foot response. Keep valid cost/cooldown/target handling and release the shared call lock on every outcome. |
| Administration `DESTROY` | Native code can request support and separately spawn police vehicles. Infection currently preserves aggression and clear-to-capture behavior but bypasses those vehicle responses. | Add a foot destruction response without restoring the native automatic capture or duplicate reaction. |

`invaderPunish` explicitly passes the Invader side. Its force and artillery
behavior is a regression boundary, not an infected route to replace.
`CON_Outpost_Compet` also calls `wavedAttack`, so mission-triggered waves must be
included in the final caller audit.

## Payment and force-result contracts

The mixed factory returns `[cost, vehicles, crewGroups, cargoGroups]` and debits
the actual cost of each land/air/orbital batch itself. Its land branch treats an
empty vehicle array as an error even if infantry groups were returned. Therefore
a foot-only replacement of `createAttackForceLand` alone is insufficient.

The support path uses a different payment contract: `createSupport` debits the
estimated cost returned by `SUP_QRFLand`/`SUP_QRFAir` and related constructors.
`SUP_QRFRoutine` creates the delayed force and refunds the difference between the
estimate and actual cost. Direct tank support also calls the land factory.
An infected adapter must choose one payment owner and exercise exact resource
balances for partial creation, later resource exhaustion, cancellation, death
and healthy deletion. The existing paid-spawn primitive is reusable; passing it
through both native payment layers would charge twice.

Single/HQ/waved attack defeat predicates compare surviving troops with a
fraction of the original count. A zero-sized force does not satisfy their strict
`0 < 0` comparison and can wait until timeout. Native QRF uses a non-strict
comparison, so its empty-force behavior differs. No-spawn is an explicit outcome
to test for each caller rather than an empty-array convention to assume safe.

## Support eligibility and return-to-base

Empty template pools do not remove every support. The registry includes types
with an empty prerequisite key, including `TANK`, `QRFLAND`, `QRFAIR`,
`CARPETBOMBS`, `SAM`, `CRUISEMISSILE` and `ORBITALSTRIKE`, subject to separate
configuration flags. Both automatic selection and direct creation/indirect-fire
entry points need an infected policy. The ordinary Invader registry must remain.

Native land-source selection uses vehicle spawn places. Foot source selection
must instead validate owned land, road connectivity, safe actual spawn positions
and departure/arrival changes. A road-graph result does not establish Redux
walking, bridge traversal or a reachable building entrance.

Native `enemyReturnToBase` can hand foot groups to `enemyGarrison`, disable
targeting/autocombat, start its own despawner or invoke surrender when no base
exists. Its source explicitly warns about double counting offscreen garrisons.
Infection needs a single owner for budget bindings, saved-roster additions and
observer-aware cleanup. A successful counterattack must not enter both native
and Infection garrison controllers or duplicate its surviving actors.

## Implementation and acceptance sequence

After validating the capture-triggered foot response, adapt tactical support selection/creation and the
remaining strategic callers with their task/flag contracts. Record each air,
naval, convoy and indirect-fire route as replaced or excluded before Gate 3.

Tests must exercise both infected and ordinary faction routes; no-source and
no-budget requests; delayed and partial creation; source/target changes;
timeouts and interrupted scripts; exact costs/refunds; and empty final
controller/budget state. Real campaign capture, Redux journeys, connected players,
save/restart and a long idle session remain separate acceptance gates. Large
creatures stay outside all generic groups until their dedicated role and event
gates pass; their known model/locality defects remain unresolved.
