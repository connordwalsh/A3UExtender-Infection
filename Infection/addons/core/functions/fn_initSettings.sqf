// CBA is a required dependency. Server-owned limits do not activate the faction.
[
    "A3I_activeLimit", "SLIDER",
    ["Active infected outside towns", "Shared maximum for living infected and pending spawns outside town infestations. Each infected town separately activates its full population target, up to 200. Lowering this does not remove existing units."],
    "Antistasi Ultimate: Infection", [1,48,40,0], 2, {}, false
] call CBA_fnc_addSetting;
[
    "A3I_contextLimit", "SLIDER",
    ["Infected per non-town location or event", "Shared limit for groups at one non-town location or event. Town infestations use their full population target instead. The active limit outside towns still applies."],
    "Antistasi Ultimate: Infection", [1,24,12,0], 2, {}, false
] call CBA_fnc_addSetting;
[
    "A3I_budgetDiagnostics", "CHECKBOX",
    ["Spawn diagnostics", "Record spawn reservation decisions in the server log."],
    "Antistasi Ultimate: Infection", false, 2, {}, false
] call CBA_fnc_addSetting;
