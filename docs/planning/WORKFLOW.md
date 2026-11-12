# Development workflow

The product owner sets requirements and resolves product uncertainty. The
developer performs implementation, testing, self-review, and backlog upkeep.

## Sprint procedure

Use the nine ordered sprint goals from PROJECT_PLAN.md. Plan against a one-week
timebox, beginning with Sprint 0 on 12 November 2026. At each working session,
record completed evidence, the next concrete work, and impediments. Review and
retrospective records accompany each sprint gate. An elapsed timebox never turns
an unverified story into completed work; unfinished stories return to the backlog.

The repository backlog is the durable record of story criteria, progress, and
evidence. GitHub issues track defects and reviewable work. Implementation uses
`codex/` feature branches and pull requests into this fork's `master` branch.
Keep upstream history and record the exact source revision behind each override.

## Review and integration

Before merging, inspect the full diff, run checks appropriate to the change,
record their actual results, and assess effects on other factions and saves.
Documentation or test tooling can be integrated independently without claiming
that the enclosing gameplay story or sprint has passed. Gameplay gates require
the live evidence specified in the plan.

Commit cohesive changes frequently. Push reviewed work and open pull requests in
the user's fork. Do not publish or modify upstream repositories. Record known
defects and the steps to reproduce them before fixing and retesting them.

## Evidence hygiene

Commit authored source, test scenarios, build tools, accepted decisions, concise
test reports, dependency manifests, and relevant screenshots. Keep dependency
binaries, extracted third-party source, raw game profiles, saves, crash dumps,
and raw logs under ignored `.work/`. Publish only the log excerpts needed to
substantiate results, without player identifiers, credentials, or private paths.
Never commit signing private keys. Built releases must match recorded source
and dependency versions.
