# Special infected lifecycle diagnostic

Status: all 56 trials completed and cleanup passed, but the runtime report is
FAILED. It records 936 model/attachment errors across five special classes and
one genuine live-body removal without a Killed event. Packaging and six parser/
classification tests pass. No special is enabled in production.
This work follows the unresolved seven ownership/deletion assertions in the
112-trial prepared-class behavior study, not a decision to accept those classes.

The standalone VR mission uses the 14 existing verified candidate class names.
Each receives four trials: delete a living actor, force engine damage, face
the same armed rifle opponent used in the earlier behavior fixture, and approach
a passive unarmed INDEP target at six metres. It records
explicit isNull/alive/local/owner/damage/custom-HP snapshots, Killed and Deleted
events, and separates trial events from cleanup events. No engine setting, native
special AI or campaign behavior is changed. Forced engine damage does not prove
normal weapon damage can defeat a creature.

The API distinction is documented by Bohemia: [Killed and Deleted event handlers](https://community.bistudio.com/wiki/Arma_3%3A_Event_Handlers).
The diagnostic attaches both observers immediately after creation, before the
prepared AI initialization wait. Missing events or deletion before recorded
death cannot grant kill credit. Existing objects must remain server-local;
deleted/null objects are classified separately instead of treating owner zero
as evidence of a transfer to another machine.

The dedicated profile, mission name and port (2902) are distinct from Template
regression and manual play. Only the receipt-owned diagnostic mission is installed.
Its collector rejects missing/duplicate trials, incomplete cleanup, malformed
records, script/model errors, and missing death evidence. Per-trial observations
remain available even when the overall report fails. Known large-creature model
errors remain errors; they are not filtered away or counted as acceptance.

The first 42-trial version was stopped after source inspection showed that
Corrupted can delete its living original body while taking over a victim. Its
partial observations remain `special-lifecycle-interrupted.json`, never accepted.
The added close-passive case records whether the original victim gains the native
zombie marker. It must not count disappearance of the attacker as neutralization.
Inspected local sources: `WBK_Zombies_Corrupted/xeh_preinit.sqf` defines possession
and deletes the original actor; `WBK_Zombies/ai/wbk_ai_zombieexplosion.sqf` instead
kills the Boomer before delayed corpse deletion. Their hashes are recorded in
`special-lifecycle-native-sources.json` under `evidence/sprint-5`.

## Completed observations

The frozen 56-trial fixture and all recorded source hashes match after execution;
the isolated server exited. `special-lifecycle-engine.json` retains the failed
report with every observation and error. All 56 trials began, produced valid
subjects, sampled, ended and cleaned up exactly once. Existing actors remained
server-local. Every forced-death trial recorded Killed; every living-deletion
control remained ineligible for kill credit.

Corrupted close-passive possession deleted the original living body at 14.681
seconds without Killed. At 15.13 seconds the original INDEP victim was observed
on WEST with the native zombie flag. The failed death-evidence assertion is a
real lifecycle finding, not a reason to relax kill credit. An eventual adapter
must track the continuing possessed threat, or leave Corrupted unavailable.
Boomer close-passive instead recorded Killed before delayed Deleted, which can
support a durable death ledger even after native corpse cleanup.

Error counts are Corrupted 218, Smasher 290, Acid Smasher 119, Hellbeast 119 and
Goliath 190. Keep these classes unaccepted pending model/attachment investigation.
Leaper 2, Screamer and Boomer recorded actual rifle-combat deaths without these
error records; Leaper 1 remained alive during this run's short rifle window.
Surviving a short window is not an invulnerability finding or balance approval.
Basic-class controls recorded rifle deaths. None of this establishes visual
quality, player credit, special-objective tracking or release readiness.

Next: implement explicit mission death tracking for validated native lifecycles
and resolve the five classes' errors before enabling those classes.
Visual model quality, terrain movement, player combat, headless transfer, JIP,
special mission balancing and campaign integration remain separate work.
