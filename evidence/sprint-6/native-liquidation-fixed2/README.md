# Native Liquidation with persistent garrison fix

All 17 Liquidation checks and 19 campaign checks pass, with zero matched engine/native errors. Factory_9 retains its full 16-defender roster with 12 active and four queued. All 16 appear and die via normal event handlers; native roster reaches zero, capture transfers the factory, task succeeds, reward increases exactly 1000 to 1800, capture worker unlocks, site cleans up, infected budget releases, reward remains stable, and HQ remains intact.

Unchanged Infection production PBO 09FD668CC767F59BD07628B6173F4E0CB945D17966EA6DA4146FE6AA975D1A1C. Redux candidate PBO F828C0F035266CFA93B165FAA91ECA6877108DB6FE09D66F699976E7D6C3551D (branch commit a7fbc5d). No clearance bypass or roster-zeroing test shortcut was used. The fix keeps server transactions local and delivers updates to clients; late-join requests obtain current state.

This is native dedicated-server lifecycle evidence with controlled defender deaths, not player combat, UI or performance acceptance. Separate generic multiplayer evidence is in A3U-Redux-Fixes evidence/garrison-sync-dev22. Server PID 46820 identity verified, stopped after completion, and absence independently verified. Manual Dev9 untouched.
