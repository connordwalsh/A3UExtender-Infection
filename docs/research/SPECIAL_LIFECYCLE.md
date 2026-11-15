# Special infected lifecycle diagnostic

Status: fixture packages and six parser/classification tests pass; expanded runtime
validation pending. No special is enabled in production.
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

Next: execute all 56 trials, review death/deletion order and surviving
objects, then determine which native lifecycle can support an Elimination Task.
Visual model quality, terrain movement, player combat, headless transfer, JIP,
special mission balancing and campaign integration remain separate work.
