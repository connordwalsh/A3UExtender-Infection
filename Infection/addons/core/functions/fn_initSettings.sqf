// CBA is a required dependency. Server-owned limits do not activate the faction.
[
    "A3I_activeLimit", "SLIDER",
    ["Active infected limit", "Maximum living infected and pending spawns created by Infection. Lowering this waits for existing units to leave; it does not remove them."],
    "Antistasi Ultimate: Infection", [1,48,40,0], 2, {}, false
] call CBA_fnc_addSetting;
[
    "A3I_contextLimit", "SLIDER",
    ["Infected per location or event", "Shared limit for all Infection groups belonging to one location or event. The active infected limit still applies."],
    "Antistasi Ultimate: Infection", [1,24,12,0], 2, {}, false
] call CBA_fnc_addSetting;
[
    "A3I_budgetDiagnostics", "CHECKBOX",
    ["Spawn diagnostics", "Record spawn reservation decisions in the server log."],
    "Antistasi Ultimate: Infection", false, 2, {}, false
] call CBA_fnc_addSetting;
