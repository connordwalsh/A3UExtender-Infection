# Native campaign loot-crate valuation regression

Owner decision on 15 November 2026: use Ultimate's configured loot-crate price
instead of its erroneous 1000-money vehicle-price fallback. The implementation
lives in the independent A3U-Redux-Fixes repository, not Infection production.

The campaign probe now creates one real faction loot crate before calling native
saveLoop. It verifies exactly one crate and no placed rally point, records the
configured price and current funds, and checks both saved funds and unchanged
live funds. After a process restart it verifies the restored amount. No native
save/load function is overridden. The crate is deleted after collecting the save.

The writer (PID 47068) passes all 11 checks: funds 1000 plus crate price 100
produce saved funds 1100. The reader (PID 55588) passes all 11 checks, including
restored funds 1100, town/admin extras, dealer, HQ and save identity. Both servers
were stopped after completion. Original smaller probes remain preserved with
their original reports; the expanded collector now requires the new checks.

Tested Infection PBO:
`b4b0c17e92a87e16020635ed4ebcd8ad1e28dd2ff78c5866c494ec23dd981085`.
Tested Redux fixes PBO:
`56686a31096bfb3e9e55ef029eab5b33ab8a2beea39e4e16fd207ec0f4430fd6`.
Full logs, reports, receipts, the written synthetic save and companion manifest
are retained under `evidence/sprint-4/redux-companion-price-*`.

Population and pricing errors are absent. Both overall clean-log reports still
fail on 11 records from existing no-player startup, object-removal and six short
vehicle-marker problems. Seven collector/parser tests pass. This validates the
approved save valuation; it does not close client/UI, JIP, performance or release
gates. The manual installation was untouched and Computer Use was not used.
