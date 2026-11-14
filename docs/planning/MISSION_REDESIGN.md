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

Destroy Missions and Random Missions were struck out without replacements.
Their intended removal scope is awaiting clarification.

## Pending decisions

Questions sent to the owner:

- Apply these replacements only to infected missions or also Russian/gang missions?
- Disable Destroy and Random categories against infected?
- Allow delivery at HQ, Rebel-held permanent sites, or also Rebel-held towns?

Further behavior to resolve before implementation: horde arrival failure rules,
eligible resource trucks and distribution, and whether Liquidation retains the
existing competitive conquest variant. Answers are not inferred from briefings.

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

Check direct requests, retained random/automatic callers and non-infected
behavior under the scope decision. Multiplayer visibility, late joining,
campaign saves and manual gameplay remain separate acceptance checks.

Status: requirements capture and source audit only. Gameplay implementation,
packaging and runtime validation for this redesign: **NOT_RUN**. The active
Dev9 game and its immutable artifact remain unchanged.
