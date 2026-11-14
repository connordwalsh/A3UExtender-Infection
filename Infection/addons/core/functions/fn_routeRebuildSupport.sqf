// Native rebuilding runs on the requesting player's machine. Its constructors
// are fire-and-forget; remote acceptance/cost cannot be returned synchronously.
params ["_name","_side","_pool","_allowance","_target","_position"];
if (isRemoteExecuted || {!([_side] call A3I_fnc_isActive)}
    || {!(_name isEqualType "")} || {!(_position isEqualType [])}
    || {!(count _position in [2,3])}
    || {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1}) exitWith {-1};
private _sites = (missionNamespace getVariable ["markersX",[]]) select {
    _x in allMapMarkers && {_name find ("REBUILD_QRF_" + _x + "_") == 0}
        && {getMarkerPos _x distance2D _position <= 50}
};
if (count _sites != 1) exitWith {-1};
private _site = _sites # 0;
if (isServer) exitWith {
    private _result = [_site,_position] call A3I_fnc_rebuildSupport;
    if (_result # 0) then {_result # 1} else {-1}
};
if (!hasInterface || {isNull player} || {!isPlayer player}) exitWith {-1};
[_site,+_position,player] remoteExec ["A3I_fnc_receiveRebuildSupport",2];
0
