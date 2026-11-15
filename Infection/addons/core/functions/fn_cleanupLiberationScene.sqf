// One retryable owner for complete or interrupted scene teardown. The native
// survivor vehicle is retained; other components retire only their own objects.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_cleanupLiberationScene,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["sceneRetired",false]) exitWith {[true,"already_retired"]};
private _name = _record getOrDefault ["name",""];
if (_name == "") exitWith {[false,"record"]};
private _registered = (missionNamespace getVariable ["A3I_liberations",createHashMap]) getOrDefault [_name,createHashMap];
if (count _registered > 0 && {!(_registered isEqualRef _record)}) exitWith {[false,"ownership"]};
if (count _registered > 0 && {!(_record getOrDefault ["settled",false])}) exitWith {[false,"mission_active"]};
private _town = _record getOrDefault ["town",""];
if (!isNil "spawner" && {spawner getVariable [_town,2] != 2}) exitWith {[false,"town_active"]};
private _vehicle = _record getOrDefault ["vipVehicle",objNull];
if (!isNull _vehicle && {_vehicle getVariable ["A3I_liberationVehicleId",""] != _name})
    exitWith {[false,"vehicle_ownership"]};
private _survivor = [_record] call A3I_fnc_cleanupLiberationSurvivor;
if !(_survivor # 0) exitWith {_survivor};
private _pending = [];
{
    private _result = [_record] call _x;
    if !(_result # 0) then {_pending pushBack (_result # 1)};
} forEach [A3I_fnc_cleanupLiberationEffects,A3I_fnc_cleanupLiberationBodies,
    A3I_fnc_cleanupLiberationWrecks,A3I_fnc_cleanupLiberationBuildings];
if (!(_record getOrDefault ["vehicleReleased",false])) then {
    if (!isNull _vehicle && {!(_record getOrDefault ["vehicleReady",false])}) then {
        if ((crew _vehicle findIf {alive _x}) != -1 || {!isNull attachedTo _vehicle}
            || {ropesAttachedTo _vehicle isNotEqualTo []}
            || {((call A3I_fnc_spawnObservers) findIf {
                _x distance2D _vehicle < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)
            }) != -1}) then {_pending pushBack "vehicle_in_use"}
        else {deleteVehicle _vehicle; _record set ["vehicleReleased",true]};
    } else {
        // Native spawnVehicle leaves ownerSide unset; VEHdespawner defaults it
        // to the Rebel side and immediately returns. Keep that usable vehicle.
        // Native preparePostMortem already handles a vehicle that was destroyed.
        _record set ["vehicleReleased",true];
    };
};
if (_pending isNotEqualTo []) exitWith {[false,_pending # 0]};
_record set ["sceneRetired",true];
[true,""]
