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
| Routine reinforcement | Replacements for killed infected may approach persistent sites on foot while players remain nearby, subject to cooldown and combat checks. This is separate from the original roster's queued arrivals. Explicit owner decision, 13 November 2026. |
| Town patrols | Preserve Ultimate's per-visit patrol regeneration. Town casualties do not become a persistent garrison; explicit owner decision, 13 November 2026. |
| Town infestation density | Only infected-held towns, using Ultimate's own town population. The owner selected the shifted logistic, then raised its cap to 200 with numerator 400 and subtracted term 200, retaining the growth constant. Minimum 10, rounded whole actors. Activate the entire town population together. Always populate infected-held towns, even during skirmishes or with an enemy base inside their boundaries. Future customization remains intended. Explicit 14 November decisions; see [full-town populations](../research/TOWN_INFESTATIONS.md). |
| Town ownership edge case | For ownership changing away and back during an active visit, use default Ultimate conventions. The owner rejected adding a special recapture reset or population rule, 14 November 2026. |
| Major attack origin | Major infected attacks against distant Rebel sites or HQ launch only from infected-held locations within walking range. Do not use aircraft, distant long marches or detached staging spawns to reach otherwise ineligible targets. Explicit owner decision, 14 November 2026. |
| Major horde sources | Towns and permanent infected-held sites, including bases, factories and resource sites, may send major attack hordes. Origins are not restricted to military locations. Explicit owner clarification, 14 November 2026. |
| Major attack resources | Follow Ultimate's rule allowing temporary attack-resource debt, recovered through the normal campaign economy. Do not require the entire horde to be affordable before launch. Explicit owner decision, 14 November 2026. |
| Major assault pattern | Send one larger horde instead of successive waves. Use the shared active-infected limit, bringing remaining attackers in gradually as earlier attackers die. Explicit owner decisions, 14 November 2026. |
| Later town attacks | Infected may launch later attacks to retake secured towns, in addition to immediate capture counterattacks. These use walking hordes from eligible infected-held locations, replacing the infected side's native strategic supply-convoy route. Explicit owner clarification, 14 November 2026. |
| Competitive conquest availability | If the infected have no nearby town or site that can send a walking horde, a mission to capture the target before that infected attack is unavailable. Do not replace it with a normal capture mission. Explicit owner decision, 14 November 2026. |
| Competitive conquest result | A competitive conquest mission fails immediately if the infected capture the target before the Rebels. Do not keep the task open until its time limit after the race is lost. Explicit owner decision, 14 November 2026. |
| Town-liberation skirmish | Keep the local survivor rescue and defense objective in infected-held towns, replacing the conventional attacking force with a walking infected horde. Explicit owner decision, 14 November 2026. |
| Town-liberation defense clock | Start the ten-minute defense countdown when the walking horde reaches the town, not when it starts marching. Explicit owner decision, 14 November 2026. |
| Town-liberation scene | Retain the wrecked vehicles, bodies, burning/damaged buildings and usable vehicle beside the survivor. Explicit owner decision, 14 November 2026. |
| Town-liberation wreck resources | Scene wrecks count as abandoned vehicles. Capturing, destroying or cleaning them up must not change infected army resources. Explicit owner decision, 14 November 2026. |
| Town-liberation building restoration | Follow Ultimate's temporary scene behavior: restore scene-added building damage after the mission ends and players leave. Preserve pre-existing damage and unrelated campaign objects. Explicit owner decision, 14 November 2026. |
| Town-liberation no-origin fallback | A town with sufficient Rebel support may join peacefully when no nearby eligible infected origin can send the defense horde, preserving Ultimate's political fallback. Explicit owner decision, 14 November 2026. |
| Military administrations | Convert infected administrations into strongholds. Clearing the infected completes capture; survivor rescues give separate benefits and are not required for capture. Destroying the building does not bypass clearing the remaining infected. Uncleared strongholds regenerate their defenders each visit, preserving Ultimate's administration default. Explicit owner decisions, 13 November 2026. |
| Testing | Manual Computer Use testing on the user's computer is explicitly allowed, including clarification after the goal repeated the older restriction. Other testing is also allowed. |
| Performance | No user-specified hardware or player-count target. Retain bounded spawning, cleanup, and stability checks; do not claim an unmeasured performance guarantee. |
| Workflow | Developer chooses Scrum organization and may review their own work. Use feature branches, useful frequent commits/pushes, and reviewed merges. |
| Uncertainty | Ask the product owner about unresolved product decisions. Do not substitute guessed data for verified source or runtime evidence. |
| Publication | GitHub publication is authorized. A public Workshop release remains a separate decision after release acceptance. |

