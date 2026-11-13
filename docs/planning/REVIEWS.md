# Review record

## 12 November 2026 — Sprint 0 foundation and test tooling

Scope: product decisions/backlog, pinned dependency inventory and source
comparison, isolated launch/build scripts, prepared-class smoke fixture and
evidence collector, and the proposed Occupant impact matrix. This review does
not accept the Infection gameplay addon or close Sprint 0.

Developer self-review, as authorized by the product owner:

* Inspected the authored tools and documentation. The inherited gameplay examples
  remain outside the test launch stack. Mod archives, profiles, raw logs and
  third-party extracted source are excluded from Git.
* CfgConvert and FileBank produced the working standalone fixture. The original
  incomplete Eden structure was replaced after a reproducible launch loop.
* All 14 prepared classes completed the dedicated spawn/init/equipment/deletion
  checks. Model/skeleton/attachment errors on the large creatures remain open;
  the report correctly requires review despite its passing smoke assertions.
* The collector rejected a real non-starting log as incomplete. It requires
  unique complete records and the full candidate set, and does not publish raw
  player identifiers or absolute local paths.
* Python compilation, PowerShell syntax parsing and Git whitespace checks passed.
  Launchers isolate profiles and protect the owned probe install with a hash
  receipt. Repeated starts are rejected instead of sharing the same profile.
* The matrix names source owners, proposed changes and acceptance scenarios;
  source paths/hashes are verified against the pinned checkout. Remaining caller
  audit, the signed S3 route disposition and complete S4 mission catalog are open.

Integration decision: the foundation/tooling can merge independently. Keep S0-1,
S0-2 and S0-3 open for the documented remaining evidence. No user acceptance,
clean gameplay certification or Workshop release is implied.

## 13 November 2026 — Registration scaffold

Self-review covers the unique addon/template registration, dependency facts,
67 prepared-class roles, isolated build scripts and contract fixture/collector.
No upstream function is overridden by this change. The real Ultimate loader and
creator completed 83 checks; the missing-dependency fixture completed ten checks.
Vehicle pools remain deliberately empty and their campaign consumers remain an
open implementation task. README and registration notes identify this limitation.
The latest full test completed before the previous halt; collection now includes
its completion record. Startup warnings are retained rather than hidden.

Integration decision: preserve this as a reviewable development scaffold. It
does not complete Sprint 1 or authorize a campaign/release claim.

## 13 November 2026 — Foot garrison-line contract

The narrow CfgFunctions override checks both Infection selection and runtime side
before replacing the virtual line builder. The installed Ultimate implementation
is retained under an alias for other factions and missing dependencies. It does
not edit shared preference arrays, create live AI, or invent vehicle placeholders.
The override ledger records the pinned source and remaining caller boundaries.

Validation: 94 isolated dedicated checks passed, including every inherited
preference at fixed and weighted tiers, no infected vehicle selector calls,
normal WEST/EAST delegation, malformed input, original initial-roster/ratio
consumers, and the 67 unit-spawn regressions. No SQF/engine error records were
detected; the previously recorded startup warnings remain. The build used a new
directory so the owner's running client retained its earlier addon unchanged.

Integration decision: this contract change is reviewable independently of the
remaining site, reinforcement, capture and save work. Those stories stay open.
