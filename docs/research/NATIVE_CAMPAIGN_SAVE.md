# Native Redux campaign save/reload probe

The official Antistasi_chernarusredux mission initialized a new Infection
campaign in a dedicated process, executed the full native saveLoop, and loaded
the resulting save through full native loadServer in a second process. The
helper addon starts setup through native startGame and observes state; no
contract-addon function replacements are loaded. It is test-only and must not
ship as gameplay content.

The controlled test uses Infection Occupants, vanilla CSAT Temperate, FIA,
civilians and Exegermenos. These are test inputs, not new release defaults or
proof of the requested final NATO/Russian equipment and civilian behavior.
Default native parameters are used. The test seeds three town extras and two
administration extras and deliberately triggers the existing dealer endpoint
to exercise persistence without waiting for random intel. Production unlock
timing is unchanged.

Writer PID 56056 initialized the campaign, unlocked the dealer and completed
a 72-field native save. Its nine state assertions passed. Reader PID 34092
initialized the saved campaign and passed ten state assertions: town extras,
administration extras, dealer flags/position, HQ position and campaign ID were
restored. Both exact test processes were stopped after completion. The full
RPTs, launch receipts, generated save and source/PBO manifest are retained.
All 324 production inputs and the PBO match. Seven evidence-parser/collector
tests pass, including rejection of native errors despite passing assertions.

## Rejected clean-log gate

Both reports are failed overall: the writer contains 63 error records and the
reader 60. This is not a bug-free campaign certification. The errors include
High Command's missing leader, a SmartMarker initialization message, native
object-removal traffic, six short vehicle-spawn markers, repeated population
lookup errors, and (writer only) an unpriced Syndicate ammunition box.

The unmodified baseline RPTs dated 12 November contain the same High Command,
spawn-marker and population errors. The current source explains the population
issue: initVarCommon calls getCityData, which stores arrays under display names;
initZones calls it again, where the display-name array masks the numeric
configuration-name fallback. The second call logs bad population and counts
houses instead. Infection town rosters read A3A_townData, which initVarCommon
filled on the first call; do not infer every downstream native town/vehicle
consumer therefore has the same population. A separate-repository decision
for general Redux compatibility fixes is pending.

These findings require resolution or explicit acceptance before release. No
connected client, commander menu, local host, JIP, player save, mission playthrough
or long-session performance acceptance is established. Manual Dev9 is untouched.
