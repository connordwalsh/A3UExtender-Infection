# Interception arrival implementation

Status: town storage/spawn support passes 88 focused checks and the complete
965-check combined engine regression on the same immutable candidate.
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
retention fixture from the controller branch is included in the passing combined
run, recorded in `town-extras-combined.json`. All 160 inputs and the PBO still
match the manifest. The combined run has 81 reviewed warnings: 16 startup or
dependency notices, 60 object-deletion notices and five notifications with no
fixture commander. There are no engine/SQF errors. Do not treat the earlier
955-check rejected report as a pass. The completed combined server exited.

## Remaining handoff work

Arriving groups currently retain their interception ownership. They must add
persistent roles exactly once, preserve living actors near players, and transfer
budget/control responsibility without releasing capacity early or deleting
adopted defenders during old-horde cleanup. Persistent sites retain their queued
normal-garrison behavior on later visits. A live adopted horde must keep its
separate temporary allowance until its physical actors retire. Hostile arrivals
must fight/capture under the approved campaign rules, not flip territory merely
because the task failed. These paths are not implemented by town storage support.


## Offscreen arrival transaction (focused validation passed)

`storeInterceptionArrivals` accepts one fully arrived group from the exact settled
interception owner. It requires an infected-owned town or ordinary permanent
site, no live site controller, all survivors inside the actual destination marker,
valid registered roles, a closed dedicated ticket containing exactly that living
group, and no nearby observers. A busy native garrison defers the transaction.
It appends survivor roles without applying the normal garrison capacity, changes
the actors to native garrison accounting, marks the handoff before deletion, and
releases only their ticket. Native corpses retain their lifetime. Retrying cannot
append the same survivors again.

The transaction is an internal helper; public mission dispatch and the arrival
owner do not call it yet. Active-site adoption and administration strongholds
remain separate work. Administration creators use a separate regenerated roster,
so the helper refuses those locations rather than saving ignored defenders.

The focused fixture uses real prepared infected, native initialization and budget
bindings. It tests stale/foreign claims, busy/active/hostile destinations, observers,
invalid roles and tickets, above-capacity permanent-site additions, a dead member
excluded from saved town additions, corpse retention, resource neutrality and
cleanup. No physical walking, campaign save-file or connected-player acceptance
is implied by placing fixture actors at the destination. All 34 focused engine checks pass, without engine/SQF errors. Packaging and
three parser tests pass. The actual missing-dependency run passes all eleven
checks without engine/SQF errors. The focused run has 16 reviewed startup or
dependency warnings. All 161 production inputs and the PBO match the manifest.
Both isolated test servers exited. Full combined regression of this additional
helper is NOT_RUN; the parent candidate passed its 965 combined checks.

Artifact: `@Infection_OffscreenArrivals_Dev1`, SHA-256
`8dcac9e5c0acee52959d3bc0e17ae7f561714ebf1df683df3148f1cbf5078a51`.
Reports: `interception-storage-build.json`, `interception-storage-engine.json`
and `interception-storage-dependencies.json` under `evidence/sprint-4`.


## Active-site adoption design review (not implemented)

The existing paid reinforcement helper cannot be reused unchanged: it enforces
native spare capacity and only transfers shared tickets. Interception groups
already own dedicated capacity, and the approved arrivals may exceed the native
garrison size. Weakening the ordinary helper would also change routine paid
reinforcements, so that path must retain its current limits.

A live handoff must update saved roles, clearance obligations, site membership
and budget ownership in one unscheduled transaction. The original horde must
lose ownership of the transferred actors before its retirement can delete them.
For towns, existing dedicated ticket ceilings must grow with extraTarget and
populationTarget; the original spawn queues must not spawn the adopted actors a
second time. For permanent sites, transferred living groups need a dedicated
arrival context that cannot reserve new actors or suppress the site's ordinary
shared queue. Site cleanup can then delete those owned actors and release their
closed tickets, while healthy saved roles remain for later visits.

Review/test obligations: adoption during a partially filled queue; a full shared
limit; two simultaneous arrival groups; native garrison mutex contention; owner
or site replacement; death during a scheduled retry; old horde cleanup after
transfer; site despawn after transfer; repeated adoption; and clearance after
all original and extra defenders are defeated. Hostile destinations must remain
under native combat/capture rules until ownership actually changes. First-entry
task failure alone never authorizes a territory transfer.


## Active town and permanent-site adoption (focused validation passed)

`adoptInterceptionArrivals` validates the exact horde owner, full living group,
closed dedicated ticket, destination ownership and running site controller.
It appends native garrison roles and clearance obligations atomically, transfers
budget responsibility and removes live actors/groups from their old horde owner.
Native combat AI and the physical actors remain. Administration sites are not yet
supported by this helper.

A town expands populationTarget and extraTarget, including existing reservation
ceilings, while preserving its original queue. Permanent-site arrivals receive
closed `arrival:` contexts that cannot reserve new actors; the normal shared
queue continues independently. Site cleanup owns both kinds of adopted actors.
Ordinary paid reinforcements keep their existing capacity limit. A second handoff
cannot duplicate an already adopted group.

LiveArrivals Dev1 passes all 59 combined offscreen/adoption focused engine checks,
11 actual missing-dependency checks and three parser tests, without engine/SQF
errors. All 162 production inputs and the PBO match the manifest. The immutable
artifact SHA-256 is `b961d085a231a1491fd3cf5060e8f6aed0c3cfffc5505c49079f1f78fd293e7c`.
Reports are `interception-adoption-build.json`, `interception-adoption-engine.json`
and `interception-adoption-dependencies.json` under `evidence/sprint-4`.
The focused run has 17 reviewed warnings (16 startup/dependency and one object-
deletion notice); the absent run has seven startup warnings. Both servers exited.
Full combined regression is the next gate for this budget change. Public calling
paths, hostile aftermath and administration reinforcements remain unfinished.

The owner confirmed administration extras should also persist between visits and
stay dead when killed. Their ordinary per-visit defenders still regenerate.
