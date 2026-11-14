// Direct legacy conquest calls are server-owned clearance requests. An HC may
// relay only a server-origin call; server accepts only registered HC owners.
params [["_target","",[""]]];
if (!([west] call A3I_fnc_isActive)) exitWith {};
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        [_target] remoteExec ["A3I_fnc_dispatchLiquidation",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2] + (missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
[{_this spawn A3I_fnc_startLiquidation},[_target]] call CBA_fnc_execNextFrame;
