// Remove only this scene's unclaimed vehicles. Native Rebel capture transfers
// ownership; player vehicles, occupied vehicles and attached cargo are retained.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_cleanupLiberationWrecks,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["sceneWrecksRetired",false]) exitWith {[true,"already_retired"]};
private _name = _record getOrDefault ["name",""];
private _wrecks = _record getOrDefault ["sceneWrecks",[]];
if (_name == "" || {!(_wrecks isEqualType [])} || {(_wrecks findIf {
    !(_x isEqualType objNull) || {!isNull _x && {_x getVariable ["A3I_sceneWreckId",""] != _name}}
}) != -1}) exitWith {[false,"ownership"]};
private _pending = [];
private _observers = call A3I_fnc_spawnObservers;
{
    private _vehicle = _x;
    if (isNull _vehicle) then {continue};
    if (_vehicle getVariable ["ownerSide",sideUnknown] == teamPlayer) then {continue};
    if ((crew _vehicle findIf {alive _x}) != -1 || {!isNull attachedTo _vehicle}
        || {ropesAttachedTo _vehicle isNotEqualTo []}
        || {(_observers findIf {_x distance2D _vehicle < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)}) != -1})
        then {_pending pushBack _vehicle; continue};
    deleteVehicle _vehicle;
} forEach _wrecks;
_record set ["sceneWrecks",_pending];
if (_pending isNotEqualTo []) exitWith {[false,"in_use"]};
_record set ["sceneWrecksRetired",true];
[true,""]
