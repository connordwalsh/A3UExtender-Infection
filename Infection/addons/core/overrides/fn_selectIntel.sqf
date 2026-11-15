if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalSelectIntel};
if (!isServer) exitWith {-1};
if (isRemoteExecuted || {!canSuspend}) exitWith {
    [{_this spawn A3I_fnc_selectInfectionIntel},+_this] call CBA_fnc_execNextFrame;
    -1
};
_this call A3I_fnc_selectInfectionIntel
