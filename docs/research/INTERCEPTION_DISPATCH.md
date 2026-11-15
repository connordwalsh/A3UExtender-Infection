# Horde Interception creation and dispatch

Status: all 36 focused runtime checks pass. Packaging, three parser tests
and eleven actual missing-dependency checks pass without engine/SQF errors.
The parent aftermath component also passes its 35 focused checks. The integrated
177-input candidate passes all 1089 combined checks and 67 role-spawn records.
No manual installation update.

## Creation

startInterception selects an eligible walking route and a tier-appropriate roster
of registered basic infected roles. It applies the existing 40-120 size function.
The unscheduled claim precedes hidden preparation, so concurrent requests cannot
create duplicate formations before native CONVOY task registration. Major battles,
existing CONVOY registrations, pending preparation, unavailable sources and bad
routes reject creation without falling back to a human convoy.

runInterception prepares every actor, then releases the complete formation and
registers the native task in one unscheduled transaction. Source cooldown begins
only after launch. Town population data is never overwritten as an idle time.
The independently attached lifecycle supervisor reclaims interrupted preparation
and owns settled aftermath. No changes to the approved size, dedicated allowance,
first-entry failure, rewards or destination policies are introduced here.

## Entry points

- Mission-board requests preserve native Petros leadership and request-lock
  eligibility, but select infected walking routes. Notifications wait for actual
  task registration or preparation failure rather than claiming success early.
- Direct legacy CONVOY calls retain their specified route and pass through the
  server-owned dispatcher. Ineligible Russian source routes are rejected.
- The scheduler routes all Infection convoy calls to the server. A registered
  HC may relay a server-origin direct call, following the existing Liquidation
  authority pattern. Direct client calls to the internal creator are refused.
- Automatic Russian Supplies/attack convoys retain their separate background
  implementation and create no player-facing assignment.
- Both mission menus label the category Horde Interception when Infection is
  selected. Ordinary campaigns preserve native labels and dispatch.
- Convoy-route intel chooses a real infected route and names the accepted
  source/destination. Unavailable routes retain the native small intel payout.

The intel selection function is adapted from pinned Ultimate 12.4.2 commit
`c7c8247672ed5e7d4aa317d47efb371c41de4e7d`. Its body is identical outside the
CONVOY_ROUTE case and absolute include-path adjustment, verified against the
pinned source. A guarded wrapper preserves ordinary campaign delegation and
detaches remote execution before running the server-local mission constructor.
Unrelated intel selection, rewards and display are unchanged. Third-party
license notices remain packaged in Infection/THIRD_PARTY_LICENSES.txt.

## Validation boundaries

Twenty-five specific runtime cases are authored, for 36 focused checks including
the common activation checks. They exercise real 40-member creation with a shared
limit of two and both shared slots reserved, claims, interruption cleanup, cooldown/population preservation,
direct/scheduler/request/remote-request entry points, native request locks,
unavailable routes, intel route text and menu config inheritance. The existing
Liquidation category-preservation test now excludes the newly replaced CONVOY
category; background-convoy regression explicitly expects requested convoy routes
to stop delegating to human convoy creation. These expectations reflect the
approved catalog, not removal of Russian background activity.

Artifact: `@Infection_InterceptionDispatch_Dev1`, 177 production inputs, SHA-256
`79db3352bb737f40dab6ad6f5165e321829cf4468e38427f4841a20f5be831b8`.
All 177 production inputs and the PBO match the manifest after combined testing.
Reports are `interception-dispatch-engine.json`, `interception-dispatch-build.json`,
`interception-dispatch-dependencies.json` and `interception-dispatch-combined.json`
under `evidence/sprint-4`. All completed isolated servers exited.

All 36 focused checks pass without engine/SQF errors; 16 startup/dependency
notices were reviewed. The first run is retained as
`interception-dispatch-rejected-1.json`: its budget assertion confused the shared
limit with the API's combined shared-plus-dedicated capacity. The corrected check
also reserves both shared slots before creation and proves further shared work
is refused while all 40 interception actors spawn. Production code is unchanged.

The combined run has 93 reviewed warnings: 16 startup/dependency notices,
72 object-deletion notices and five missing-fixture-commander notification targets.
Self-review covers administration save payload validation, casualty persistence,
arrival ownership and complete-group transfer, observer-safe cleanup, server
authority, concurrent creation, native request locks and source cooldowns.
The earlier 1040-check report remains rejected; this corrected combined run
includes the bounded native task/reward settlement assertions.

Stochastic intel outcomes, connected menu
interaction, actual HC relay, terrain travel, saves and campaign acceptance remain
open. No Computer Use was performed. This component integration does not close a sprint gate.
