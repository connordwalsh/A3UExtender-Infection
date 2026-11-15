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

Dev4 adds the fifth legacy rescue route, RES_Informer, and adapts the pinned
civilian conversation endpoint. Conversation success/mission probabilities,
undercover and already-spoken checks, intel responses and zone reveals retain
the native structure. Rescue location choices are restricted to eligible
Extraction locations near both HQ and the civilian. The local scheduled worker
reports success only after the public task is registered. It does not acquire or
clear the native civilian mission flag; foreign native flags remain respected,
and the atomic Extraction registry prevents duplicate jobs. Client-origin dialog
requests must identify their own player. The delayed zone-reveal response now
carries its caller explicitly rather than relying on an expired local variable.

The Dev4 combined Extraction regression is running; its additional checks cover
the informer route directly and through server scheduling, native delegation,
civilian reservation/retirement, invalid targets and already-spoken civilians.
These are server contracts, not connected-player conversation acceptance.

Dev4 completed: 150 combined Extraction checks, eleven missing-dependency checks
and three parser tests pass. No recorded engine/SQF errors; 26/7 reviewed warnings
remain (dependency animation/config notices, native final-function notices,
object-removal traffic and null-player notification targets in the AI-only
fixture). All 287 production inputs and the PBO match the retained manifest.
Both completed Extraction servers were stopped after collection. The separate
full survivor-defense regression remains running in its unchanged worktree.
Connected-player conversation, remote ownership, release UI, HC/JIP and campaign
saves remain unverified.

A subsequent inventory cross-check found the sixth registered rescue endpoint,
RES_Shipwreck. Although the replaced commander request no longer calls it, its
direct endpoint could still create a conventional naval task. RescueRoutes Dev1
routes it through Extraction and pins server scheduling. Eligible land sources
create the normal survivor mission; seaports are refused, preserving the owner's
approved town/base/outpost/airfield list. Ordinary campaigns use the native
alias. All six rescue endpoints pass direct/scheduled/native-delegation checks;
the focused dispatch suite passes 43 checks, with no engine/SQF errors and sixteen
baseline warnings. All 288 production inputs and the PBO match. This increment
is separate from the still-running Dev4 full regression.
