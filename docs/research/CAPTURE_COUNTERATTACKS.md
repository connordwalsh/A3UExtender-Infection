# Capture-triggered infected counterattacks

This increment covers `singleAttack`, the response requested by Ultimate's
ownership-change transaction. Tactical support, large strategic attacks and
special creatures remain separate work. The baseline is Ultimate 12.4.2,
commit `c7c8247672ed5e7d4aa317d47efb371c41de4e7d`; the original
`CREATE/fn_singleAttack.sqf` SHA-256 is
`4307b88c3385da599c745e8fba23671642f7721fe12554a0745a610fb221beda`.
The [response audit](RESPONSE_CONTRACTS.md) records the caller and payment owners.
The [capture source manifest](../../evidence/sprint-3/counterattack-sources-12.4.2.json)
also pins native distance activation and Rebel garrison initialization.

## Request, movement and cost

Only the active infected Occupant route changes. Other factions and inactive
dependencies/templates use the installed original function. The scheduler keeps
infected requests on the server, including when headless clients are registered.
Valid targets are Rebel- or Invader-owned persistent sites and towns. A target
has one pending response and a 600-second cooldown; a defeated Occupant faction
cannot start or continue a response.

Sources are nearby owned outposts, military bases or airports, unspawned and
unforced, with at least 16 saved defenders, a completed native idle period,
no observer within 700 metres and at most 50 recent damage in 300 seconds.
The source roster is not consumed. Sources must share a bounded road-graph route
with a checked outdoor destination: at most 2 km straight-line distance (or the
lower native attack-distance setting) and 500 metres extra graph distance.
Actual ground points replace the native vehicle-spawn redirects.

The native vehicle-count allowance is converted to basic infected at ten defence
resources each, capped at 64 planned actors and affordable funds. The native
capture caller's estimated support spend is retained; it does not debit funds.
Actual births pay once, in batches of at most four, normally 15 seconds apart.
The existing shared limits, safe-placement checks, source checks and fresh funds
checks govern every birth. Blocked or unpaid roles wait for up to 600 seconds;
they neither exceed the active cap nor incur charges. No special creature,
vehicle, aircraft or indirect-fire pool is used by this adapter.

Groups receive foot movement orders to the destination. Walking toward a site
near HQ is allowed; the default exclusion around HQ still applies to every
birth. Approaching actors carry the native spawner flag so their presence can
activate defending garrisons without a connected player. The native
intercepted-communications call runs after the first birth.
Its reveal level is capped below the native ETA threshold because Infection has
no verified walking ETA. A client-visible warning remains an acceptance check.

## Capture, failure and cleanup

Only a living response actor within 200 metres triggers the native `zoneCheck`.
The target must be active and its living, marker-bound defenders must account
for the remaining saved roster. This prevents an early ownership check from
skipping native defenders that are still waiting to spawn.
That existing transaction still decides ownership from the forces present.
After staging ends, fewer than 25 percent of created actors able to fight causes
retreat, matching Ultimate's threshold. Empty forces terminate explicitly.
Source loss, a third-party target change, faction defeat, a 2700-second timeout
or an interrupted controller also terminates the response.

After infected capture, complete arrived groups can transfer once into a live
persistent site's roster and budget context. The normal site capacity and
active limits still apply. If the active site has no Infection controller yet,
the handoff starts an actor-only controller. It does not duplicate or take over
the previous faction creator's flags, crates, civilians or activation events.
Normal site activation still creates those assets by default.
An offscreen persistent site can instead store the
arrived healthy roles and retire their physical copies atomically, without a
refund. That path requires a closed ticket containing exactly that living group,
all actors within 200 metres, no active/cleaning site and no nearby observers.
It does not apply to towns, whose patrols retain per-visit regeneration.
An active captured town instead starts its separate full-population controller;
the arriving counterattack actors are not written into its garrison or borrowed
by its population allowance. Existing town visits are reused.
Handoff retries last at most 60 seconds.

The response watchdog owns retirement of actors that were not adopted. It
orders a retreat when the source still belongs to the infected and waits until
survivors are outside observation range before deleting them. Healthy prepaid
survivors refund their actual cost once; dead actors do not. Adopted groups have
a different context, so response cleanup cannot remove their saved roster or
live actors. Interrupted creation is recovered from budget bindings rather than
only the controller's last recorded actor array.

## Validation boundaries

The focused fixture uses real engine actors, resource transactions and movement
with synthetic road geometry. The combined fixture also runs native distance
activation while recording the eventual defender-creator endpoint. Arrival
positions and ownership changes are injected; `zoneCheck` calls and ordinary-function delegation are recorded by an
isolated test addon. This does not certify actual campaign recapture, Redux
journeys, connected-player cleanup, client warnings, headless transfer, saves or
performance. Cooldown persistence and high-war special-creature events remain
open.

The first development run is rejected as incomplete: an incorrectly parenthesized
test-array index stopped the offscreen-arrival fixture after earlier checks
passed. The fixture was corrected before a 55-check focused pass. Source review
then found that native distance processing requires the attackers' spawner flag
and does not recreate an active site's controller on ownership change. The first
combined run was stopped and rejected as incomplete while those gaps were fixed;
the corrected fixture no longer supplies a site controller for the response.
The [combined population regression](../../evidence/sprint-2/town-infestation-contract.json)
passes all 464 checks, including 51 counterattack cases, native distance
activation and capture-to-town population startup. The strict collector records
no engine/SQF Error records and retains 61 dependency/deletion warnings. The
83-file integrated build and its 11-check dependency-absent result are linked
from [full-town populations](TOWN_INFESTATIONS.md). The earlier counterattack-only
build and dependency result remain historical evidence in `evidence/sprint-3/`.
