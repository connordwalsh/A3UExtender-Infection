if (!([west] call A3I_fnc_isActive)) exitWith {_this call A3I_fnc_originalAmbientCivTraffic};
if (!isServer) exitWith {
    if (!hasInterface && {isRemoteExecuted && {remoteExecutedOwner == 2}}) then {
        _this remoteExec ["A3A_fnc_createAmbientCivTraffic",2];
    };
};
if (isRemoteExecuted && {!(remoteExecutedOwner in ([2]+(missionNamespace getVariable ["hcArray",[]])))}) exitWith {};
private _town = _this param [0,"",[""]];
if (isNil "sidesX" || {sidesX getVariable [_town,sideUnknown] != west}) exitWith {
    _this call A3I_fnc_originalAmbientCivTraffic
};
[{_this spawn A3I_fnc_startAbandonedTown},[_town]] call CBA_fnc_execNextFrame;
