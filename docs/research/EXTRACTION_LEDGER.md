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

Dev1 packages and passes three parser tests and eleven actual missing-dependency
checks. Its 42-check focused run is REJECTED: 41 passed, with the living-deletion
case failing and two script errors. On this installed engine, EntityDeleted
passes the object directly; indexing it as an array fails. The retained report
and Dev1 manifest document the defect. Correct the handler and retest before
acceptance. No manual installation/profile or Computer Use changes.

Open work: public task/controller and rewards, guarded release/recruitment,
mission target/scene selection, timeout cleanup, connected play, HC/JIP, campaign
save/load and complete mission acceptance. This prerequisite closes no sprint.
