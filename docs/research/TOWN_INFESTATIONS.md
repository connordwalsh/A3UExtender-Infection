# Full-town infected populations

Owner decisions, 14 November 2026: use the proposed shifted logistic, activate
the entire town population, raise the cap from 180 to 200 with numerator 400
and subtracted term 200, and populate every infected-held town even during a
skirmish or when an enemy-owned base lies inside its boundary. Continue without
Computer Use. These decisions supersede the earlier fixed one-in-three target
and the native town-patrol skip rules.

## Population and lifecycle

The model reads population from index 0 of Ultimate's `A3A_townData` and computes:

```math
Z(P)=\operatorname{round}\!\left(\max\!\left(10,
\frac{400}{1+e^{-kP}}-200\right)\right),\qquad
k=\frac{\ln(11/7)}{50}\approx0.009039702475.
```

The growth constant is unchanged from the selected proposal. Consequently the
old comparison's calibration becomes approximately 44 infected at 50 citizens,
not 40. The continuous ceiling is 200; the implementation also clamps to 200
before rounding. Zero is a valid model input with the minimum of 10. Negative,
missing, nonnumeric and nonfinite population values reject the town selection.
The model is centralized for later customization; no new mandatory mod is added.

| Town | Ultimate population | Infected target |
| --- | ---: | ---: |
| Olsha | 23 | 21 |
| Tulga | 46 | 41 |
| Dubrovka | 100 | 85 |
| Pavlovo | 166 | 127 |
| Zelenogorsk | 367 | 186 |
| Elektrozavodsk | 603 | 198 |
| Chernogorsk | 1,176 | 200 |

Only infected WEST ownership uses this controller. Other factions and missing
dependencies retain the installed native creator. Support, marker size, frontline
status and destruction do not scale the target. Frontline and ruined status
continue to select the appropriate approved basic infected roles; no special
or giant creature is in this generic population. Native skirmish, conflicting
base ownership and nonhuman-civilian random skips no longer suppress infestation.

On activation the controller creates the complete population in one continuous
pass, in groups of at most 12. It yields briefly between actors and groups so
the server can schedule other work; it does not wait for casualties, a
neighborhood trigger or the old 15-second patrol interval. This is full-town
activation, not a requirement to execute 200 creation calls in one engine frame.

Unsafe or temporarily unavailable placements stay queued and retry after five
seconds. Faulty role definitions stop the controller with a diagnostic. Counts
are never discarded because a search failed. The normal native simulation
states still apply: state 0 is active, state 1 suspends existing actors, and
state 2 ends the visit and cleans up. Ownership loss cancels waiting births;
existing actors remain until normal cleanup. Killed infected do not regenerate
within the visit. A later visit starts with the complete population again.

Town casualties use native legacy resource/support bookkeeping and never write
a persistent garrison. Town ownership stays with Ultimate's support and ownership
system. Town actors are explicitly non-spawners, so they do not activate or keep
other locations alive by themselves. Civilians, traffic, vehicles and nearby
base assets are outside this controller's cleanup ownership.

## Capacity and placement

Each registered town receives its own population allowance, up to 200. Multiple
active towns each receive their full allowance. These slots cannot be borrowed
by events, persistent sites or another town. Outside-town settings keep the
existing shared 40-active/12-per-context defaults and 48/24 setting ceilings;
their labels now explicitly state that they govern actors outside towns.
This avoids retaining the old 12-unit town ceiling through a saved CBA setting.

All actors still use the same atomic reservation, binding, death/deletion,
expiry and cleanup machinery. Town tickets carry their budget domain. Transfers
into or out of town populations are rejected. Removing a town controller removes
its allowance and cancels every owned ticket, including partially created groups
not yet returned to the controller. Aggregate statistics report total allowance,
living actors, pending slots, tickets and per-context occupancy. The total
allowance is the outside-town cap plus all registered town populations.

Leader placement samples the complete marker, supporting rotated rectangles and
ellipses. It prefers cached in-town road positions, then samples the marker area.
Followers spawn within 50 metres of their group's anchor. Every search has at
most 16 attempts and retains ground, water, slope, geometry, entity separation,
HQ distance and observer distance/visibility checks. Placement is checked again
atomically before creation. There is no unchecked fallback position.

Each group patrols within the town near its own anchor, rather than every group
converging on the central 150 metres. Route points remain at most 150 metres
from that anchor, inside the town and validated against terrain/HQ constraints.
Failed route searches retain the existing 30-second retry deadline.

The server logs each town's target, completed activation count and elapsed time.
Blocked activation logs pending counts and reasons at most every 30 seconds.
These records are available even when detailed reservation logging is disabled.

## Verification boundary

The new focused fixture covers all 49 configured Redux population inputs, the
200-actor town, simultaneous independent towns, shared-budget isolation, actual
birth locations, movement, deaths, per-visit regeneration, ownership changes,
simulation, route retries and interruption during creation. The full regression
also exercises the unchanged non-town budget, sites, reinforcement and responses.

The [focused report](../../evidence/sprint-2/town-infestation-focused.json) passes
all 68 checks (57 town checks plus 11 startup/activation checks), with no
engine/SQF Error records and 20 retained dependency/deletion warnings. The
200-actor town and 21-actor neighbor completed activation in 22.89 seconds while
two additional actors occupied the non-town budget. The large town used 17 groups.
The final fixture state had no extra actors, groups, tickets or site records.
All 82 addon source files and the PBO match the
[build manifest](../../evidence/sprint-2/town-infestation-build.json).

Full regression is in progress; it also explicitly checks the non-spawner flag.
A synthetic dedicated fixture cannot certify Redux
street navigation, connected-player visibility, multiplayer/JIP, saves or
representative crowded-town performance. The earlier small-patrol evidence in
[TOWN_PATROLS.md](TOWN_PATROLS.md) does not establish this new behavior.
