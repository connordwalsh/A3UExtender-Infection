// Other categories retain native dispatch until their replacement is ready.
if (!isServer) exitWith {};
if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalMissionRequest};
private _type = _this param [0,"RAN"];
if (_type in ["DES","RAN"]) exitWith {};
if !(_type in ["CON","CONVOY"]) exitWith {_this call A3I_fnc_originalMissionRequest};
private _arguments = [_this param [1,clientOwner,[0]],_this param [2,false,[false]]];
if (_type == "CONVOY") exitWith {
    if (isRemoteExecuted || {!canSuspend}) then {
        [{_this spawn A3I_fnc_requestInterception},_arguments] call CBA_fnc_execNextFrame;
    } else {_arguments call A3I_fnc_requestInterception};
};
if (isRemoteExecuted || {!canSuspend}) exitWith {
    [{_this spawn A3I_fnc_requestLiquidation},_arguments] call CBA_fnc_execNextFrame;
};
_arguments call A3I_fnc_requestLiquidation
