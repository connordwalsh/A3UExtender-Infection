# Ultimate 12.4.2 baseline refresh

On 13 November 2026 Steam updated the installed Ultimate files. The official
[12.4.2 release](https://github.com/Antistasi-Ultimate-Community/A3-Antistasi-Ultimate/releases/tag/v12.4.2)
is pinned at `c7c8247672ed5e7d4aa317d47efb371c41de4e7d`.
The previous 12.4.1 reports remain historical evidence, not current-version
campaign acceptance.

The [new inventory](../../evidence/sprint-0/installed-baseline-12.4.2.json)
contains 198 addon hashes. Compared with the 12 November inventory, all 15
Ultimate archives changed; CBA, IMS, WebKnight, CUP Core and Redux archives did
not change. Arma remains 2.22.154089, Steam build 25623484.

The installed core archive was extracted into a separate research directory.
The [comparison](../../evidence/sprint-0/core-source-equivalence-12.4.2.json)
finds 1,323 matching script/header/config inputs, normalizing CRLF to LF.
Only the packaging-dependent `config.cpp` differs; `bis_addoninfo.hpp` is
installed-only and there are no source-only inputs. The reproducible comparison
tool is `Tools/dev/compare-core.py`. This does not compare all other addon
sources or prove gameplay compatibility.

Of the 86 integration-owner files in the
[refreshed impact manifest](../../evidence/sprint-0/impact-sources-12.4.2.json),
85 retain their earlier hashes. The change in `Save/fn_setStatVariable.sqf`
preserves legacy-format save storage when renaming a game before loading it.
The plugin save/load design remains an open implementation task. Infection
continues to support new campaigns only.

`NATOinit`, `handleDamageAAF`, `enemyUnitKilledEH`, `enemyUnitDeletedEH` and
`createGarrisonLine` are byte-identical to their inspected 12.4.1 versions.
The isolated fixture now checks the full `[12,4,2]` version from the installed
header, in addition to Ultimate's normal major/minor extender validator.
Local and dedicated campaign/save acceptance must still be performed on the
current version; the older local-save proof is not transferred automatically.
