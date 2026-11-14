# Strategic infected attack follow-up

Baseline: Ultimate 12.4.2, commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. The
[source manifest](../../evidence/sprint-3/strategic-sources-12.4.2.json)
pins the inspected files. This records contracts for the next S3 increment;
strategic infected attacks are being prototyped and are not campaign-accepted.

## Owner decisions

On 14 November the owner selected attacks launched only from infected-held
locations within walking range. Aircraft, detached staging spawns and distant
long marches must not make an otherwise unreachable target eligible. The owner
also explicitly allowed later attacks to retake secured towns, separate from
immediate capture counterattacks. The infected side's strategic supply convoy
therefore needs a walking town-recapture replacement. A subsequent owner answer
includes towns and permanent sites such as factories and resource sites as horde
origins, rather than only military locations. Invader routes retain their
ordinary behavior.

The owner subsequently selected one larger horde instead of successive waves,
using the shared active limit and bringing in waiting attackers gradually as
earlier attackers die. Temporary attack-resource debt follows native policy.

## Target selection and payment

`findAttackTargets` starts from airports and a carrier, filters using air range,
accounts for flyover threat and separately counts land-capable bases. Its city
shortcut selects supply-convoy bases. Simply filtering its final result cannot
fully implement a foot campaign: valid nearby ground origins can be absent from
the original list. Preserve target value/threat rules where applicable while
replacing the origin/range/route rules and removing carrier/flyover assumptions.
HQ eligibility still depends on the attacking side's accumulated HQ knowledge.

`aggressionUpdateLoop` calls `chooseAttack` when attack resources are positive and
no major attack is active. A false result applies a pacing penalty. Positive is
not the same as enough resources to fund a whole attack: native `chooseAttack`
debits 400 before a real HQ or waved attack and 200 before a supply convoy, then
the mixed factory debits actual forces separately. Native strategic resources
can enter debt. The owner explicitly selected that same temporary-debt rule.
The foot adapter must scope debt to approved major attacks; simply combining
native upfront charges with current affordable-birth checks could produce an
empty attack. A refused or zero-force attack must not award a free
defence victory, leave a task open or strand global attack flags.

Unobserved enemy-vs-enemy attacks use an alternate simulation branch. It debits
defence and attack resources, flips ownership, then adds already-paid saved
roles. Apply the owner's walking-source restriction before either real or
simulated launch. Keep virtual roster payment distinct from paid live arrivals.

## Lifecycle owners

| Entry | Native responsibilities that need explicit treatment |
| --- | --- |
| `chooseAttack` | Target/ownership checks; town, HQ, real-wave and simulated dispatch; fixed charges; global attack flags; Boolean result consumed by the aggression loop. |
| `wavedAttack` | Forced target activation; task or enemy-vs-enemy notification; up to three waves from the normal selector; separate aircraft and artillery; capture, below-25-percent defeat and 900-second wave deadlines; minefield on failure; rewards, return-to-base and flag cleanup. |
| `attackHQ` | Forced HQ activation; defence task; UAV and artillery calls; player-scale preparation delay; original Petros object; below-33-percent defeat and 900-second deadline; rewards, both attack flags and cleanup. |
| `CON_Outpost_Compet` | May run through the HC scheduler; chooses an air origin and starts `wavedAttack` directly, passing two/four/six as the wave count. Its own conquest task is independent. The normal three-wave cap does not protect this caller. |
| `resourcecheck` -> `townBattle` | A separate town-liberation skirmish triggered by civilian support. Uses a nearby outpost, survivor/VIP, vehicle/scenery effects, a preparation phase, a mixed force, support changes, rescue/reward conditions and eventual cleanup. It is not the newly approved later town-recapture attack. |
| `ultimate/REINF/simpleAttack` | Passes through the mixed factory's four-field return, defaults to Invaders and accepts an explicit side. Caller ownership of returned groups must remain clear. |

Replacing only `createAttackForceMixed` is insufficient: waves independently
create attack helicopters and later minefields. The native mixed land branch
also treats an empty vehicle array as failure despite any returned infantry.
Foot spawning needs one payment/cleanup owner and explicit terminal outcomes.

Major attacks must claim and release only their own forced-spawn/task/global
state. Source loss, third-party capture, moved HQ, Petros replacement/death,
insufficient force, timeout and stopped-script recovery need separate cases.
Travel time for foot forces must be included in bounded deadlines; the native
airborne/vehicle timing is not evidence of an achievable walking journey.

