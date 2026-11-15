# Interception arrival implementation

Status: town storage/spawn support passes 88 focused engine checks; combined
regression is running on the same immutable candidate.
The marching-horde handoff, hostile-destination attack and public dispatch remain
unfinished. No campaign, save-file or connected-client acceptance is claimed.

## Approved policy

Surviving arrivals add defenders above the normal destination garrison or town
population. Offscreen town arrivals are remembered for the next visit. Killed
extra town defenders stay dead; the normal logistic population regenerates.
First entry still fails Interception, and Russian takeover does not cancel travel.

## Native storage and town spawning

Use the native saved garrison list for persistent town additions. Normal town
population continues to come from cityRoster and the approved logistic function.
cityExtraRoster selects only registered Infection roles, leaving unrelated saved
entries untouched. The queues are separate: baseline actors retain legacy
per-visit accounting, while extras use native garrison casualty accounting.

The town allowance is baselineTarget (at most 200) plus extraTarget. The existing
shared infected limit cannot displace either population. This is explicit extra
reinforcement capacity, not a change to the logistic curve or generic horde size.
Both queues must finish, and extras must be killed, before Liquidation can certify
clearance. Normal town political capture behavior is not replaced by this predicate.

Pinned Ultimate 12.4.2 source evidence:
- `init/fn_initZones.sqf` appends citiesX to markersX.
- `Save/fn_saveLoop.sqf` saves garrison lists for markersX except controls and
  player-built posts; towns are included.
- `Save/fn_loadStat.sqf` restores saved role names through the current faction
  loadout registry.
- `init/fn_initGarrisons.sqf` initializes native enemy permanent-site garrisons,
  not a normal town infantry roster.
- Native markerChange and Infection liquidationCityCapture clear the old
  garrison when ownership transfers.

The new fixture creates 203 living actors for a 200-base town with three extras,
kills one ordinary actor and one extra, despawns the town, uses the real native
garrison loader, then revisits. It expects 200 baseline actors and only two extras.
It also checks unrelated saved-entry preservation and clearance obligations.
All 88 town checks pass, including the ten new reinforcement cases, without
engine/SQF errors. The actual missing-dependency run passes all 11 checks. Three
collector parser tests also pass. The loader case does not claim a complete
disk-save/load or campaign test.

Artifact: `@Infection_TownExtras_Dev1`, 160 production inputs, SHA-256
`d426c9971337acce8159542c7055817a935674a7fa4ddb0b0653ac3666853a22`.
Reports: `town-extras-engine.json`, `town-extras-dependencies.json` and
`town-extras-build.json` under `evidence/sprint-4`. The corrected native-task
retention fixture from the controller branch is included in the combined run.
Do not treat the earlier 955-check rejected report as a pass.

## Remaining handoff work

Arriving groups currently retain their interception ownership. They must add
persistent roles exactly once, preserve living actors near players, and transfer
budget/control responsibility without releasing capacity early or deleting
adopted defenders during old-horde cleanup. Persistent sites retain their queued
normal-garrison behavior on later visits. A live adopted horde must keep its
separate temporary allowance until its physical actors retire. Hostile arrivals
must fight/capture under the approved campaign rules, not flip territory merely
because the task failed. These paths are not implemented by town storage support.
