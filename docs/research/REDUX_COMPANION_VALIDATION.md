# Independent Redux population correction: campaign validation

15 November 2026. The owner approved the independent public
[A3U-Redux-Fixes repository](https://github.com/connordwalsh/A3U-Redux-Fixes).
The Infection launcher now accepts an optional `ReduxFixesMod` test input and
records its exact PBO hash. Infection production code and dependencies are
unchanged. The manual Dev9 installation and saves were not touched.

## Tested artifacts

- Infection CampaignSave Dev1 PBO:
  `b4b0c17e92a87e16020635ed4ebcd8ad1e28dd2ff78c5866c494ec23dd981085`.
- Redux fixes PBO:
  `cfa61bd47272c7f8f9ec26ed92aba51181988d4af3d4e2cf5956acba37ad3a8b`.
- Official Redux campaign, native startGame/saveLoop/loadServer, same isolated
  scenario and defaults as the original campaign save spike.
- Writer PID 55648, reader PID 17700, distinct processes using the same isolated
  profile. Both were stopped after completion and evidence collection.

## Outcome

The writer passes all nine assertions and saves 72 campaign fields. After a
process restart, the reader passes all ten assertions, restoring town and
administration extras, dealer state, HQ and campaign identity.

Both logs contain zero bad-population errors. The original campaign spike had
49 such errors in each phase. Total classified error records drop from 63 to
14 for write and from 60 to 11 for read. These are record counts, not counts of
distinct bugs. Both reports correctly remain **failed** under the unchanged
clean-log gate: High Command/SmartMarker no-player startup, object-removal
messages, six short vehicle markers and writer-only ammunition-box pricing
errors remain. No error filtering was relaxed.

Evidence: `evidence/sprint-4/redux-companion-*` includes full RPTs, reports,
launch receipts, the writer's 341059-byte synthetic save, and companion build
manifest. Seven existing evidence parser/collector tests pass.

This supports the focused population correction in a full server campaign.
It does not certify client UI, player missions, local hosting, JIP, long-session
performance or overall release readiness. No Computer Use was performed.
