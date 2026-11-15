# Elimination target tracking

The owner approved Screamer, Boomer and Leaper 2 as the initial Elimination Task
roster on 15 November 2026. The approved prepared class names are:

- `Zombie_Special_BLUFOR_Screamer`
- `Zombie_Special_BLUFOR_Boomer`
- `Zombie_Special_BLUFOR_Leaper_2`

The separate [special lifecycle diagnostic](https://github.com/connordwalsh/A3UExtender-Infection/pull/36)
observed rifle-combat deaths for these three without the model/attachment errors
recorded for several larger creatures. That diagnostic remains failed overall;
it is not gameplay acceptance for this roster. Corrupted can delete its living
original body while possessing a victim. Boomer instead records a real death
before its native corpse deletion. Consequently, disappearance alone cannot
satisfy an Elimination objective.

## Internal ledger increment

The five new functions expose the explicitly approved, config-validated roster
and track one exact registered target per named ledger. They create no actors,
public tasks or rewards. Registration requires Infection, server-local execution,
a living server-owned WEST actor of an approved class, a future deadline and no
existing actor/record ownership. Unique serials protect reused names and actors.

Mission-level EntityKilled and EntityDeleted handlers observe the registered
actor. A recorded death before the deadline becomes `neutralized`, even if the
corpse is subsequently deleted. A death after the deadline fails. Unexplained
live deletion or ownership reassignment becomes `interrupted`; it never grants
kill credit. The eventual controller must distinguish this technical interruption
from an ordinary combat failure. No public settlement policy is installed here.

An independent one-second monitor handles deadlines if the eventual mission
worker stops. A settlement ownership change does not stop the hunt, as approved
by the owner. Terminal results freeze. Releasing a ledger removes only its own
registration; it preserves living actors and foreign ownership. Shared event
handlers remain until the final record is released.

## Evidence boundary

The authored isolated fixture covers all three real prepared classes, actual
Killed/Deleted events, late death, deadline failure, foreign ownership, concurrent
records, stale serials, location capture and native Boomer self-destruction/corpse
removal. Forced damage checks prove event tracking, not normal weapon balance.

Packaging and parser checks are separate from runtime results. The focused
engine suite is pending the running Humanitarian Aid regression's use of the
shared isolated Template profile. No manual installation changes or Computer
Use. Public target selection, safe spawning, tasks, rewards, menus, connected
combat, saves and full campaign acceptance remain open.
