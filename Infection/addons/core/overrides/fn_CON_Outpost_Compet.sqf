private _target = _this param [0,"",[""]];
if (!([west] call A3I_fnc_isActive) || {isNil "sidesX"}
    || {sidesX getVariable [_target,sideUnknown] != Invaders})
    exitWith {_this call A3I_fnc_originalCompetitiveMission};
// Native missions may have been scheduled on an HC. Only the server owns this
// horde/task pair; accept an HC relay only from a currently registered HC owner.
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        [_target] remoteExec ["A3A_fnc_CON_Outpost_Compet",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2] + (missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
// spawn inherits remote execution context. Enter a local frame before the worker.
[{_this spawn A3I_fnc_startCompetitiveMission},[_target]] call CBA_fnc_execNextFrame;
