# Product backlog

The acceptance criteria and test requirements are in [PROJECT_PLAN.md](PROJECT_PLAN.md).
[PRODUCT_DECISIONS.md](PRODUCT_DECISIONS.md) records the user's amendments.
Status is evidence-based; successful packing does not complete a gameplay story.

| Story | Work | Status | Evidence / next check |
| --- | --- | --- | --- |
| S0-1 | Versions, dependencies, clean local and dedicated baseline | In progress | Version/hash inventory and local HQ startup observed; save/reload and dedicated campaign open. |
| S0-2 | Prepared-class catalog and behavior | In progress | Installed configs inspected; dedicated probe in development; combat/locality matrix open. |
| S0-3 | Occupant impact map | In progress | Creation, garrison, damage, civilian, support and event contracts being traced. |
| S1-1 | Infection scaffold and dependency checks | Backlog | Gate 0 inputs required. |
| S1-2 | Basic infected tier/group definitions | Backlog | Tested class catalog required. |
| S1-3 | Vehicle/template contract | Backlog | Empty pools need tested bypasses. |
| S2-1 | Occupied-site lifecycle | Backlog | All used site types, cleanup and reentry. |
| S2-2 | Foot patrols and road controls | Backlog | Urban/rural paths and bounded cleanup. |
| S2-3 | Capture and persistence | Backlog | Capture/reload/recapture at four site types. |
| S3-1 | QRF and attack routing | Backlog | Foot responses, costs, timeout and cancellation. |
| S3-2 | Garrison repair | Backlog | Ownership, cooldown, player proximity and cap. |
| S3-3 | Conventional force disposition | Backlog | Occupant-only changes; Invader regression. |
| S4-1 | Complete mission classification | Backlog | Manual and automatic triggers. |
| S4-2 | Mission eligibility and common objectives | Backlog | Success/failure/timeout/no-spawn outcomes. |
| S4-3 | Existing outbreak mission adaptations | Backlog | Survivor civilian configuration. |
| S5-1 | Central spawn budget | Backlog | Reservations, cap, cleanup and telemetry. |
| S5-2 | Special roles and escalation | Backlog | Largest types restricted to declared events. |
| S5-3 | Two distinct outbreak mission patterns | Backlog | End-to-end solo and group evidence. |
| S6-1 | Chernarus Redux site sweep | Backlog | Fix reproduced defects only. |
| S6-2 | Faction interaction regression | Backlog | Survivor side decision and final faction composition. |
| S6-3 | Player-facing clarity | Backlog | First-hour usability evidence. |
| S7-1 | Dedicated multiplayer and JIP | Backlog | Two clients; headless support decision based on tests. |
| S7-2 | Performance and cleanup soak | Backlog | 90-minute representative session. |
| S7-3 | Campaign progression and saves | Backlog | New campaigns only; staged save fixtures. |
| S8-1 | Reproducible release candidate | Backlog | Clean-install and artifact/source matching. |
| S8-2 | User and maintenance documentation | Backlog | Verified behavior and override ledger. |
| S8-3 | Acceptance and handoff | Backlog | Traceability, defect closure, user sign-off. |
| V-1 | Abandoned, repairable, drivable vehicles | Backlog | Included in this repository by the latest user correction. |

## Working session: 12 November 2026

Sprint goal: establish a reproducible baseline and verified integration contracts.
The public fork and planning PR exist. Installed/source versions are pinned.
A fresh unmodified local campaign reached HQ. The prepared-class diagnostic
mission builds with the installed Bohemia tools; its dedicated launch is being
debugged before any pass is claimed.

Resolved product question: the owner approved vanilla stand-ins by default,
with optional mod support for authentic modern Russian/NATO equipment.

Manual testing resumed after the owner's explicit authorization. Both earlier
test processes had closed. The local log ends normally without a completed save,
so the baseline save/reload check is being repeated in the isolated profile.
Injected keyboard input still needs verification after the restart.

No sprint review, retrospective, or completed gate is recorded yet.
