# Antistasi Ultimate: Infection — product decisions

Decisions supplied by the product owner on 12 November 2026. These amend the
original project plan; they are not evidence that the behavior is implemented.

| Topic | Accepted requirement |
| --- | --- |
| Product | Antistasi Ultimate: Infection |
| Repository | Public `connordwalsh/A3UExtender-Infection`, forked from `Westalgie/A3UExtender`. |
| Dependency baseline | Current distributed versions of Antistasi Ultimate, WebKnight's Zombies and Creatures, and their dependencies. Extra gameplay mods must remain optional and detected at runtime. |
| Terrain | Chernarus Redux for campaign acceptance. Infection itself must not require a terrain addon. Independent terrain modifications belong in a separate repository. |
| Vehicles | Abandoned police cars, light Russian military vehicles, and civilian cars in towns and streets; repairable and drivable. The latest explicit correction places this feature in the Infection repository. It supersedes the earlier separate-repository decision. |
| Occupant forces | Infected on BLUFOR. No conventional infected vehicle crews. |
| Other factions | Rebels/NATO on INDEP; Invaders/Russia and Rivals/gangs on OPFOR. Civilians/survivors preferably on INDEP; CIV is acceptable if Ultimate requires it. Verify the actual side relationships and targeting. |
| Equipment fallback | Use vanilla stand-ins with the minimum dependency stack. Support authentic modern Russian/NATO equipment through optional mods; do not make a faction pack mandatory. |
| Civilian infection | Preserve WebKnight's default behavior. Determine that behavior from the installed code and live tests; do not invent an automatic-conversion rule. |
| Major infected | Largest creatures appear only in designated special missions or military-base capture QRFs at a sufficiently high war level. The developer may choose the threshold after inspecting the current war-level system. |
| Saves | New campaigns only. Existing campaigns are unsupported and must not be silently modified. |
| Garrison overflow | Preserve the full saved garrison. If it exceeds the active-unit limit, bring in its remaining infected gradually from safe positions. Explicit owner decision, 13 November 2026. |
| Testing | Manual Computer Use testing on the user's computer is explicitly allowed, including clarification after the goal repeated the older restriction. Other testing is also allowed. |
| Performance | No user-specified hardware or player-count target. Retain bounded spawning, cleanup, and stability checks; do not claim an unmeasured performance guarantee. |
| Workflow | Developer chooses Scrum organization and may review their own work. Use feature branches, useful frequent commits/pushes, and reviewed merges. |
| Uncertainty | Ask the product owner about unresolved product decisions. Do not substitute guessed data for verified source or runtime evidence. |
| Publication | GitHub publication is authorized. A public Workshop release remains a separate decision after release acceptance. |

## Scope and evidence

The full nine-sprint plan remains the backlog. A successful build or addon load
does not establish campaign, multiplayer, or save compatibility. Stories remain
open until their acceptance evidence exists; deferred tests must be labelled.

Current stage: baseline research and isolated registration implementation. No
campaign gameplay feature has passed acceptance yet.

13 November amendment: development is resumed **without Computer Use**. Source,
build and non-UI engine testing are authorized. Earlier UI authorization does not
apply to this resumed work. The owner separately requested the visible client
for their own manual tests.
