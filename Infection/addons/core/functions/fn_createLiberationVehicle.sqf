// Local scene component; creates the native survivor's usable vehicle without
// ever creating a temporary driver or turret crew. The parent owns it at birth.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_createLiberationVehicle,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["survivorCleaned",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
private _vip = _record getOrDefault ["vip",objNull];
if (_name == "" || {!(_town in allMapMarkers)}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {sidesX getVariable [_town,sideUnknown] != west}
    || {isNull _vip} || {!local _vip} || {!alive _vip}
    || {!(_record getOrDefault ["survivorReady",false])}
    || {_vip getVariable ["A3I_liberationId",""] != _name}) exitWith {[false,"survivor"]};
if (_record getOrDefault ["vehicleAttempted",false]) exitWith {
    private _vehicle = _record getOrDefault ["vipVehicle",objNull];
    [!isNull _vehicle && {_vehicle getVariable ["A3I_liberationVehicleId",""] == _name}
        && {_record getOrDefault ["vehicleReady",false]},"existing"]
};
private _categories = call A3I_fnc_liberationVehicleClasses;
if (_categories isEqualTo []) exitWith {[false,"vehicle_pool"]};
private _class = selectRandom (selectRandom _categories);
private _center = getPosATL _vip;
private _position = [];
private _hqMarker = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hqMarker in allMapMarkers) exitWith {[false,"hq_unavailable"]};
private _observers = call A3I_fnc_spawnObservers;
// Use an actual nearby road when safe; never getPos objNull as a fallback.
private _road = [_center,25] call BIS_fnc_nearestRoad;
if (!isNull _road) then {
    private _roadPosition = getPosATL _road; _roadPosition set [2,0];
    if (_roadPosition distance2D _center >= 8 && {_roadPosition distance2D _center <= 25}
        && {_roadPosition inArea _town}
        && {([_roadPosition,_class,_observers,getMarkerPos _hqMarker] call A3I_fnc_positionSafety) # 0})
        then {_position = _roadPosition};
};
if (_position isEqualTo []) then {
    _position = ([_center,8,25,_class] call A3I_fnc_findSpawnPosition) # 0;
};
if (_position isEqualTo [] || {!(_position inArea _town)}) exitWith {[false,"placement"]};
_record set ["vehicleAttempted",true];
private _vehicle = createVehicle [_class,_position,[],0,"NONE"];
_record set ["vipVehicle",_vehicle];
if (isNull _vehicle) exitWith {[false,"creation_failed"]};
_vehicle setVariable ["A3I_liberationVehicleId",_name];
// The engine may move a NONE placement. Reject an out-of-bounds result rather
// than moving the vehicle into an unchecked position beside the survivor.
if (!alive _vehicle || {surfaceIsWater getPosATL _vehicle}
    || {!(_vehicle inArea _town)} || {_vehicle distance2D _center > 25}
    || {_vehicle distance2D _position > 0.5}) exitWith {
    deleteVehicle _vehicle;
    [false,"placement_changed"]
};
_vehicle setDir random 360;
[_vehicle] call A3A_fnc_preparePostMortem;
_vehicle lock 0;
// Match native spawnVehicle's association with the original survivor group.
(_record get "vipGroup") addVehicle _vehicle;
_record set ["vehicleReady",true];
[true,""]
