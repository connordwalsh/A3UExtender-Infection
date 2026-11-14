# Mission redesign

Product-owner request: 14 November 2026. Requirements amendment only; these
replacements are not implemented in the running manual-test build. Existing
survivor-defense development remains separate.

## Requested catalog

Titles and briefings preserve the owner's supplied wording. Braced values refer
to actual mission locations or the selected resource truck.

| Current category | Replacement | Briefing |
| --- | --- | --- |
| Convoy Ambush | Horde Interception | A large group of infected have been spotted moving from {Settlement A} to {Settlement B}. Intercept and neutralize the horde. |
| Assassination Mission | Elimination Task | A powerful special zombie has been reported in {Settlement}. Find it and neutralize it. |
| Conquest Missions | Liquidation Assignment | High command calls for the liberation of {Settlement}. Cleanse the site of infected so friendly forces can move in. |
| Logistics Missions | Supplies Seizure | Intelligence reports a {Resource Truck} was positioned in {Settlement} before the infection. Bring the truck back to friendly territory for distribution. |
| Rescue Missions | Extraction Mission | Rumors have circulated that a group of survivors are stranded near {Settlement}. Get out there and bring them to a friendly site. |
| Supply Missions | Humanitarian Aid | {Settlement} has a lot of survivors who need our help. Deliver a package of supplies to them to buy time before we can move in for cleansing. |

Destroy Missions and Random Missions are removed completely in Infection
campaigns, regardless of target faction. Merely loading the addon without
selecting Infection must still preserve ordinary Ultimate campaigns.

## Accepted scope and rules

- The new catalog replaces all requested mission categories in Infection campaigns.
- Requested combat missions target infected exclusively; Russian/gang target
  variants are not retained in this catalog.
- Supplies Seizure and Extraction deliveries accept Rebel HQ or Rebel-held
  permanent sites, not Rebel-held towns alone.
- Supplies Seizure includes ammunition, fuel and repair trucks.
- Delivered trucks remain usable by the Rebels rather than being consumed.
- Horde Interception fails when the first infected enters Settlement B.
- Settlement B may be infected-held or Rebel-held.
- Liquidation is always a straightforward infected-site clearance. This
  supersedes the earlier requested competitive conquest/race-to-capture variant.
  Existing automatic strategic attacks are not themselves requested missions.
- Liquidation includes towns and permanent sites. Clearing the mission's infected
  immediately transfers the location to the Rebels, including towns that would
  otherwise require political support to change ownership.
- Military bases and airfields remain unavailable before war level 3, preserving
  Ultimate's capture restriction.

## Pending decisions

Truck resource types, horde arrival threshold and Liquidation target/capture
rules are now resolved. The precise distribution/reward behavior for recovered
resource trucks still needs a decision before implementing that transaction.

## Source audit

Inspected Ultimate commit `c7c8247672ed5e7d4aa317d47efb371c41de4e7d`
(12.4.2). Paths are relative to that repository, except the Infection path.

| Entry point | Finding and required adaptation |
| --- | --- |
| `A3A/addons/core/functions/Missions/fn_missionRequest.sqf` | Dispatches multiple human-target, guarded-prisoner, bank, salvage and vehicle-convoy variants. Each infected route needs an achievable replacement, including automatic callers. |
| `Infection/addons/core/overrides/fn_missionRequest.sqf` | Current routing adapts conquest/random; explicit other categories delegate to Ultimate. Extend behavior as well as wording. |
| `A3A/addons/gui/functions/GUI/fn_requestMissionDialog.sqf` | Converts Random into a concrete category on the client before requesting it. Removing only the server RAN branch would miss this path. |
| `A3A/addons/scrt/UILayouts/menu.hpp` | Legacy menu also submits individual categories and RAN. Keep both interfaces consistent with server policy. |
| `A3A/addons/core/functions/Missions/fn_LOG_Ammo.sqf` | Uses faction ammunition trucks, conventional guards and HQ delivery; destroying the truck can also succeed. Supplies Seizure must require the approved delivery behavior. |
| `A3A/addons/core/functions/Missions/fn_RES_Refugees.sqf` | Uses HQ return checks and rewards returned survivors. Replace its scenario and apply the approved destination rule. |
| `A3A/addons/core/functions/Missions/fn_SUPP_Supplies.sqf` | Town delivery includes additional encounter/completion logic. Audit the full sequence before adapting humanitarian aid. |
| `A3A/addons/core/functions/Missions/fn_CON_Outpost.sqf` | Completion uses Rebel ownership. Resolve Liquidation's relationship to capture and competitive conquest before changing settlement. |

