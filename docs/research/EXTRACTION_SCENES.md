# Extraction sources and survivor scenes

The owner approved infected-held towns, military bases, outposts and airfields,
with 2-6 survivors fitted to the available shelter. Other permanent locations
remain approved delivery destinations but are not requested Extraction sources.

The source filter uses actual, valid marked areas and current ownership. Nearby
selection uses Ultimate's native mission-distance check. A bounded search considers
up to 32 real houses and 64 native positions per house, respects the building
blacklist, and checks floors, headroom, walls, occupants, observer distance and
visibility through Infection's existing human-captive placement predicate.
Positions must remain inside the source and at least 1.5 metres apart. There is
no unsafe center fallback or single-survivor mission scene.

The internal factory chooses 2-6 survivors, rechecks source ownership and all
positions immediately before creation, and uses the selected Rebel unarmed role
through Ultimate's native creator and redressing. Survivors are vulnerable human
members of the Rebel side, captive and waiting as native refugees do. The factory
creates no task, rescue action, rewards or automatic despawner; the future mission
controller must register the returned actors with the accepted Extraction ledger
and own their cleanup. Partial creation rolls back its own actors and group.

Pinned source: Ultimate 12.4.2 c7c8247672ed5e7d4aa317d47efb371c41de4e7d,
Missions/fn_missionRequest.sqf, fn_RES_Refugees.sqf, fn_RES_Prisoners.sqf and
fn_RES_Deserters.sqf; AI/fn_liberaterefugee.sqf; Base/fn_flagaction.sqf.
The native refugee search can exhaust an empty house pool; native prisoner and
deserter fallbacks can place units outdoors. This scene increment requires a
checked shelter instead. The native release action transfers group locality to
the player, which the ledger anticipates but connected tests must still verify.

Status: implementation and 24 focused engine scenarios prepared; focused scene
validation NOT RUN. Packaging, three parser tests and eleven actual
missing-dependency checks pass without engine/SQF errors. The 188 production
inputs and Dev1 PBO match after the dependency run; that server exited. Public mission creation, release actions, rewards,
post-rescue disposition and cleanup remain open. The owner question about
manpower versus usable AI remains pending. No Computer Use or manual-install
changes; no sprint acceptance gate is closed.
