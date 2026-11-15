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
