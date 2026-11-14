# Horde Interception source audit

Status: route selection and separate-budget foundation drafted on the feature
branch. Its focused engine suite passes 78 checks; town regression is running. The task controller, full formation
staging, march, arrival aftermath, settlement and public dispatch remain incomplete.

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


## Foundation candidate

Interception Dev1 adds a town/permanent-site endpoint list and bounded scheduled
route planning. Destination ownership is restricted to infected/Rebels at initial
selection; this selector is not reapplied during the approved continued march
through a Russian takeover. HQ, controls and malformed/absent boundaries are
excluded. The existing major-source checks exclude active, forced, cooling-down,
recently damaged or player-observed origins. Native HQ mission range is retained.
The route checks up to 64 nearby pairs, a 2 km straight-line limit and a 2.5 km
road limit, safe outdoor endpoint positions and non-overlapping spawn/destination
bounds. Pinned Redux mission source uses area markers for its permanent sites;
actual terrain travel remains untested.

The initial developer-tuned count is 40 + 8 * floor(warLevel), clamped to war
levels 0-10: 40 to 120 basic infected. This is a tuning choice, not a measured
performance guarantee. No special creature is added to this ordinary horde.

Preparing server-owned jobs can reserve their complete size separately from
shared actors and town populations. March/arrival/cleanup retains the allowance
for living members but cannot reserve replacements; pending slots retire when
preparation stops. Missing, stopped or retired owners cannot create more members.
Living bindings retain their dedicated classification even if the owner record
is removed. Transfers cannot borrow town/horde capacity or import outside actors.
Arrival reinforcement will therefore need an explicit handoff that preserves
budget accounting rather than weakening this rule.

The focused suite includes 11 common, 23 existing shared-budget and 44
interception checks. All 78 pass without engine/SQF errors. It uses native navigation queries with controlled VR graph
records and creates complete 40- and 120-infected groups while the shared limit
is full and a town owns its own pending allowance.
This exercises the spawning primitive, not a complete staged mission. Three
parser unit tests and config/PBO packaging pass. All 141 production files and
the PBO match Interception Dev1. The initial 72-case run failed an assertion made
before Arma reported a terminated worker finished. The corrected fixture records
scriptDone false immediately and true on a later scheduler step, then verifies
that pending reservations and new grants are refused. No production change was
made for that fixture correction. The rejected report is retained separately.
The passing report is interception-foundation-focused.json. It retains 16
startup/dependency notices and no engine/SQF errors. Town regression and actual
missing-dependency checks are next; full campaign acceptance remains open.
