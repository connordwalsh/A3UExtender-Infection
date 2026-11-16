# Humanitarian Aid map shortcut

Ultimate's map-hover shortcut bypassed the commander mission dialog, so it kept
its Deliver Supplies label and native all-town availability in Infection.
The addon now keeps that original entry only outside Infection and adds a
Humanitarian Aid entry for Infection commanders. Its action inherits the native
scheduler dispatch; server-side construction and revalidation remain unchanged.

The read-only aidTargetEligible predicate is shared with the server's weighted
Aid selector. The menu excludes other factions' towns, destroyed towns,
high-support towns, towns outside HQ mission range, and an occupied Aid task
slot. The server additionally retains campaign readiness and location validation.
The original campaign entry keeps its native title, tooltip, action and condition
behind the non-Infection guard. Load ordering explicitly names Ultimate's existing
dynamic-hover addon; this is not an additional Workshop mod dependency.

Dev1 is rejected: 56/57 focused checks passed, but the fixture expected the
unlocalized config token for the ordinary title. Dev2 records the actual value
and compares it with localize: both are Deliver Supplies. All 60 focused checks
pass, including the existing Aid mission regressions and ten map-config cases,
with zero engine/SQF error records. All 328 production input hashes match the
candidate build. Exact rejected and passing evidence is retained under
`evidence/sprint-6/aid-map-menu-*`. All eleven actual dependency-absence checks also pass with zero engine/SQF
error records. The completed test servers have exited.

Self-review checked the native context callback variables, config inheritance,
server request path and ordinary-campaign guard. Config condition evaluation is
an isolated engine check, not a rendered menu or connected-client test. UI
placement, translated presentation and multiplayer data propagation remain open.
No Computer Use or faction development occurred; manual Dev9 is unchanged.
