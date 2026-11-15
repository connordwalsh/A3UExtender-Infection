# Extraction survivor resolution

The owner requires the assignment to remain active until every survivor is
rescued or killed, or the original deadline expires. At settlement, one or more
rescues means success; zero means failure. The rescued total will drive rewards.
The first rescue alone cannot finish a mission with unresolved survivors.

Four internal server functions register exact actors, observe death/deletion,
update outcomes and release bookkeeping. They do not create a public task, spawn
survivors, grant rewards or delete assets. Each survivor has a stable entry and
an owner/name/serial/index guard. Rescue is recorded at an approved friendly
destination before deadline and remains recorded thereafter. Death requires an
actual event; live deletion remains unresolved until the deadline. Conversion
cannot count as rescue. An independent one-second handler prevents a stopped
mission worker from silently abandoning deadline evaluation. Final counts and
outcomes do not change on repeated checks or late arrivals.

Ultimate's pinned 12.4.2 refugee mission completes on the first HQ arrival and
counts nearby survivors five seconds later; that settlement is not reused.
Its rescue action joins survivors to the player's group, so death observation
must not depend on retaining server group locality. Mission EntityKilled is
also the pattern used by Ultimate's server for vehicle deaths. Reference:
[Bohemia mission event handlers](https://community.bistudio.com/wiki/Arma_3%3A_Mission_Event_Handlers).
Actual connected-client locality transfer remains untested.

Dev2 passes all 42 focused engine checks, eleven actual missing-dependency
checks, packaging and three parser tests. No engine/SQF errors; 16 startup/
dependency notices reviewed. All 182 production inputs and the PBO match the
frozen manifest after execution. Both completed servers exited.

Artifact: @Infection_ExtractionLedger_Dev2, SHA-256
`c5db7f55c6119e0150976c2b3c324ce7120aab9d3f69f0645b355c3e70a2bd3d`.
Reports are extraction-ledger-build.json, extraction-ledger-engine.json and
extraction-ledger-dependencies.json under evidence/sprint-4.

Historical Dev1 packages and passes three parser tests and eleven actual missing-dependency
checks. Its 42-check focused run is REJECTED: 41 passed, with the living-deletion
case failing and two script errors. On this installed engine, EntityDeleted
passes the object directly; indexing it as an array fails. The retained report
and Dev1 manifest document the defect. Dev2 accepts both the observed direct object and array event forms; the
unchanged fixture now passes. No manual installation/profile or Computer Use
changes.

Self-review covered serial ownership, duplicate registration, actual death before
deletion, no early partial success, frozen deadline counts, concurrent ledgers,
independent ticking and exact observer cleanup. No public caller exists yet;
these handlers install only when a ledger is explicitly created. Focused coverage
is the acceptance scope of this prerequisite, not a full combined campaign run.
The final survivor disposition (manpower or usable AI) is awaiting owner input.

Open work: public task/controller and rewards, guarded release/recruitment,
mission target/scene selection, timeout cleanup, connected play, HC/JIP, campaign
save/load and complete mission acceptance. This prerequisite closes no sprint.
