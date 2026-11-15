// Direct legacy convoy calls keep their requested route and cannot create a
// human convoy. Only the server or its registered HC relays may dispatch here.
params [["_target","",[""]],["_source","",[""]]];
if (!([west] call A3I_fnc_isActive)) exitWith {};
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        [_target,_source] remoteExec ["A3I_fnc_dispatchInterception",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2] + (missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
[{_this spawn A3I_fnc_startInterception},[_target,_source]] call CBA_fnc_execNextFrame;
