# Elimination Task adaptation audit

Status: source audit only; the replacement mission and special-target adapter
are not implemented. This does not approve any creature for production use.

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

## Owner clarification and next evidence

The owner confirmed that a Rebel or Russian takeover while the special remains
alive must leave the hunt active. Once the target exists, settlement ownership
alone cannot resolve the task. Eligibility before target creation remains a
separate concern from the existing target's death ledger.

The standalone special lifecycle diagnostic is documented in
SPECIAL_LIFECYCLE.md. Its close-passive case addresses native Corrupted possession,
where deletion of the original actor can represent a continuing threat in a new
host. No production mission or special selection is enabled by that diagnostic.
