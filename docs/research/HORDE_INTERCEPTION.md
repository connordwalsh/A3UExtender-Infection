# Horde Interception source audit

Status: route selection and separate-budget foundation drafted on the feature
branch. It passes 78 focused, 78 town-regression and 11 actual missing-dependency
checks. Full mission behavior is still incomplete. The task controller, full formation
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
startup/dependency notices and no engine/SQF errors. The same artifact passes all 78 town-regression checks, preserving full town
populations and independent shared limits. That run retains 20 warnings: 16
startup notices and four object-deletion notices. The actual missing-dependency
run passes 11 checks with seven startup notices. Neither reports engine/SQF
errors. The reports are interception-town-regression.json and
interception-dependencies.json. Full campaign acceptance remains open.


## Next integration work

The formation child branch now tracks members inside the spawn transaction and
holds the whole roster hidden with simulation disabled. It refuses departure
until every member is present, initialized and alive. Interrupted construction
can be reclaimed through exact context/ticket ownership. Death and live deletion
are separate: deletion cannot count as elimination, and an arrival followed by
immediate death remains an arrival. A controller still needs to own the record,
poll arrivals, settle the task and supervise eventual cleanup.

Native garrisonUpdate appends arriving classnames without a hard capacity clamp.
The existing Infection adoptReinforcement helper deliberately requires paid
shared-budget groups and available site capacity, so it cannot be reused blindly
for this separately budgeted horde. Preserve ownership, real arrival, once-only
roster/clearance updates and eventual cleanup when designing that handoff. Town
visits retain the owner's default per-visit regeneration policy.

The owner confirmed Russian automatic supply convoys must remain background
military activity without player-facing convoy assignments. Native CONVOY currently
combines task creation, rewards and vehicle/campaign behavior, so its strategic
Russia path needs explicit separation. Do not simply refuse the constructor or
redirect that activity into an infected task. This behavior is not implemented
by the foundation branch.


## Formation candidate and movement correction

The internal preparation worker creates groups of at most 12 and requires the
complete requested roster. Source safety and ownership, destination ownership,
worker identity and remaining obligations are rechecked during staging and at
departure. These initial destination restrictions do not cancel an already
marching horde when Russia takes the destination. No player-facing constructor
uses these helpers yet.

Retirement closes pending reservations immediately. Hidden preparation actors
can be removed directly; visible survivors wait until observers leave their
spawn-distance radius. An arriving-horde handoff must explicitly release adopted
members from formation ownership before this cleanup is used. Cleanup does not
claim kills, settle tasks or erase the owning job record.

The generic spawn helper has an optional post-initialization callback. A refused
callback rolls back the unit; prepaid actors receive one refund rather than both
an explicit refund and the initialized unit's deletion refund.

Formation Dev1 exposed a movement defect: assigning group waypoints did not
reliably override prepared zombies' initial individual movement order. Its
rejected report records a group leader with zero progress. Earlier half-metre
checks were too weak to establish travel. Dev2 waits for native AI initialization
while the formation is hidden and explicitly orders each released member toward
the destination, leaving native enemy pursuit enabled. The strengthened check
requires every group's leader to make at least ten metres of destination progress;
it does not establish complete route traversal on Chernarus Redux.

Three rejected reports retain test-fixture faults: missing parentheses in
an SQF hashmap expression, an unserializable null-group diagnostic, and use of
forEachIndex inside apply when computing group progress. None is a passing
build result.

Formation Dev2 passes 47 focused dedicated-engine checks (11 common and 36
formation checks) and 11 actual missing-dependency checks. The focused run
staged and released all 40 and all 120 infected, reclaimed interrupted partial
creation, and left no actor/group/budget residue. Four leaders advanced
12.4893, 12.5686, 10.0027 and 12.4208 metres toward their destination. Observer
cleanup uses a controlled AI observer injected through the isolated test addon;
it is not connected-player validation. Focused warnings are 16 startup notices
and four object-deletion notices; missing dependencies has seven startup notices.
Neither run has engine/SQF errors. All 147 production inputs and the PBO match
the recorded Dev2 manifest. The combined Dev2 regression completed 844 checks with two failures: remote
Rebel capture in the Liquidation fixture and one stationary formation leader.
It has no engine/SQF errors but is rejected, not a passing integrated result.


### Background convoy integration boundary

Pinned chooseAttack sends the native Supplies/attack request after its existing
200-resource strategic debit. Keep that scheduling and the native vehicle,
crew, route, supply/support effects and cleanup path. Background mode must gate
both task creation/registration and task settlement/deletion; simply setting
visible=false only removes route dots and still creates a task. Mission-linked
commander/player rewards and penalties also need explicit separation from
world/resource effects. Ordinary campaigns must still delegate unchanged.
The requested and intel paths use the legacy pool; they need Infection mission
dispatch rather than the background strategic path. This is source analysis,
not a claim that the convoy adapter has been implemented or tested.


### Dev3 correction under validation

The targeted capture diagnostic recorded EAST or GUER at entry after the fixture
had locally reset the owner to WEST. Normal captures publish the object variable;
changing the fixture reset to publish it too made all twelve remote trials
succeed. The same rule is needed for its final spawner reset before deleting
campaign namespaces. These are fixture corrections; production capture code
is unchanged. A cleanup-error run is retained separately from passing results.

The movement diagnostic found a living, simulated, awake walker on the ground,
with a MOVE command, no nearest enemy and no native movement lock, advancing
only 0.052 metres while the other leaders marched. Reissuing its destination
order restored movement: 6.064 metres of progress after fifteen seconds. Thus
Dev2's one-time departure order was insufficient; startup ordering alone is not
claimed as the complete root cause.

Dev3 adds a per-job march monitor. Every ten seconds it checks movement and
reissues the destination only for stationary, unadopted, local foot members
outside the arrival radius without native pursuit or a movement lock. It never
teleports units or changes native AI flags. Cleanup and owner termination remove
the monitor. The diagnostic record and original rejected combined report remain
in evidence/sprint-4. New targeted checks cover stopped-order recovery, native
pursuit, remote callback refusal and monitor removal. Dev3 now passes 85 targeted regression checks (11 common, 33 Liquidation and
41 formation) and 11 actual missing-dependency checks. The formation checks
include full 40/120-member staging/release, all four leaders progressing ten
metres, confirmed STOP recovery, native enemy-pursuit preservation, remote
callback refusal, and monitor removal on retirement/owner termination. The
forced-stop check observed STOP, one recovery and 2.025 metres of renewed
movement. Its earlier doMove-to-self fixture was rejected because the actor
never stopped and advanced 16.423 metres normally.

The targeted report has 20 reviewed warnings: 16 startup/dependency notices and
four object-deletion notices. Dependencies has seven startup notices. Neither
has engine/SQF errors. Three parser tests pass. All 148 production inputs and
the PBO match the Dev3 manifest after testing. Both servers exited.

Dev3 full combined suite: NOT_RUN. The previous Dev2 combined run remains
rejected; the targeted run exercises both corrected failures. Repeat the full
suite on the next integrated controller/dispatch candidate before integration.
No full-route, connected-player, performance, save or campaign acceptance is
claimed. No Computer Use or manual-build replacement occurred.
