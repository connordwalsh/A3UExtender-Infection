# Controlled prepared-class behavior observations

The 13 November dedicated run completed all 112 trials: 14 candidate classes,
each with a waypoint, passive INDEP and EAST targets, CIV and INDEP survivor
targets, empty and occupied vehicles, and an armed rifle opponent. The installed
Ultimate baseline was 12.4.2. Infection was not loaded, so these are observations
of prepared WebKnight classes, not campaign or combat-adapter acceptance.

The [collected report](../../evidence/sprint-0/behavior-12.4.2.json) retains the
runtime settings, per-trial measurements, source/log hashes and error categories.
All trials produced matching setup/result/cleanup records, with no remaining
trial entities or groups. No SQF error records were found. The report deliberately
remains `failed_or_aborted`: its final ownership assertion failed for seven
special-creature trials. A completed batch is not equivalent to every acceptance
condition passing.

## Basic types used by Infection

| Prepared class | 25-second movement toward a point 20 m away | Other observations |
| --- | --- | --- |
| `Zombie_B_Walker_Civ` | Moved 10.57 m; ended 9.43 m from the point | Acquired INDEP/EAST and INDEP survivor targets; injured the survivor; damaged an occupied offroad. |
| `Zombie_B_Shambler_Civ` | Moved 20.99 m; ended 0.99 m from the point | Acquired and killed passive INDEP/EAST and INDEP survivor targets; destroyed the occupied offroad in this trial. |
| `Zombie_B_RA_Civ` | Moved 21.14 m; ended 1.24 m from the point | Acquired and killed passive INDEP/EAST and INDEP survivor targets; destroyed the occupied offroad in this trial. |

All three basic types remained server-local and were killed by the rifle opponent.
They produced no categorized model errors. The results support using ordinary
movement orders without replacing their melee AI; they do not prove long-distance
arrival times, building navigation or movement on Chernarus Redux.

Every candidate ignored the passive CIV target during its short trial. The three
basic types acquired the same survivor class after it joined INDEP. Empty cars
were ignored by these basic types. WebKnight's defaults were left unchanged;
this is not evidence of long-term infection/conversion behavior or of support
for moving all Ultimate civilians to INDEP.

## Specials remain candidates

Boomer ended with `local=false, owner=0` in four combat trials; Corrupted did so
in three. Both were no longer alive. These readings are consistent with deleted
objects, but the fixture did not record `isNull`, so it cannot certify end-of-trial
locality for those objects. Keep the failed assertion visible and extend the next
special-creature fixture to distinguish deletion, death and ownership changes.

Corrupted, Smasher, Acid Smasher, Hellbeast and Goliath emitted model/skeleton or
attachment errors (1,020 categorized `Error:` records in total). Goliath also
produced convex-component warnings. These candidates are not approved for
production spawning. The generic Infection template contains only the three
basic types above. No boss or special is enabled by this study.

The short VR trials use passive stationary targets and explicit AI fire orders.
They do not establish player experience, terrain pathing, human weapon controls,
ACE behavior, headless transfer, JIP, campaign rewards, persistence or a server
performance target. Those checks remain separate backlog items.
