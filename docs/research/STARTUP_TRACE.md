# Startup object and addon tracing

15 November 2026. Opt-in diagnostic helper; not campaign acceptance. The normal
campaign helper configuration remains unchanged. `-TraceStartup` selects a
separate configuration that observes startup without starting or saving a
campaign. Its activation wrapper records bounded inputs/results and calls the
installed handler unchanged; it changes the diagnostic function-name prefix
and can affect scheduling. Never use its timings as uninstrumented proof.

## Observations and limitations

- Dev1 combined early entity events with a full addon-list log. The list exceeded
  the RPT line limit. Preserve this rejected run and its exact fixture; it is not
  evidence of a clean or completed campaign. It recorded crate boxX as 2:8 and
  sidesX as 2:19, but never observed creation/deletion events identifying 2:9 or
  2:10. The missing objects therefore remain unidentified.
- Dev2 removes entity logging and records counts/sample names. Both Curator
  activation requests occur after mission time starts: all 2874 patches, then
  an empty list. Both return an empty array and log the native timing error.
  There are already 2874 active addons, and Curator ends with 2874 available.
- Dev3 compares raw names. Case-sensitive subtraction reports 2790 differences;
  that does not establish missing addon identities.
- Dev4 compares both raw and lowercase names. Both requests have zero missing
  normalized names, proving they request no additional addons in this run.
  The native handler still rejects both late requests. Two missing-object errors
  also remain. All six bounded diagnostic records parse without truncation.

Source inspection of the installed Curator module shows two activation sites:
the all-addons branch and a final request for synchronized future addons.
Official Redux configures its module with Addons=3. The native helper rejects
every call after time 0, before checking whether any new activation is needed.
This supports a narrow idempotent-request fix, not permission to activate new
addons after startup or change Curator access policy.

Local installed source hashes (source not redistributed):

- modules_f_curator/curator/functions/fn_modulecurator.sqf:
  `d377ba2abce66026e62240d7806962be6b2caf4292743a33d3f7b72df48d3818`
- functions_f_curator/misc/fn_activateaddons.sqf:
  `b5f9b83a401c4ba62e5c767a86a95dd9f6a5e8e17fce2f9f652c642554270643`

Complete logs and launch identities are retained under
`evidence/sprint-4/startup-trace-dev*`; intermediate fixture versions accompany
Dev1–3. Dev4 uses the committed trace fixture. Its collector records errors
without classifying diagnostic completion as clean-log acceptance. Three tests
cover complete bounded records, rejected truncation, duplicate runs and missing
completion. The helper launcher now records all selected source hashes for
future runs; older receipts retain their original packed-helper hashes.

No production Infection code, manual installation or Computer Use changed.
