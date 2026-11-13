# Antistasi Ultimate: Infection

An in-development Antistasi Ultimate extender that integrates WebKnight's
Zombies and Creatures as the Occupant faction. This repository is a fork of
[Westalgie/A3UExtender](https://github.com/Westalgie/A3UExtender).

**Status: development prototype; campaign integration is incomplete.** The
`Infection/` addon registers the infected Occupant, supplies basic unit definitions,
creates foot-only virtual garrison lines, and adapts infected combat bookkeeping.
The current isolated dedicated suite passes 120 checks on Ultimate 12.4.2,
including 67 roles and rifle/death/deletion contracts. Site, reinforcement,
mission and save integration remain unfinished. Do not use this build for a
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
- [Validation corrections](docs/research/VALIDATION_CORRECTIONS.md)
- [Sprint 1 contract evidence](evidence/sprint-1/)
- [Upstream extender instructions](docs/upstream-extender.md)

Runtime reports will distinguish observed behavior from source findings and
pending checks. No campaign, multiplayer, or save compatibility is claimed until
its required scenarios pass.
