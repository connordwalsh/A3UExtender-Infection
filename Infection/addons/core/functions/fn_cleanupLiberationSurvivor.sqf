// Retire only this mission's actor and original CIV group. A recruited survivor
// may belong to a player's group; that group never enters our cleanup queue.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_cleanupLiberationSurvivor,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["survivorCleaned",false]) exitWith {[true,"already_cleaned"]};
private _name = _record getOrDefault ["name",""];
if !(_name isEqualType "" && {_name != ""}) exitWith {[false,"record"]};
private _vip = _record getOrDefault ["vip",objNull];
private _group = _record getOrDefault ["vipGroup",grpNull];
if ((!isNull _vip && {_vip getVariable ["A3I_liberationId",""] != _name})
    || {!isNull _group && {_group getVariable ["A3I_liberationId",""] != _name}})
    exitWith {[false,"ownership"]};
if (!isNull _vip && {((call A3I_fnc_spawnObservers) findIf {
    _x distance2D _vip < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)
}) != -1}) exitWith {[false,"observed"]};
_record set ["survivorCleaned",true];
if (!isNull _vip) then {
    [_vip,"remove"] remoteExec ["A3A_fnc_flagaction",[teamPlayer,civilian],_vip];
    if (local _vip) then {_vip call BIS_fnc_ambientAnim__terminate};
    deleteVehicle _vip;
};
// Never add group _vip here: recruitment transfers it to the rescuer's group.
[[_group]] call A3I_fnc_cleanupGroups;
[true,""]
