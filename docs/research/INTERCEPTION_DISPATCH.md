# Horde Interception creation and dispatch

Status: drafted; 36 focused runtime checks NOT_RUN. Packaging, three parser tests
and eleven actual missing-dependency checks pass without engine/SQF errors.
The parent stronghold combined regression and aftermath focused validation must
finish before testing this additional candidate. No manual installation update.

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
limit of two, claims, interruption cleanup, cooldown/population preservation,
direct/scheduler/request/remote-request entry points, native request locks,
unavailable routes, intel route text and menu config inheritance. The existing
Liquidation category-preservation test now excludes the newly replaced CONVOY
category; background-convoy regression explicitly expects requested convoy routes
to stop delegating to human convoy creation. These expectations reflect the
approved catalog, not removal of Russian background activity.

Artifact: `@Infection_InterceptionDispatch_Dev1`, 177 production inputs, SHA-256
`79db3352bb737f40dab6ad6f5165e321829cf4468e38427f4841a20f5be831b8`.
All production inputs match the manifest after dependency testing. Reports are
`interception-dispatch-build.json` and `interception-dispatch-dependencies.json`
under `evidence/sprint-4`. The dependency server exited.

Focused gameplay, combined regression, stochastic intel outcomes, connected menu
interaction, actual HC relay, terrain travel, saves and campaign acceptance remain
open. No Computer Use was performed. This draft does not close a sprint gate.
