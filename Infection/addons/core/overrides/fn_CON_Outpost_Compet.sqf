if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalCompetitiveMission};
_this call A3I_fnc_dispatchLiquidation
