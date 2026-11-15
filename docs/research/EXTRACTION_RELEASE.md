# Extraction survivor release

This increment connects registered Extraction survivors to a guarded release
interaction. It does not create the public mission, award resources or decide
what happens to survivors after delivery.

The future controller explicitly binds a live ledger. Clients receive a free
survivor action; the server validates the requesting player, exact actor and
ledger ownership, pending state, deadline, side, consciousness and four-metre
range. A three-second release reserves the actor once. An independent handler
rechecks the rescuer before joining the survivor to their group. Walking away
allows retry; expiry or ledger cancellation prevents a late join. This preserves
the native refugee group-recruitment pattern while keeping mission settlement
in the approved all-survivors-or-deadline ledger.

Movement AI is enabled while the survivor is still server-local. Native FIAinit
then runs at the recruited unit's locality, preserving its existing identity
and unarmed equipment. Delivery is distinct from release: joining a group does
not mark the actor rescued. Player group assets are not deleted when the ledger
is released. The action's JIP entry is retired even if another system has taken
over the actor, without clearing that system's state.

## Validation

Dev2 passes 89 dedicated checks spanning the existing survivor ledger, actual
shelter/scene creation and release transactions, plus eleven actual dependency-
absence checks. Three parser tests and whitespace checks pass. No engine/SQF
errors; 16 focused and seven missing-dependency notices match the preceding
baseline. All 268 production inputs and the packaged PBO match the manifest.
Completed servers were stopped after verifying process/profile identity.

The earlier Dev1 passes 31 release checks and eleven dependency-absence checks;
its retained evidence predates the ownership-handoff cleanup correction. Dev2
adds explicit foreign-owner refusal, state preservation and JIP-key retirement
checks. No production claim relies on the earlier build for those cases.

The dedicated fixture uses real AI actors through the trusted internal entry.
It verifies the public endpoint rejects AI impersonation, actual group joining,
AI activation and native initialization, duplicate refusal, range and incapacity
checks, cancellation, stale records and cleanup. It does not exercise the visible
client action or network locality transfer to a connected player. Those remain
open alongside HC/JIP, public mission dispatch, rewards, final survivor disposition,
full combined regression, saves and campaign acceptance. No Computer Use or
manual Dev9 changes; no sprint gate is closed.
