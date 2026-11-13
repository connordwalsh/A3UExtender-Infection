# Validation corrections

## 13 November 2026: protected functions and evidence parsing

During combat fixture development Arma reported `Attempt to override final
function` when the harness reassigned Ultimate functions at runtime. The intended
recording endpoints were not installed; the first combat run then reached
campaign functions without a full campaign environment and was stopped. Its
errors and failed assertions are fixture failures, not accepted combat evidence.

Review of the earlier `garrison-contract.json` run found the same rejected
assignment for the vehicle selector. Its `garrison_no_vehicle_queries` assertion
therefore did not establish that no calls occurred. The other observed line,
tier, roster and ordinary-faction result checks remain historical observations.
The earlier report and review are retained with this explicit correction.

The current isolated test addon installs recording endpoints through config
before compilation. The vehicle wrapper calls the real installed selector.
The revised run observed zero queries from infected line construction, then
exactly five from ordinary/dependency-absent controls. This both checks the
infected behavior and proves the counter was active. Configuration paths are
also asserted. The collector now rejects attempts to overwrite protected
`A3A_` or `A3I_` functions and retains other startup warnings for review.

The first completed 118-assertion combat log used bare SQF side values (`WEST`,
`GUER`) inside detail arrays. The JSON-oriented parser rejected four records,
correctly withholding a passing report. The parser now recognizes only the
specified side tokens outside strings, preserves literal strings/backslashes,
and continues to reject unknown tokens. Three regression tests cover that case.

The final [120-check report](../../evidence/sprint-1/combat-contract.json)
passes schema/completeness, actual assertion results and error checks. It includes
the corrected selector observation and added spawn/simulation-contract checks.
Historical tests are not silently reclassified as complete campaign acceptance.
