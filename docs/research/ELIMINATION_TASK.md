# Elimination Task adaptation audit

Status: historical source audit below, followed by the current controller
implementation checkpoint. Focused engine validation is in progress; this is
not campaign or connected-player acceptance.

The approved objective is one powerful special infected in a settlement:
"A powerful special zombie has been reported in {Settlement}. Find it and
neutralize it." Requested combat missions target infected exclusively.

Inspected Ultimate 12.4.2 commit c7c8247672ed5e7d4aa317d47efb371c41de4e7d,
using the local pinned checkout. Source paths below are relative to that checkout.

## Native behavior that cannot be reused unchanged

- `A3A/addons/core/functions/Missions/fn_AS_Smasher.sqf` requires the civilian
  faction to be non-human, creates its boss on the Invader side, and uses
  hard-coded OPFOR Smasher/Goliath classes. Infection's occupants are WEST;
  civilian faction selection must not gate the replacement.
- Its difficult branch selects an Occupant attack/light-attack helicopter.
  Infection deliberately has no conventional aircraft pools. The normal branch
  creates four Occupant special-forces groups to fight the boss. Neither is
  part of the approved one-special-infected objective.
- Native success uses `!alive _mutant`, which includes deleted/null actors.
  The replacement must observe a genuine death before treating native cleanup
  or a disappearing special as a kill. Special behaviors may delete their actors,
  so event timing must be verified against the selected class.
- Its pre-activation timeout returns immediately after task failure, before
  reaching the final task-deletion schedule. The normal branch also reaches
  cleanup with `_heliGroup` declared only inside the difficult branch. A new
  server-owned lifecycle must cover timeout and interruption independently.
- `fn_AS_Zombies.sqf` is a wave-defense mission for Rebel towns, gated by
  non-human civilians. Failure destroys the town and transfers it to Invaders.
  Renaming this mission would not implement the requested elimination objective.
- `fn_missionRequest.sqf` selects Official, Ambush, Traitor, Smasher, Zombies and
  rival-traitor routes. Replace selection and direct entry points together;
  changing Smasher alone would still offer human/gang targets.

## Creature validation needed before implementation acceptance

The existing controlled behavior report completed 112 trials but retains seven
failed special death/locality assertions. They did not distinguish deleted
objects from locality changes. Corrupted, Smasher, Acid Smasher, Hellbeast and
Goliath produced model/skeleton/attachment errors. See BEHAVIOR_12.4.2.md and
`evidence/sprint-0/behavior-12.4.2.json`; these are unresolved evidence, not approved
specials. Extend those checks with isNull and real Killed/Deleted evidence before
claiming compatibility for a special target.

The generic managed-unit predicate intentionally accepts only basic prepared
classes. Implement a separate, explicit special mission adapter after validating
its native lifecycle; do not broaden every garrison, patrol and horde to include
special creatures. Largest enemies remain confined to approved special missions
or high-war-level military-base QRFs.

Native Smasher timing/rewards provide the authorized starting point (normal
60 minutes, difficult 30; different faction/support/player rewards). Final target
selection, mission-specific timing, defeat/cancellation and cleanup behavior
still require implementation and evidence. No new product policy is selected by
this audit. No Computer Use or manual installation change.

## Controller checkpoint: 15 November 2026

The owner approved Screamer, Boomer and Leaper 2 as initial targets; their
separate ledger and scene prerequisites are merged. The controller branch now
registers actor ownership, the death ledger, a static search ellipse and an AS
task inside the factory creation transaction. The task names the primary type;
minor-special escorts exclude it. Basic escorts and other approved minor types
use the shared active-infected limit (6-11 total actors depending on war level).

Only an observed primary death by the deadline succeeds. Escort deaths do not
complete the objective; settlement capture does not cancel it. Live deletion or
reassignment is a technical cancellation without rewards. Normal/difficult
limits are 60/30 minutes. Success adapts native AS_Zombies rewards: 1000/2000
faction funds, 10/20 local support, 10/20 player score and 250/500 player money.
Timeout fails without the old wave-defense mission's unrelated city destruction.