## Scope and evidence

14 November mission-catalog amendment: the owner supplied six replacement names
and objectives: Horde Interception, Elimination Task, Liquidation Assignment,
Supplies Seizure, Extraction Mission and Humanitarian Aid. Exact briefings,
source findings and pending decisions appear in [Mission redesign](MISSION_REDESIGN.md).
This records requested behavior; the active manual-test build does not contain it.

The owner subsequently confirmed the catalog applies throughout Infection
campaigns, with combat requests targeting infected exclusively. Destroy and
Random categories are disabled completely. Delivery accepts Rebel HQ or
Rebel-held permanent sites. Interception fails when the horde reaches its
destination. Liquidation is always infected-site clearance, superseding the
earlier competitive conquest requirement for requested missions.

Further owner clarification: seizure includes ammunition, fuel and repair trucks;
interception fails on the first infected entering the destination; Liquidation
includes towns and permanent sites and captures them immediately after clearing
the mission's infected, overriding ordinary town political capture for that task.
Military bases and airfields retain Ultimate's war-level 3 capture requirement.
Recovered supply trucks remain usable by the Rebels after delivery.
Interception destinations may be infected-held or Rebel-held. A Russian takeover
of a Liquidation target cancels that assignment without a penalty. The owner
authorizes developer judgment using Ultimate's existing time limits and rewards
as a starting point for replacement missions.

The full nine-sprint plan remains the backlog. A successful build or addon load
does not establish campaign, multiplayer, or save compatibility. Stories remain
open until their acceptance evidence exists; deferred tests must be labelled.

Current stage: baseline research and isolated registration, combat and site implementation. No
campaign gameplay feature has passed acceptance yet.

13 November amendment: development is resumed **without Computer Use**. Source,
build and non-UI engine testing are authorized. Earlier UI authorization does not
apply to this resumed work. The owner separately requested the visible client
for their own manual tests.

The town-patrol and military-administration choices above supersede the earlier
pending questions. Their isolated implementations are recorded in the backlog;
campaign acceptance remains open.


14 November interception clarification: routes include towns and permanent sites.
Spawn the entire interception horde together. The developer may choose and tune
its size and use a separate temporary allowance even when the shared infected
limit is full. This differs from the gradual arrivals approved for strategic
major attacks; neither policy changes the other.

Interception arrival clarification: first arrival still fails the task, and
surviving infected reinforce an infected-held destination or attack its defenders.
A Russian takeover during the march does not cancel the assignment; the horde
continues toward the destination. Territory does not transfer merely on first
entry: reinforcement/combat aftermath must remain distinct from task failure.


14 November Russian convoy clarification: keep Russia's automatic supply convoys
as background military activity, without offering missions against Russian
forces. The requested catalog remains infected-only; do not disable the Russian
convoy activity to achieve that UI policy.


14 November interception reinforcement clarification: surviving arrivals add
extra defenders even when the destination's normal garrison or town population
is full. If a town is not active, remember those extra infected for its next
visit. This supersedes the previously pending capacity/offscreen-town questions.
The owner also confirmed that killed extra town reinforcements stay dead.
Normal town population still follows the approved per-visit regeneration policy.


14 November administration reinforcement clarification: normal stronghold
defenders still regenerate each visit. Extra infected arriving as reinforcements
persist between visits; killed extras stay dead, just as extra town defenders do.

14 November delivery clarification: Extraction success requires at least one
survivor rescued; rewards scale with rescues. Preserve
Ultimate's HQ delivery distances: 100 metres for Supplies Seizure trucks and
50 metres for Extraction survivors. Rebel-held bases, outposts, airfields,
factories, resource sites and seaports use their marked boundaries. Towns,
road controls and cleared administration strongholds are not delivery sites.