## Town ownership boundary

Native `zoneCheck` can request an enemy capture when attackers outnumber local
defenders by more than three to one. `markerChange` handles the transaction;
the existing Infection handoff then starts the appropriate town population.
Town political ownership is also processed by `resourcecheck`/`cityChangeSide`.
Exercise those paths together; do not silently add a new support reset or lock
town ownership. The owner's existing instruction retains Ultimate conventions
for town ownership changes and per-visit population regeneration.

## Required evidence

Test eligible and unreachable targets, source ownership and readiness changes,
both real and simulated dispatch, task/flag ownership, every no-force outcome,
exact costs/refunds, wave caps, physical arrival and native capture, paid garrison
handoff, HQ/Petros changes and interrupted cleanup. Include normal Invader and
inactive-template delegation. Confirm the town-recapture adapter cannot produce
a supply truck, aircraft, artillery or minefield.

Redux routes, completed long walks, connected-player task presentation,
rebuilding/competitive missions and saved-campaign transitions remain separate
acceptance work. Only the initial selector/credit/lifecycle checkpoint below has
runtime evidence; the complete route matrix and campaign scenarios are NOT_RUN.

## Selector development checkpoint

`majorAttackTargets` is a prototype on the strategic-attacks branch. It is
registered for direct validation but is not wired into native campaign dispatch.
It uses nearby towns and permanent infected sites with bounded outdoor road
routes, preserves native population/site values and local threat components,
requires native HQ knowledge, removes air/carrier/convoy assumptions and retains
per-target source normalization. Empty enemy economic sites receive a finite
difficulty floor to avoid dividing by zero. Towns are eligible targets for the
owner-approved later recapture route.

The broader source predicate retains ownership, activation, combat and observer
checks without the military counterattack's sixteen-role minimum. Source cooldowns
need a separate namespace: town population arrays occupy the same native server
keys used for military idle timestamps. Military origins also honor their native
idle timestamps. Tactical support keeps its original military candidate list and
eligibility predicate; the route helper accepts explicit candidates for majors.

Town selection reads the existing `server` population array. The similarly named
native `getCityData` initializes all towns and must not be called as a getter;
source review corrected that mistake before the first build. The new 41-case
selector fixture covers permanent categories, ownership/readiness, native idle
and town cooldown isolation, values/threats, route limits, HQ knowledge and
unchanged tactical default candidates. These cases pass in the checkpoint below.

The first candidate is packed and has an initial isolated engine checkpoint. A direct
`startMajorAttack` prototype combines up to three native strength allowances into
one finite queue (at most 192 basic infected), retaining the shared active cap.
Town attacks have the native 200 fixed charge; other campaign attacks have 400.
Each actual actor costs ten attack resources, with finite credit tied to the
live job, context and global attack owner. Ordinary callers remain subject to
their original affordability checks. A zero-force cancellation refunds the fixed
charge and gives no defence victory. Waiting actors count toward remaining
strength, preventing shared-cap staging from triggering an immediate retreat.

The controller has one preparation phase and a provisional 45-minute assault
deadline, source/combat/placement retries, arrival-gated capture, paid persistent
garrison handoff and a recovery watchdog. No aircraft, artillery or minefields
are created. Native task bookkeeping is retained; cancellations use BIS's
canceled state and native task deletion because Ultimate's task-update worker
accepts only success and failure. Completed attacks retain native rewards.
Walking duration and the chosen population ceiling require campaign tuning.

The focused fixture now has 59 selector, credit and initial lifecycle cases
(70 including startup checks). The [initial focused report](../../evidence/sprint-3/major-initial-focused.json)
passes all 70 checks on the [102-input candidate](../../evidence/sprint-3/major-initial-build.json)
without engine/SQF Error records. Two earlier runs are rejected: one omitted
native fixture globals and observed script termination before it completed;
the second observed payment before the worker appended its new actor. Corrected
observations now wait for the relevant engine/worker state without weakening
the expected resource or actor counts. Native dispatch,
offscreen simulation, direct mission adapters and expanded HQ/capture/reward
regressions remain to implement or exercise. This candidate is not installed in
the manual client, and native campaign attack selection is not wired to it yet.
