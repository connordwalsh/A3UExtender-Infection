// Native scene corpse/blood creation with exact ownership before initialization.
// The optional role must be an entry returned by liberationBodyRoles, never an
// arbitrary class. Killing is atomic with creation, before WBK's scheduled AI.
params [["_record",createHashMap,[createHashMap]],["_position",[],[[]]],
    ["_role",[],[[]]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createLiberationBody,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["sceneBodiesRetired",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
if (_name == "" || {!(_town in allMapMarkers)} || {isNil "sidesX"}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {sidesX getVariable [_town,sideUnknown] != west}) exitWith {[false,"town"]};
private _categories = call A3I_fnc_liberationBodyRoles;
if (_categories isEqualTo []) exitWith {[false,"body_pool"]};
if (_role isEqualTo []) then {_role = selectRandom (selectRandom _categories)};
if ((_categories findIf {_role in _x}) == -1) exitWith {[false,"role"]};
_role params ["_key","_unitType","_class"];
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[false,"hq_unavailable"]};
private _safety = [_position,_class,call A3I_fnc_spawnObservers,getMarkerPos _hq] call A3I_fnc_positionSafety;
if !(_safety # 0) exitWith {_safety};
if !(_position inArea _town) exitWith {[false,"town_bounds"]};
private _bodies = _record getOrDefault ["sceneBodies",[]];
private _groups = _record getOrDefault ["sceneBodyGroups",[]];
private _bloods = _record getOrDefault ["sceneBlood",[]];
_record set ["sceneBodies",_bodies];
_record set ["sceneBodyGroups",_groups];
_record set ["sceneBlood",_bloods];
private _group = createGroup [civilian,false];
if (isNull _group) exitWith {[false,"group_limit"]};
_groups pushBack _group;
_group setVariable ["A3I_sceneBodyId",_name];
private _faction = missionNamespace getVariable ("A3A_faction_" + _key);
private _identity = [_faction,_unitType] call A3A_fnc_createRandomIdentity;
private _body = [_group,_unitType,_position,[],0,"NONE",_identity] call A3A_fnc_createUnit;
if (isNull _body) exitWith {[false,"body_creation"]};
_bodies pushBack _body;
_body setVariable ["A3I_sceneBodyId",_name];
_body setDir random 360;
_body setDamage 1;
if (alive _body) exitWith {[false,"body_not_dead"]};
if (!(_body inArea _town) || {_body distance2D _position > 0.5}) exitWith {
    deleteVehicle _body;
    [false,"placement_changed"]
};
private _blood = createVehicle [selectRandom ["BloodPool_01_Large_New_F",
    "BloodSplatter_01_Large_New_F","BloodSplatter_01_Medium_New_F","BloodPool_01_Medium_New_F"],
    getPosATL _body,[],0,"CAN_COLLIDE"];
if (isNull _blood) exitWith {[false,"blood_creation"]};
_bloods pushBack _blood;
_blood setVariable ["A3I_sceneBodyId",_name];
[true,""]
