# Isolated disk persistence checks

The modern-format test writes a native campaign-data hashmap through Ultimate's
setStatVariable and writebackSaveVar helpers, stops the writer process and starts
a different process using the same isolated mission/profile. It does not call
the full saveLoop or loadServer. The saved plugin payload is read-only using
compileFinal, as in native saveLoop. The reader triggers the native load event
before applying the garrison field, matching loadServer order.

The accepted missionProfileNamespace run passes 15 write checks and 20 read
checks with no recorded engine/SQF errors. It restores three town extras, two
administration extras, unrelated plugin data, trader assignment/completion
flags, the saved trader position and the destroyed-radio-position field. A
repeat plugin event does not duplicate administration extras. Native loadStat
recreates the trader and stock at the saved location. The radio check verifies
stored positions only, not reconstruction of terrain radio objects.

The writer PID was 56844; the reader PID was 57140. Both were stopped after
completed evidence collection. The snapshot and SHA-256 receipt are retained
in evidence/sprint-4. All 324 production inputs and the PBO match the manifest;
three evidence-parser tests pass. No production code was changed in this branch.

Rejected attempts are retained: the first writer incorrectly expected eight
fields when it populated seven; the legacy-profile reader passed its 20 state
assertions but raised an undefined disableTrader error because the fixture
omitted the native campaign setting. Initializing that setting precedes the
accepted modern-format reader. The legacy read is not certified by the later
modern-format result.

These checks do not establish a complete campaign save/reload, connected-player
state, saved active missions, save migration, JIP, or playable trader actions.
Actual campaign creation, full native save/load, terrain object restoration and
player acceptance remain open. Manual Dev9 profiles and saves were untouched.

To repeat, use a new named Template profile. Build/run PersistenceWrite, collect
and stop its exact server, then build/run PersistenceRead with the same instance
name, profile and build. The writer refuses to overwrite its existing campaign
key; preserve prior runs and choose another instance for a fresh pair.
