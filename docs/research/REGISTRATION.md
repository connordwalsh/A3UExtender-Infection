# Infection registration prototype

Implemented against Ultimate 12.4.1, pinned source
`ea8bcf9f05d6b0d4642179db845d7d3425ceab0d`. The addon prefix is
`x\a3i\addons\core`; the patch is `A3I_core`. This is a development build, not
an accepted campaign release.

## Implemented contract

* `A3I_Infected` extends `Vanilla_Base` as an Occupant template. Its negative
  selection priority avoids replacing the normal default faction. Required
  template patches are `WBK_ZombieCreatures` and `WebKnight_StarWars_MoveSet`.
* The addon itself depends on Ultimate and CBA, so it can load without WebKnight.
  Dependency inspection checks the required patches and the three basic classes'
  existence, public scope and WEST config side. Missing dependencies keep the
  activation guard false and produce an explicit diagnostic.
* Police, militia and miscellaneous roles use `Zombie_B_Walker_Civ`; military
  roles use `Zombie_B_Shambler_Civ`; elite/SF roles use `Zombie_B_RA_Civ`.
  The 67 role definitions cover Ultimate's generated role references. The
  `baseClass` trait preserves the prepared class's own equipment/init. No medic,
  engineer or weapon trait is added, and no special/boss is in these pools.
* Red flag/marker and vanilla loot/equipment crates resolve in the engine.
  Faces, silent voice and names are supplied. WebKnight may subsequently change
  a prepared unit's face; the test records the observed face without overriding
  that behavior.
* ACE and ACE Medical patch presence is detected only. No ACE-specific gameplay
  adaptation or authentic faction-pack support is claimed.

## Vehicle contract boundary

All conventional ground, air, naval, UAV, static, militia and police vehicle
arrays are explicitly empty. Radar/SAM and artillery magazine scalar fields are
empty strings; the artillery magazine map is empty. Ultimate's loader derives
empty armor and armed-transport pools successfully. EnemyDefaults' noncombat
scenery, medical item and insignia defaults remain inherited.

This is **not** a tested bypass of campaign callers. Sites, garrison preferences,
supports, convoys and missions can still ask those empty pools for vehicles or
crew. Their guard/replacement work is tracked in the impact matrix. The current
build must not be described as a usable Infection campaign.

## Evidence

* `evidence/sprint-1/registration-build.json` records addon/source hashes.
* `dependencies-absent.json`: ten isolated dedicated checks passed with CBA and
  Ultimate but neither WebKnight patch loaded. The template's dependency gate
  and activation guard rejected the missing dependencies.
* `template-contract.json`: all 83 isolated checks passed, with 67 sequential
  unit creations through the real Ultimate loader and `A3A_fnc_createUnit`,
  generated-group references resolved, and no remaining test entities/groups.
  This did not call `NATOinit` or start a campaign.
* The first full run failed a harness assertion: the case-folded `vehicles`
  prefix also matched scalar `vehicleSam`. Its valid empty string is now accepted
  alongside empty arrays. The repeat completed on 12 November at 19:46:46 EST,
  before the requested halt; final evidence was collected on 13 November.
* Ten startup warnings are retained for review, including IMS/WebKnight animation
  warnings and the `a3_characters_f` deleted-content warning. The same warnings
  occur in the probe without Infection. Runtime inspection confirmed that
  `A3_Characters_F` exists and supplies the observer class. The warning's root
  cause is unresolved; passing assertions are not a claim of warning-free startup.

Not covered: setup UI acceptance, campaign sites, damage/kill accounting,
headless transfer, multiplayer/JIP, progression, persistence, or performance.
