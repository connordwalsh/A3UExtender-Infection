# Antistasi Ultimate: Infection

An in-development Antistasi Ultimate extender that integrates WebKnight's
Zombies and Creatures as the Occupant faction. This repository is a fork of
[Westalgie/A3UExtender](https://github.com/Westalgie/A3UExtender).

**Status: development prototype; campaign integration is incomplete.** The
`Infection/` addon registers the infected Occupant, supplies basic unit definitions,
creates foot-only virtual garrison lines, adapts infected combat bookkeeping,
and spawns full queued garrisons at six persistent site types under shared limits.
Road/field controls use capped foot groups and guarded local capture.
Infected-held towns use a population-based logistic target of 10–200 infected,
activate the complete population together and spread groups across the town.
Each town has its own allowance; casualties regenerate on a later visit.
Administration strongholds require clearing even after building destruction;
survivor rescues give separate rewards, and uncleared defenders regenerate each visit.
Routine reinforcements use paid foot groups, cooldowns and combat checks, and
join persistent garrisons only after arriving within the active limits.
Roaming patrols use bounded foot routes between nearby owned locations.
Capture-triggered counterattacks use paid foot groups and native ownership checks.
The completed isolated dedicated regression passes 464 checks on Ultimate 12.4.2,
including 67 roles, combat, placement, later arrivals, controls, towns, strongholds,
routine reinforcement, roaming, counterattacks, town ownership handoffs and cleanup.
The missing-dependency suite passes 11 checks.
Tactical QRF, strategic attacks, missions and save integration remain unfinished. Do not use this build for a
campaign you intend to keep.

## Intended campaign

- Infected Occupants on BLUFOR, NATO Rebels on INDEP, Russian Invaders and gangs
  on OPFOR, and survivor civilians on INDEP if the campaign supports it.
- Foot-based territory defense, reinforcements, counterattacks, and achievable
  outbreak missions with bounded spawning and cleanup.
- Major creatures restricted to special missions and high-war-level military
  base capture counterattacks.
- Abandoned police, light military, and civilian vehicles that can be repaired
  and driven.
- New campaigns only; optional mods detected without making them dependencies.

The required gameplay stack is Ultimate, Zombies and Creatures, Improved Melee
System, and CBA_A3. Chernarus Redux and CUP Terrains - Core are additionally used
for campaign acceptance on the launch terrain. This is a dependency plan, not a
claim that compatibility testing has passed.

## Development records

- [Original plan and acceptance gates](docs/planning/PROJECT_PLAN.md)
- [Mission statement](docs/planning/MISSION_STATEMENT.md)
- [Product-owner decisions and amendments](docs/planning/PRODUCT_DECISIONS.md)
- [Scrum and review workflow](docs/planning/WORKFLOW.md)
- [Sprint 0 evidence](evidence/sprint-0/)
- [Registration implementation and limits](docs/research/REGISTRATION.md)
- [Combat implementation and limits](docs/research/COMBAT.md)
- [Spawn budget component and limits](docs/research/SPAWN_BUDGET.md)
- [Persistent site spawning and limits](docs/research/SITE_SPAWNING.md)
- [Road/field controls and limits](docs/research/ROAD_CONTROLS.md)
- [Full-town populations and limits](docs/research/TOWN_INFESTATIONS.md)
- [Administration strongholds and rescue limits](docs/research/ADMINISTRATIONS.md)
- [Routine foot reinforcement and limits](docs/research/REINFORCEMENTS.md)
- [Roaming foot patrols and limits](docs/research/ROAMING_PATROLS.md)
- [Capture counterattacks and limits](docs/research/CAPTURE_COUNTERATTACKS.md)
- [Tactical support follow-up audit](docs/research/TACTICAL_SUPPORT_CONTRACTS.md)
- [Remaining attack and support contracts](docs/research/RESPONSE_CONTRACTS.md)
- [Controlled behavior observations](docs/research/BEHAVIOR_12.4.2.md)
- [Validation corrections](docs/research/VALIDATION_CORRECTIONS.md)
- [Sprint 1 contract evidence](evidence/sprint-1/)
- [Sprint 2 site and placement evidence](evidence/sprint-2/)
- [Sprint 3 reinforcement and roaming evidence](evidence/sprint-3/)
- [Upstream extender instructions](docs/upstream-extender.md)

Runtime reports will distinguish observed behavior from source findings and
pending checks. No campaign, multiplayer, or save compatibility is claimed until
its required scenarios pass.
