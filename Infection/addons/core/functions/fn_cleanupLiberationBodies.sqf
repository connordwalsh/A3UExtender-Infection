// Own only the scene's original corpses, blood objects and temporary groups.
// Never collect a body by proximity or delete another group's living members.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_cleanupLiberationBodies,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["sceneBodiesRetired",false]) exitWith {[true,"already_retired"]};
private _name = _record getOrDefault ["name",""];
private _bodies = _record getOrDefault ["sceneBodies",[]];
private _groups = _record getOrDefault ["sceneBodyGroups",[]];
private _bloods = _record getOrDefault ["sceneBlood",[]];
if (_name == "" || {!(_bodies isEqualType [])} || {!(_groups isEqualType [])}
    || {!(_bloods isEqualType [])}) exitWith {[false,"record"]};
private _objects = _bodies + _bloods;
if ((_objects findIf {!(_x isEqualType objNull)
        || {!isNull _x && {_x getVariable ["A3I_sceneBodyId",""] != _name}}}) != -1
    || {(_groups findIf {!(_x isEqualType grpNull)
        || {!isNull _x && {_x getVariable ["A3I_sceneBodyId",""] != _name}}}) != -1})
    exitWith {[false,"ownership"]};
private _observers = call A3I_fnc_spawnObservers;
if ((_objects findIf {
    private _object = _x;
    !isNull _object && {(_observers findIf {
        _x distance2D _object < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)
    }) != -1}
}) != -1) exitWith {[false,"observed"]};
_record set ["sceneBodiesRetired",true];
{deleteVehicle _x} forEach _objects;
[_groups] call A3I_fnc_cleanupGroups;
_record set ["sceneBodies",[]];
_record set ["sceneBlood",[]];
_record set ["sceneBodyGroups",[]];
[true,""]
