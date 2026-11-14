# Horde Interception source audit

Status: approved requirements and source findings only. No interception controller
or route selector is implemented or runtime-tested in this increment.

## Approved objective

A large group of infected moves from Settlement A to Settlement B. Intercept and
neutralize the horde. Fail when the first infected enters B. Origins are infected;
destinations may be infected-held or Rebel-held. Towns and permanent sites may
serve as endpoints. Spawn the entire horde together with a separate temporary
allowance. The owner permits developer-selected and tuned sizes and use of
Ultimate's timers/rewards as an adaptable baseline.

## Pinned Ultimate 12.4.2 findings

- missionRequest selects destinations near HQ, calls findBasesForConvoy, then
  schedules CONVOY with destination first and origin second. Its current source
  and ownership filters cannot express the new approved endpoint policy.
- selectIntel also schedules CONVOY, supplying legacy resource pool and visible
  task arguments. Replacing only the mission board would miss this caller.
- chooseAttack schedules a Supplies convoy with the attack resource pool. The
  existing infected strategic attack adapter already replaces that planning
  path with walking major hordes. Do not turn Russian strategic attacks into
  player-requested interception tasks.
- CONVOY owns a global convoy lock, registers a native task, stages objective
  vehicles and escorts, delays departure, and starts a one-hour travel timeout.
  It tests vehicle proximity within 100 metres of the selected nav point. This
  is not the approved first-infected-entry objective.
- Its default departure delay is random 0-5 plus 10 minutes (normal) or 5 minutes
  (difficult), despite an inconsistent nearby source comment. A walking horde
  needs a documented departure/travel policy and matching player briefing.
- Native arrival, loss, vehicle capture, prisoner rescue and destruction settle
  different rewards and world effects. Those branches cannot be retained merely
  by changing the title. Whole-horde elimination needs explicit death tracking;
  missing/deleted actors must not count as kills.
- Existing roaming/tactical routing checks bounded land connectivity and safe
  outdoor positions. These checks do not prove travel across Redux terrain.
- The budget already separates finite town populations from shared actors and
  forbids transfers that borrow their allowance. A temporary interception domain
  must be distinct from site records, bounded, owned by a live mission, and
  retired after pending reservations and living actors are handled.

## Implementation constraints and remaining design

Use server-owned exclusive task claims, matching scheduler/direct-call guards,
ordinary-campaign delegation and modern/legacy menu hooks. Revalidate endpoints
at launch; reject overlapping endpoints that could spawn actors already inside
B. All spawned members must be ready before the march starts. Placement failure,
partial construction and interrupted workers require bounded cleanup without
silently shrinking the assigned horde. A death ledger must distinguish killed
actors from deleted actors and uncreated entries.

The arrival rule must use the destination boundary rather than treating all
permanent sites as circles with the same arbitrary radius. Test first entry,
simultaneous last death/entry, an actor disappearing, paused/stopped controllers,
full shared usage, allowance isolation, ordinary delegation and cleanup.

The owner approved arrival aftermath: survivors reinforce an infected-held
destination or attack its defenders. Russian capture during travel does not
cancel the assignment. First arrival fails the task, but does not itself grant
territory: combat capture remains separate. Aftermath ownership, separate-budget
retirement and reinforcement transfer therefore need their own lifecycle checks. Visual tasks, client visibility, actual terrain travel and performance
remain separate acceptance work.
