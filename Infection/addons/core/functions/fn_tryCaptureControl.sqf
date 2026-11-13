// Atomic control-only ownership transaction. No flag, garrison, reward or QRF path.
params ["_marker","_record"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {sideUnknown};
if (canSuspend) exitWith {[A3I_fnc_tryCaptureControl,_this] call CBA_fnc_directCall};
if !(_record getOrDefault ["kind",""] == "Control" && {_marker in controlsX}
    && {!(_record getOrDefault ["cleaned",true])}
    && {(A3I_sites getOrDefault [_marker,createHashMap]) getOrDefault ["id",-1] == _record get "id"}
    && {[sidesX getVariable [_marker,sideUnknown]] call A3I_fnc_isActive}
    && {spawner getVariable [_marker,2] == 0} && {_record get "fault" == ""}
    && {_record get "spawnedAny"} && {_record get "queue" isEqualTo []}) exitWith {sideUnknown};
private _blocked = (_record get "units") findIf {
    [_x] call A3A_fnc_canFight && { !(_x getVariable ["A3I_controlArrived",false])
        || {[_x,_marker] call A3A_fnc_canConquer} }
};
if (_blocked != -1) exitWith {sideUnknown};
private _contenders = allUnits select {side group _x in [teamPlayer,Invaders]
    && {!captive _x} && {[_x,_marker] call A3A_fnc_canConquer}};
if (_contenders isEqualTo []) exitWith {sideUnknown};
private _nearest = [_contenders,getMarkerPos _marker] call BIS_fnc_nearestPosition;
private _winner = side group _nearest;
_record set ["captured",_winner];
sidesX setVariable [_marker,_winner,true];
if (_winner == Invaders) then {[-5,0,getMarkerPos _marker] remoteExec ["A3A_fnc_citySupportChange",2]};
if (_record get "road") then {
    ["TaskSucceeded",["","Roadblock Destroyed"]] remoteExec ["BIS_fnc_showNotification",_winner];
    ["TaskFailed",["","Roadblock Lost"]] remoteExec ["BIS_fnc_showNotification",west];
};
_winner
