# Campaign route policy

Owner decisions on 15 November 2026:

- Infected-held destroyed radio towers stay destroyed. Remove the repair-crew
  mission and its automatic rebuild.
- Keep the gang introduction and player-ordered gang assaults.
- Unlock the arms dealer without an introduction mission, at Ultimate's normal
  intel/progression timing. Dealer implementation is in the separate DealerUnlock candidate described below.

The tower adapter stops REP_Antenna both in scheduling and at its public
endpoint, while ordinary campaigns delegate to the native alias. It does not
remove antennasDead entries or rewrite native tower persistence. The separate
player-funded rebuildAssets path remains native; it is not an infected repair
crew. Gang entrypoints and their progression flags remain native.

The first isolated catalog run completed with two rejected assertions because
the scheduler fixture records native forwarding rather than executing it. The
follow-up adds explicit scheduler suppression and logs tower/alive/list/alias
state. This is a changed production candidate (Dev2), not a reinterpretation of
the rejected Dev1 result.

Dealer audit: native prepareTraderQuest owns normal trigger eligibility and
location selection; resourcecheck and selectIntel call it. ENC_Trader creates
the real trader/stock/action, then waits for player discovery before publishing
traderPosition, TraderMarker and completed flags. The replacement must skip the
intro task/discovery/rewards while retaining native services and save fields.
It must handle duplicate requests, failed placement and disabled-trader settings.
Native loadStat restores traderPosition by creating the trader, stock and action;
actual disk save/reload and connected trading require subsequent acceptance.

Pinned source identities:

- `core/functions/Missions/fn_REP_Antenna.sqf`: `430af43f92dde3ec2c9b557eeb992dc91786652adecaa66aa286b9e866992765`

- `core/functions/init/fn_resourcecheck.sqf`: `c306affdeb61926ad1ee58112b4d542dfecfeb66ce60dc482c8a55a1bd4d1def`

- `core/functions/Base/fn_rebuildAssets.sqf`: `fa704add8738e86ad62cec651e773e143d14ec1b9c2ef1300b0353fcf44c8709`

- `core/functions/Missions/fn_ENC_Trader.sqf`: `c6b54eac128d526e43863b7c543dd9f085b662d177f9da3648c340bf15814962`

- `scrt/Trader/fn_trader_prepareTraderQuest.sqf`: `00023febe390b3ba4d5a780bd317d7e69a4c6e796ed54ea0270a4711adcfc8fd`

- `scrt/Trader/fn_trader_createTrader.sqf`: `abce4c0d9aa71c6359079bc14de88c54ed9009082698d483231c69dfb9ef7195`

Dev2 catalog results: all 30 checks pass, with no engine/SQF errors. The tower
diagnostic records dead=true, antennasDead membership preserved, and no native
repair/scheduler alias calls. No added entities/groups are observed. All 289
production inputs and the PBO match the retained manifest. Three parser tests
pass. All eleven missing-dependency checks also pass; native disk saves and full campaign
acceptance are not certified by these checks.

## Dealer unlock candidate

The separate DealerUnlock Dev1 keeps native prepareTraderQuest and its callers,
so intel/progression timing and the disabled-trader setting remain native. The
ENC_Trader adapter runs once on the server, creates the native trader and stock,
dispatches the native market action, and publishes the native marker, position
and completed flags without an introduction task, search area or score reward.
Placement retains native terrain/road/enemy-site checks, with a 200-attempt
bound; failed workers release the assignment flag for a later normal retry.

The first test created the trader, stock and saved fields successfully but is
rejected: its marker-update recorder lacked initialization, and it incorrectly
expected an action ID on a dedicated server. Bohemia documents that addAction
is ignored on dedicated servers: https://community.bistudio.com/wiki/addAction .
The corrected fixture forwards the native market function while recording its
server-origin remote dispatch; it does not claim visible client interaction.
The production build is unchanged for this rerun. Actual purchasing, JIP action
visibility and disk save/reload remain acceptance work.

DealerUnlock Dev1 results: the corrected 26-check run passes; the expanded
28-check run also passes, including remote worker rejection and a no-safe-position
case that releases the assignment in 0.179 seconds without creating a scene.
The following normal native trigger succeeds, demonstrating retry. Eleven
missing-dependency checks pass. All 291 production inputs and the PBO match.
No recorded engine/SQF errors; sixteen/seven baseline warnings remain. Native
stock cleanup also prints a zero-client update notice in this no-player fixture.
The rejected initial report is retained. Both completed dealer servers stopped.
No connected buying, JIP, real terrain or disk-save acceptance is claimed.

## Gang-cell staged casualties

Source review of pinned Ultimate `fn_RIV_ATT_Cell.sqf` found a delayed scene
effect: after 30 seconds it selects on-foot Occupant actors within 1.5 times
the site size, excludes actors indoors, and gives each a 75 percent chance
of fatal damage. The owner explicitly retained this behavior on 15 November.
No Infection override is needed. This is a source-policy finding, not proof
of completed gang-story campaign playthroughs.
