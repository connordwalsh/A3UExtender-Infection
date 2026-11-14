// Object-bound JIP setup retires with the exact emitter. Special effect objects
// have no variable namespace, so ownership is held in the server's registry.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_cleanupLiberationEffects,_this] call CBA_fnc_directCall};
if (_record getOrDefault ["sceneEffectsRetired",false]) exitWith {[true,"already_retired"]};
private _name = _record getOrDefault ["name",""];
private _effects = _record getOrDefault ["sceneEffects",[]];
private _owners = missionNamespace getVariable ["A3I_liberationEffects",createHashMap];
private _owned = _owners getOrDefault [_name,[]];
if (_name == "" || {!(_effects isEqualType [])}
    || {(_effects findIf {!(_x isEqualType objNull)}) != -1}
    || {_owned isEqualTo [] && {_effects isNotEqualTo []}}
    || {_owned isNotEqualTo [] && {!((_owned # 0) isEqualRef _record)
        || {!((_owned # 1) isEqualRef _effects)}}}) exitWith {[false,"ownership"]};
private _observers = call A3I_fnc_spawnObservers;
if ((_effects findIf {
    private _effect = _x;
    !isNull _effect && {(_observers findIf {
        _x distance2D _effect < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)
    }) != -1}
}) != -1) exitWith {[false,"observed"]};
_record set ["sceneEffectsRetired",true];
{deleteVehicle _x} forEach _effects;
_record set ["sceneEffects",[]];
_owners deleteAt _name;
[true,""]