Seven native assassination entry points, server scheduler routing, commander
requests, and both menu labels use the replacement only during Infection. Other
campaigns delegate to their original functions. An independent watchdog settles
once, releases the exact ledger and marker, retains nearby actors/corpses,
preserves reassigned actors, and retires empty groups. Task retention follows
Ultimate's 1200-second average.

EliminationTask Dev1 is built; validation remains pending. The initial fixture
report is retained as rejected: missing native faction/commander setup and an
unparenthesized town-data lookup interrupted it. A second rejected fixture used
a string comparison on the task description's formatting array. The installed
functions_f.pbo source confirms BIS_fnc_setTask wraps each description field in
an array; the corrected assertion formats that field. Neither correction changes
production source. Public dispatch, actual absent dependencies, cleanup, combined
regression and connected gameplay remain to be verified. No Computer Use or
manual-install changes.

Dev1's corrected lifecycle run passes 36 checks and the public-dispatch suite
passes 38 with no engine/SQF errors. An earlier completed run remains rejected:
its reward assertion counted native per-death support calls as mission rewards,
and its high-war scene was unavailable (the fixture did not retain the reason).
The corrected reward assertion compares the callback list before and after a
repeat settlement. Later checks carry explicit phase, fault, count and outcome
details. That historical placement failure is not claimed conclusively diagnosed.

Dev2 reserves a margin around the primary spawn for its escort circle, avoiding
repeated boundary rejection when the primary lies at the site's edge. It also
preserves an actor that another elimination ledger has claimed, even when the
older task tag remains. Added checks exercise eleven-actor groups with each of
the three target classes and transfer the primary to an actual second ledger.
Validation of Dev2 and integration with Humanitarian Aid are in progress.

Dev2 passes all 40 focused lifecycle checks, including actual eleven-actor
Screamer, Boomer and Leaper 2 groups and protection of a primary reassigned to a
second ledger. All 11 actual missing-dependency checks and three parser tests
pass. No engine/SQF errors. Its 18 reviewed notices comprise 16 startup baseline
notices and two native resource-notification calls to the fixture's null
commander; client notifications/rewards are not certified. All 236 production
inputs and the PBO match the manifest. Both completed Dev2 test servers exited.
SHA-256: ca5fa6c4bdf3586cb43f36c65846343b19d9a6b7d6ca1a8e4c319593e98ffa4b.
Combined regression and connected acceptance remain open.


## Integrated Dev3 regression checkpoint, 15 November

Dev3 combines public Elimination with the Aid controller and corrected Aid-ledger
fixture. All 254 production inputs and the PBO match the frozen manifest; SHA-256
9563500a216a240540f138daafe98c8fed257b102d47b5e6a2ab21b37d6b06ef.
Its 11 actual dependency-absence checks pass. The first full run stopped before
completion: every recorded assertion passed and no engine/SQF error was recorded,
but this is incomplete evidence, not a passing regression. The interruption report
and Dev2/Dev3 manifests are retained separately. A fresh run of unchanged Dev3 is
in progress; public integration and the enclosing story remain unaccepted.


## Accepted combined code regression, 15 November 2026

The unchanged integrated EliminationTask Dev3 rerun passes all 1,427 checks and
67 role-spawn records. All 254 production inputs and the PBO still match its
manifest (SHA-256 9563500a216a240540f138daafe98c8fed257b102d47b5e6a2ab21b37d6b06ef).
Its actual dependency-absence run passes eleven checks. No engine/SQF errors;
96 reviewed notices comprise 16 startup, 70 object-deletion and ten null-fixture-
commander notifications. The completed server was stopped. The earlier
interrupted run and rejected Aid fixture reports remain preserved.

This accepts the combined code regression containing public Aid and Elimination,
not a standalone passing Aid Dev4 full run or campaign acceptance. Connected
players, visible menus/rewards, real-terrain mission behavior, HC/JIP, saves and
performance remain open. No sprint gate or manual Dev9 installation changed.
