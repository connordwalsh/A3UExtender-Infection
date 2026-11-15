// Native supply entry points provide a town marker.
params [["_target","",[""]]];
if (!([west] call A3I_fnc_isActive)) exitWith {};
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        [_target] remoteExec ["A3I_fnc_dispatchHumanitarianAid",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2] + (missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
if (_target == "") exitWith {};
[{_this spawn A3I_fnc_startHumanitarianAid},[_target]] call CBA_fnc_execNextFrame;
