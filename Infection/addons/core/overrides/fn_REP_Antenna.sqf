// Infected have no repair crews. Leave the destroyed tower and its native save state intact.
if ([west] call A3I_fnc_isActive) exitWith {};
_this call A3I_fnc_originalRepairAntenna
