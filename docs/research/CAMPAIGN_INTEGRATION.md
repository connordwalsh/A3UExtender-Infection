# Combined campaign integration

This candidate combines the survivor-defense integration with Extraction and
release, the sixth rescue endpoint, infected tower policy and dealer unlock.
The separate source builds and accepted focused reports remain preserved.
Manual Dev9 and its saves are untouched. No Computer Use is involved.

The independent Extraction Dev4 full run is still running and has reported
failures. It must be retained as rejected on completion, not certified by its
150-check focused pass. The independently running survivor-defense full suite
has not yet completed either.

## Investigation

- The older Liquidation dispatch fixture still expected RES to delegate to the
  native missionRequest. That conflicts with the implemented replacement. The
  integrated fixture now checks that RES has no native fallback; dedicated
  Extraction dispatch tests separately verify actual mission creation.
- The active Invader-horde fixture requested global limit zero. The RPT at
  14:31:59 explicitly reports CBA rejecting that value; the registered slider
  minimum is one. The unchanged prior cap allowed four paid actors. The test
  checked fixed-only cost, then moved on before those actors finished cleanup;
  two subsequent offscreen simulation assertions also failed. Their causal link
  still needs confirmation by the corrected run. The new fixture reserves one
  slot against a valid one-slot cap and asserts that reservation before launch.
- Native Liquidation capture logged a successful ownership transaction but its
  composite fixture assertion failed without component detail. The integrated
  fixture now records owner, claim outcome, capture lock, garrison and clearance
  without changing capture behavior. Do not infer its cause before observation.

Focused Major and Liquidation diagnostics are running on the same frozen
CampaignIntegration Dev1 PBO. Full integration, connected clients, campaign
saves, real terrain, performance and release acceptance remain open.

Focused results: all 126 Major checks pass after the valid-cap reservation fix,
including the active Invader horde and all six offscreen target categories. All
44 Liquidation checks pass; the capture diagnostic reads Rebel owner, won claim,
empty lock and empty garrison. This does not reproduce or explain the earlier
full-run capture assertion failure. Keep that issue open until combined evidence
can assess it. Both focused reports have no engine/SQF errors; all 322 production
inputs and the shared PBO still match. The next full run includes both original
feature branches and all later route/dealer changes, with these diagnostics.

## Completed combined regression, 15 November

CampaignIntegration Dev1 completed at 15:19:28: all 1,806 checks and 67 role
spawns pass. The collector reports no engine/SQF errors; a separate search finds
no native Antistasi Error-level records. All 322 production inputs and the PBO
still match the build manifest. The completed isolated server was stopped.

The corrected valid-cap attack case, all offscreen attack simulations, native
site capture, replacement rescue dispatch and restored-arsenal cleanup pass in
this combined run. The old Extraction run remains rejected. This result does
not identify which component failed in its uninstrumented capture/cleanup
assertions; preserve the intermittent findings for further acceptance testing.

The survivor-defense integration is now merged in #49. This full report supports
source integration of Extraction and the remaining campaign route/dealer changes.
It predates the narrative-only Rivals adapter and later disk/campaign test tools.
Those have separate branch evidence. Native Redux campaign tests reveal existing
startup/map-data errors; passing isolated regression does not resolve them or
close a sprint/release gate. Client/UI, multiplayer/JIP, terrain playthroughs and
long-session performance remain open.
