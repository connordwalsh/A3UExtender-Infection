# Automatic interception aftermath

Status: all 35 focused runtime checks pass. Packaging, three parser
tests and eleven actual missing-dependency checks pass without engine/SQF errors.
Combined regression awaits the stacked public-dispatch candidate. No player-facing
Horde Interception dispatch is connected in this component alone.

## Behavior

The existing lifecycle supervisor calls interceptionAftermath after arrival
settles the task as FAILED. Task retention and surviving-force lifetime remain
independent. Complete living groups are adopted into an active infected site or
stored offscreen. Partial groups, busy garrisons, observer presence and destination
activation transitions defer the transaction. Each helper retains its exact owner,
serial, ticket, side and physical-arrival validation; retries cannot duplicate
roles. Multiple groups are iterated over a copy because handoffs change ownership.

The aftermath supervisor keeps individual march recovery alive even if the
original scheduled worker stops after settlement. Native pursuit/combat remains
unchanged. An empty force finishes aftermath without changing the failed task.
Remaining actors receive an hour after arrival, using Ultimate's convoy hour as
the owner's authorized time-limit baseline. After that window, ordinary observer-
safe retirement applies; actors do not vanish while nearby players observe them.

At hostile destinations, existing spawner anchors activate the native defence.
Only an active destination with its saved defenders physically represented can
request Ultimate's zoneCheck, at most once per ten seconds. Its weighted 3:1
decision and markerChange remain authoritative; mere arrival never changes side.
After native capture, an actor-only Infection site controller takes over while
the previous creator retains its scene assets. The surviving horde becomes extra
defenders through the same handoff transaction. No second task reward is issued.

The owner confirmed that a stronghold cleared during the march stays permanently
cleared. Its arriving horde still attacks nearby humans, but aftermath never calls
zoneCheck for administrations and does not recreate their removed registry entry.

## Evidence boundaries

Twenty-four specific runtime cases are authored, for 35 focused checks including
the common dependency/activation checks. They cover partial arrival, stopped
worker recovery, busy and observed destinations, automatic storage/adoption,
multiple tickets, persistent deaths, native capture ratios, a Russian takeover,
post-capture actor handoff, permanently cleared administrations and observer-safe
timeout cleanup. The native capture decision runs unchanged; its final campaign
transaction is a controlled fixture endpoint. Arrival positions and deadlines
are injected. This is not terrain travel, a real-hour soak, connected-client or
full campaign acceptance.

Artifact: `@Infection_ArrivalOwner_Dev1`, 168 production inputs, SHA-256
`16a792e9c165b172a5a455df98981f07d84d10899091476914546f65bef4745f`.
Reports: `interception-aftermath-engine.json`, `interception-aftermath-build.json` and
`interception-aftermath-dependencies.json` under `evidence/sprint-4`.

All 35 focused checks pass with no engine/SQF errors and 16 reviewed startup/
dependency notices. The frozen 168 production inputs and PBO still match the
manifest. The completed isolated server exited. Two rejected diagnostic reports
are preserved as `interception-aftermath-rejected-1.json` and `-2.json`.
The fixture now waits for physical deletion after the atomic storage transaction,
introduces its observer after horde preparation, and supplies the required native
town-data map. The second diagnostic's missing-site error is retained in its
rejected report. No production behavior or expected assertion was changed to
obtain the accepted run.

Public creation, mission request/board/intel dispatch, full combined regression,
terrain, connected players, complete campaign saves and sprint acceptance remain
open. No Computer Use or manual installation/profile changes.