## Acceptance work

Each replacement needs achievable eligibility, matching menu/task wording,
correct location/truck substitution, server-owned assets, and success, failure,
timeout, cancellation and interrupted-cleanup handling. Rewards settle once.
Spawning follows applicable approved budget rules; special targets remain
inside the declared special-mission policy.

Check direct requests, disabled random entry points, automatic callers and
ordinary campaigns with Infection unselected. Multiplayer visibility, late joining,
campaign saves and manual gameplay remain separate acceptance checks.

## First implementation increment

The draft blocks DES/RAN server requests before native delegation/random
selection and before acquiring or modifying the mission-request lock. A client
guard rejects RAN before Ultimate expands it to a concrete request. All four
native DES functions have Infection guards, covering direct/automatic/HC entry
points as well as the mission board. Both menu definitions hide and disable the
removed controls when Infection is selected. Other categories retain native
wording until their replacement objectives are implemented.

An isolated 13-case fixture covers request rejection, missing-type random
requests, preserving a busy request lock, GUI dispatch rejection, direct and
remote Destroy calls, inactive/dependency-absent delegation, and loaded config
inheritance. These cases are authored, not executed. Visual menu rendering and
connected-client/HC execution require separate runtime acceptance.

The Dev1 addon and fixture package successfully; three evidence-parser unit
tests pass. Runtime validation is **NOT_RUN**: the protected launch check found
the user's active Dev9 client (PID 52480), and no test server started. The active
game, profile, mission installation and immutable Dev9 artifact remain unchanged.

## Clearance tracking increment

Dev2 adds a death ledger to each site visit, attaching real Killed/Deleted event
handlers before successfully initialized defenders leave their creation
transaction. Adopted reinforcements add obligations to that same ledger.
Live deletion is not kill credit; administrative replacements retain their
existing replacement obligation. Cleanup and old-visit events cannot change the
current visit's ledger.

`siteClearance` requires an active, healthy controller, an empty spawn queue,
zero remaining obligations, no living recorded defenders and, for persistent
sites, an empty native garrison. Missing ledgers/actors and inactive or stopped
controllers do not count as clear. The predicate does not yet capture territory
or change ordinary capture rules; the Liquidation controller still needs wiring.

The isolated clearance suite passes 30 checks (11 shared checks and 19 new
contract cases), with no engine/SQF error records. Its 16 retained warnings are
startup/dependency notices. It uses real death/deletion events on a controlled
site record, not a complete mission. See `evidence/sprint-4/site-clearance-focused.json`.
The subsequent combined suite passes 717 checks, including strengthened real
site/town spawning and reinforcement assertions. Actual menu rendering,
multiplayer/HC execution and complete Liquidation acceptance remain open.

Dev2's combined run was stopped after 223 passing checks because its startup
log showed that the menu patches dropped native widget base classes. Dev3
preserves those classes explicitly. Its focused catalog suite now passes 25
checks (11 shared and 14 catalog cases), with no engine/SQF error records and
16 retained startup/dependency warnings. The new inheritance assertion passes.
An intermediate fixture failed on the native Random button's missing translation;
the corrected assertion checks preservation of the text property rather than
requiring an upstream translation. Both rejected/interrupted results are retained.
The corrected Dev3 combined run passes all 717 checks, with no engine/SQF error
records. The actual missing-dependency run passes all 11 checks. All 127
production files and the loaded PBO match the recorded manifest. Reports are
`mission-catalog-combined.json` and `mission-catalog-dependencies.json`.
The 71 combined warnings comprise 16 startup/dependency notices, 53 object
deletion notices and two absent-fixture-commander notifications. The dependency
run retains seven startup notices. These checks do not certify visual menus,
connected multiplayer, saves or full mission gameplay.

A separate source audit (`requested-mission-variants-12.4.2.json`) records 30
native requested-category variants and 44 literal caller references with source
hashes. It includes potential comments/examples and is not a complete dynamic
call graph. Replacement dispatch must cover civilian dialogue, intel and direct
entry points as well as the mission board.
