# Extraction task controller

Owner decisions: infected-held towns, bases, outposts and airfields; 2-6 sheltered
survivors; an additional small infected guard group; delivery to HQ within 50 m
or six approved Rebel-held permanent-site boundaries. Delivered survivors become
manpower and leave the map. All unresolved survivors must be rescued or killed,
or the deadline reached. At least one rescued survivor means success. Follow
native removal of undelivered survivors, including squad members, after settlement.

The controller uses the existing four-member basic police-team template and
shared infected budget. It registers human and guard references atomically during
creation. Failure to place the complete scene creates no public task. Active
objectives use the existing exact-actor ledger and guarded release interaction.
Ownership changes after creation do not erase the rescue objective.

Manpower uses native ceil(rescued * (2-overallHRGain/100)), credited incrementally
without repeated rounding per person. Delivered equipment returns to the HQ box
using native refugee weapon/magazine/item recovery. Final success grants native
100 currency per survivor with the normal/difficult multiplier, player score/money
and commander rewards. Native 60/30-minute difficulty limits, aggression response,
one-minute survivor cleanup and randomized task retention are retained. Cleanup
never deletes the player's group. Unrelated actor owners are preserved.

Dev1 passes 37 focused engine checks, eleven dependency-absence checks and three
parser tests. No engine/SQF errors. All 276 production sources and the packaged
PBO match the manifest. The first rejected run checked two task registry states
before native taskSetState's remoteExecCall update arrived. The corrected fixture
observed CREATED immediately, then SUCCEEDED/FAILED within a bounded wait; the
production build stayed unchanged. The rejected report remains retained.

The isolated test uses actual tasks, human creation, four managed guards, the
native resource transaction, inventory recovery and accelerated deadlines/cleanup.
No connected players, visible menus, real travel, HC/JIP, disk saves, campaign
acceptance or full combined regression are certified. Public dispatch is the next
increment. No Computer Use or manual Dev9 changes.


Dev2 connects four legacy rescue routes, server scheduling, the public RES request
and both menu labels; 31 focused dispatch checks pass. Dev3 adds successor-ledger
ownership protection and checks missing-arsenal recovery, scene registration
rollback and cumulative manpower. Its 141-check combined Extraction suite and
eleven actual missing-dependency checks pass, with no engine/SQF errors. All 283
production inputs/PBO match. The first Dev3 run is rejected: it sampled survivor
deletion immediately after task retirement. The bounded rerun recorded not-null
then null, with the player group and Petros intact. The rejected report is kept.

Caller audit found a fifth route, RES_Informer, and the native civilian-conversation
mission flag. Those still require integration before the rescue caller surface
is complete. Full combined regression and connected-player acceptance remain open.
