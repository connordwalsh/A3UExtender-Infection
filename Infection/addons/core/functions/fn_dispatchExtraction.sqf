// Legacy rescue endpoints now dispatch only eligible infected sites.
params [["_source","",[""]]];
if (!([west] call A3I_fnc_isActive)) exitWith {};
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        [_source] remoteExec ["A3I_fnc_dispatchExtraction",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2] + (missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
[{
    _this spawn {
        params ["_source"];
        if (_source == "") exitWith {};
        [_source] call A3I_fnc_startExtraction;
    };
},[_source]] call CBA_fnc_execNextFrame;
