# Liquidation Assignment

Owner-approved replacement for requested conquest missions. Targets are infected
towns and sites; clearing the assigned infected captures the location for the
Rebels. The former race-to-capture objective is superseded. Bases and airfields
remain restricted to war level 3. A Russian takeover cancels the assignment
without a penalty. The owner permits developer judgment using Ultimate's timers
and rewards as a starting point.

## Target selection draft

`liquidationTargets` uses Ultimate's `findIfNearAndHostile` distance/sorting rule
around Petros, then restricts candidates to infected ownership. The candidate
families are towns, administrations, outposts, seaports, factories, resource
sites, and native conquest-eligible road controls. Military bases and airports
join at war level 3; duplicate list membership cannot bypass that restriction.
Field controls retain their native exclusion from conquest selection. No nearby
attacking faction or horde origin is required for a clearance assignment.

The helper neither requests a task nor captures territory. Existing mission
dispatch is not connected to it yet. The 11 authored selection checks cover
families, duplicate lists, tier restrictions, ownership, distance, field-control
exclusion, missing dependencies and missing HQ. They are **NOT_RUN**. Config/PBO
packaging and three parser tests pass; see the draft build receipt.

## Capture integration constraints

The parent branch supplies the site clearance ledger and read-only predicate.
Pending queued defenders, living assigned actors, healthy deleted actors,
missing/stopped controllers and pending persistent garrison updates cannot count
as clearance. A later visit uses its own ledger and native regeneration rules.

Native `markerChange` can capture a permanent site before its entire garrison is
dead, so an active Liquidation claim must guard that transition. Native town
politics can bypass `markerChange` through `cityChangeSide`; that route also
needs the full-clear guard while the assignment is active. Control and
administration transactions require explicit integration rather than assuming
all captures pass through one function.

Do not put the entire native capture function inside an unscheduled block:
`markerChange` contains sleeps in its aftermath, and `cityChangeSide` delays
maintenance by five seconds. The clearance recheck and actual ownership commit
must be atomic, with delayed work retained separately. A stale success check
must not allow a reinforcement arriving between the check and capture to vanish
or surrender. Preserve site QRFs, campaign support/resource changes, native
administration completion and the war-level restriction.

The remaining lifecycle includes task registration, success/timeout/cancellation,
once-only rewards, stopped-worker recovery, task deletion and ordinary-campaign
delegation. New mission text must not be attached to a legacy competitive task
that still launches an attack on Russian targets. End-to-end gameplay, saves,
connected clients and terrain travel remain unverified.
