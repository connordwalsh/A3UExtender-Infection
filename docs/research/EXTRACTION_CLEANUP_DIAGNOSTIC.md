# Extraction cleanup diagnostic

The rejected Extraction Dev4 full run failed the composite restored-arsenal
assertion after task retirement. It recorded no component values.

This branch changes only the fixture: record actor-null states and actual versus
expected HR/funds immediately after registry retirement, then wait up to three
seconds for engine actor deletion and assert the same cleanup/reward conditions.
Production cleanup and rewards are unchanged.

The isolated 14:50 diagnostic completed at 14:51:27 with 41 checks passing and
no recorded engine/SQF errors. All six survivors were already null at the first
observation; HR was 22/22 and funds 1900/1900. The second observation occurred
0.074 seconds later. Thus this run does not reproduce or explain the original
full-run failure. Keep that failure open for combined regression diagnosis.
All 322 production inputs match the retained build manifest. Three evidence
parser tests pass. The completed diagnostic server was stopped after collection.

The combined CampaignFull server remains on its original frozen fixture and
build; this diagnostic change has not been applied to it.
