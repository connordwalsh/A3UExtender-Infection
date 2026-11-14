// Adapted from native createFire. Record each emitter at birth, rather than
// returning an unowned partial result if later scene initialization fails.
params [["_record",createHashMap,[createHashMap]],["_position",[],[[]]],
    ["_type","BigDestructionFire",[""]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createLiberationFire,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["sceneEffectsRetired",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
if (_name == "" || {!(_town in allMapMarkers)} || {sidesX getVariable [_town,sideUnknown] != west})
    exitWith {[false,"town"]};
if !(_type in ["BigDestructionFire","SmallDestructionFire","Smoke"]) exitWith {[false,"effect_type"]};
if (count _position != 3 || {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1}
    || {_position # 2 < 0} || {!(_position inArea _town)} || {surfaceIsWater _position})
    exitWith {[false,"position"]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if (!(_hq in allMapMarkers) || {_position distance2D getMarkerPos _hq < 200})
    exitWith {[false,"hq"]};
if (((call A3I_fnc_spawnObservers) findIf {
    _x distance2D _position < 150
        || {[vehicle _x,"VIEW",_x] checkVisibility [eyePos _x,ATLToASL _position] > 0.01}
}) != -1) exitWith {[false,"observed"]};
// These special engine objects cannot store setVariable tags. Keep the exact
// owning record and array in the server registry instead; a copied record with
// the same name must not take over effects already created for another parent.
private _owners = missionNamespace getVariable ["A3I_liberationEffects",createHashMap];
private _owned = _owners getOrDefault [_name,[]];
private _effects = _record getOrDefault ["sceneEffects",[]];
if ((_owned isNotEqualTo [] && {!((_owned # 0) isEqualRef _record)
    || {!((_owned # 1) isEqualRef _effects)}})
    || {_owned isEqualTo [] && {_effects isNotEqualTo []}}) exitWith {[false,"ownership"]};
if (_owned isEqualTo []) then {_owners set [_name,[_record,_effects]]};
missionNamespace setVariable ["A3I_liberationEffects",_owners];
_record set ["sceneEffects",_effects];
if (_type == "Smoke") exitWith {
    // The native class owns three local effects on each machine and deletes
    // them through its Deleted handler. Own its networked anchor, not copies of
    // those local objects. Config initialization also applies to joining clients.
    private _anchor = createVehicle ["test_EmptyObjectForSmoke",_position,[],0,"CAN_COLLIDE"];
    if (isNull _anchor) exitWith {[false,"smoke_creation"]};
    _effects pushBack _anchor;
    _anchor setPosATL _position;
    [true,""]
};
private _emitter = "#particlesource" createVehicle _position;
if (isNull _emitter) exitWith {[false,"particle_creation"]};
_effects pushBack _emitter;
private _light = "#lightpoint" createVehicle _position;
if (isNull _light) exitWith {[false,"light_creation"]};
_effects pushBack _light;
// A single object-bound JIP call retains all four settings. Separate calls with
// the same object as JIP id replace each other for clients joining later.
[_emitter,_light,_type] remoteExecCall ["A3I_fnc_applyLiberationFire",0,_emitter];
[true,""]