Extraction settlement correction: the first rescue does NOT finish the mission.
Keep it active until every survivor has been rescued or killed, or until its
original deadline. If any survivor remains unresolved, including in infected
territory, the assignment persists until that deadline. At settlement, succeed
if at least one survivor was rescued; fail if zero were rescued. This supersedes
the earlier immediate-completion interpretation and the proposed post-completion
reward window.

14 November administration arrival boundary: for Horde Interception, the first
living infected within 50 metres of the stronghold counts as arrival and fails
the task. Ordinary town/permanent-area marker boundaries remain unchanged.

14 November cleared-administration aftermath: if the player clears a stronghold
while an interception horde approaches, the horde still attacks the area. The
stronghold stays permanently cleared and cannot be reestablished by that horde.

14 November Supplies Seizure ownership clarification: once the truck exists,
continue recovering that same truck if Rebels or Russia capture its settlement.
Ownership change alone does not cancel the mission; delivery, destruction or
the original deadline determine its outcome.

15 November Supplies Seizure source policy: towns can contain fuel trucks only;
permanent sites can contain any of the approved ammunition, fuel and repair
trucks. If the truck's permanent source site becomes Rebel-held while the truck
is still inside its boundary, complete recovery there. Driving to a different
friendly site is not required.

15 November Extraction sources and group size: use infected-held towns, military
bases, outposts and airfields, preserving Ultimate's usual source categories.
Place 2-6 stranded survivors, choosing a number that fits the available shelter.
Factories, resource sites, seaports, road controls and administration strongholds
are not sources for these requested missions. This does not change the broader
approved delivery destinations.

15 November Humanitarian Aid: retain Ultimate's unloading phase (180 seconds
normal, 90 difficult), with no infected within 50 metres. If Rebels or Russian
forces capture the destination before completion, cancel without a penalty.

15 November Elimination initial roster: the owner approved Screamer, Boomer and
Leaper 2 while the larger creatures' observed model/lifecycle errors are investigated.
This approval does not certify those three for full campaign gameplay; target
tracking, spawn policy, missions and connected combat acceptance remain required.

15 November Elimination locations and escorts: use infected-held towns and
permanent sites, and add a group accompanying the special target. The owner amended the proposed basic-only escort to include both basic and
minor special infected; use the approved initial special roster and tune the mix
within the shared limit.

15 November Elimination identification: mark a search area and name the target
type. Escort special infected must use types other than the primary target.
The marked area is the reported spawn area; it does not track the creature.
15 November Humanitarian Aid defenders: use the town's existing infected
population. The mission does not launch an additional walking horde.

15 November abandoned vehicles: follow Ultimate's default regeneration and
persistence rules. The abandoned civilian/police/light military mix appears only
in infected-held towns, and taking it is free salvage without a civilian-theft
penalty. These decisions do not change ordinary vehicles in other towns.
The owner approved keeping native parked-vehicle counts and developer tuning
of the civilian/police/light military mix, fuel and repairable damage.


15 November Extraction disposition: delivered survivors become manpower and leave
the map, following Ultimate. At the deadline follow Ultimate's removal of all
undelivered survivors, including those still travelling with the player. Keep
the native one-minute cleanup delay. The owner also approved a small additional
infected guard group near the survivors; use the existing four-member basic
police-team definition under the shared infected budget.

15 November follow-up campaign routes: destroyed radio towers in infected
territory stay destroyed; remove the conventional repair-crew mission. Keep the
separate gang storyline and gang assaults. The arms dealer unlocks without an
introduction mission, at Ultimate's normal intel/progression timing rather than
at campaign start. These choices do not disable native trader services.

15 November gang-cell scene: retain Ultimate's staged casualties. Its native
assault mission may kill approximately 75 percent of nearby outdoor, on-foot
Occupant units after the scene starts, including infected. Do not suppress this
effect; the owner explicitly chose the native behavior.

15 November Rivals narrative: initially unknown to the Rebels, who expected
Chernarus Redux to be largely barren of healthy life. The Rivals distrust
governments and wish to preserve the anarchic conditions created by infection.
Their discovery is a surprise. Retain the native discovery timing, gang
storyline, attacks and staged casualties.
