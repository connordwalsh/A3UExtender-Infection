// Scheduled assembly of the retained native townBattle scene. Every component
// owns its objects before initialization; an interrupted parent can retire the
// partial scene. Unsafe placements are skipped, never replaced by an origin.
params [["_record",createHashMap,[createHashMap]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {[false,"server_local_scheduled"]};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["sceneRetired",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
private _vip = _record getOrDefault ["vip",objNull];
if (_name == "" || {!(_town in allMapMarkers)} || {isNull _vip} || {!alive _vip}
    || {!local _vip} || {!(_record getOrDefault ["survivorReady",false])}
    || {_vip getVariable ["A3I_liberationId",""] != _name}
    || {isNil "sidesX"} || {sidesX getVariable [_town,sideUnknown] != west})
    exitWith {[false,"survivor"]};
if (_record getOrDefault ["sceneStarted",false]) exitWith {
    [_record getOrDefault ["sceneReady",false],"existing"]
};
private _wreckClasses = call A3I_fnc_liberationWreckClasses;
private _bodyRoles = call A3I_fnc_liberationBodyRoles;
if (_wreckClasses isEqualTo [] || {_bodyRoles isEqualTo []}
    || {call A3I_fnc_liberationVehicleClasses isEqualTo []}) exitWith {[false,"scene_pools"]};
private _civilian = missionNamespace getVariable ["A3A_faction_civ",createHashMap];
if (!(_civilian isEqualType createHashMap)
    || {!((_civilian getOrDefault ["animations",[]]) isEqualType createHashMap)}
    || {!((_civilian getOrDefault ["variants",[]]) isEqualType createHashMap)}
    || {isNil "destroyedBuildings"}) exitWith {[false,"campaign_not_ready"]};
private _entered = false;
isNil {
    if !(_record getOrDefault ["sceneStarted",false]) then {
        _record set ["sceneStarted",true]; _record set ["sceneReady",false];
        _record set ["sceneFailures",[]]; _record set ["sceneClustersBuilt",0];
        _entered = true;
    };
};
if (!_entered) exitWith {[false,"existing"]};
private _vehicleResult = [_record] call A3I_fnc_createLiberationVehicle;
if !(_vehicleResult # 0) exitWith {[false,"survivor_vehicle_" + (_vehicleResult # 1)]};
private _stillActive = {
    [west] call A3I_fnc_isActive && {alive _vip}
        && {_record getOrDefault ["outcome","pending"] == "pending"}
        && {sidesX getVariable [_town,sideUnknown] == west}
        && {time < _record getOrDefault ["expiresAt",1e10]}
};
private _size = [_town] call A3A_fnc_sizeMarker;
private _center = getMarkerPos _town;
private _radius = (50 min _size) * 1.5;
private _protected = [];
{_protected append (missionNamespace getVariable [_x,[]])}
    forEach ["antennas","antennasDead","A3A_milAdministrations","A3A_destroyedMilAdministrations"];
private _sites = [];
{_sites append (missionNamespace getVariable [_x,[]])}
    forEach ["airportsX","outposts","milbases","seaports","factories","resourcesX","milAdministrationsX"];
private _houses = ((nearestObjects [getPosATL _vip,["House"],_size])
    select {(_x buildingPos -1) isNotEqualTo []}) select [0,100];
_houses = _houses select {
    private _house = _x;
    _house inArea _town && {!(_house in _protected)}
        && {(_sites findIf {_x in allMapMarkers && {_house inArea _x}}) == -1}
};
// Capture ground centers before a destroyed original sinks under its ruin.
private _fireCenters = _houses apply {private _position = getPosATL _x; _position set [2,0]; _position};
{
    if !(call _stillActive) exitWith {};
    if (random 100 < 20) then {
        private _result = [_record,_x] call A3I_fnc_decorateLiberationBuilding;
        if !(_result # 0) then {(_record get "sceneFailures") pushBackUnique ("building_" + (_result # 1))};
    };
    sleep 0.01;
} forEach _houses;
private _lastCluster = round (random [4,5,6]);
_record set ["sceneClustersPlanned",_lastCluster + 1];
for "_cluster" from 0 to _lastCluster do {
    if !(call _stillActive) exitWith {};
    private _class = selectRandom _wreckClasses;
    private _search = [_center,1,_radius,_class] call A3I_fnc_findSpawnPosition;
    private _wreckPosition = _search # 0;
    if (_wreckPosition isNotEqualTo []) then {
        private _result = [_record,_wreckPosition,_class] call A3I_fnc_createLiberationWreck;
        if !(_result # 0) then {(_record get "sceneFailures") pushBackUnique ("wreck_" + (_result # 1))};
    } else {(_record get "sceneFailures") pushBackUnique ("wreck_" + (_search # 1))};
    private _bodyCenter = if (_wreckPosition isEqualTo []) then {_center} else {_wreckPosition};
    private _amount = round (random [2,3,5]);
    // Native createDeadSoldiers uses an inclusive randomized loop.
    for "_body" from 0 to (random [_amount - 1,_amount,_amount + 1]) do {
        if !(call _stillActive) exitWith {};
        private _role = selectRandom (selectRandom _bodyRoles);
        private _position = ([_bodyCenter,2,35,_role # 2] call A3I_fnc_findSpawnPosition) # 0;
        if (_position isEqualTo []) then {(_record get "sceneFailures") pushBackUnique "body_placement"; continue};
        private _result = [_record,_position,_role] call A3I_fnc_createLiberationBody;
        if !(_result # 0) then {(_record get "sceneFailures") pushBackUnique ("body_" + (_result # 1))};
    };
    if (_fireCenters isNotEqualTo [] && {call _stillActive}) then {
        private _fireCenter = selectRandom _fireCenters;
        for "_fire" from 0 to (random [1,2,3]) do {
            private _position = ([_fireCenter,2,50,"Land_HelipadEmpty_F"] call A3I_fnc_findSpawnPosition) # 0;
            if (_position isEqualTo []) then {(_record get "sceneFailures") pushBackUnique "fire_placement"; continue};
            private _result = [_record,_position,"BigDestructionFire"] call A3I_fnc_createLiberationFire;
            if !(_result # 0) then {(_record get "sceneFailures") pushBackUnique ("fire_" + (_result # 1))};
        };
    };
    _record set ["sceneClustersBuilt",_cluster + 1];
    sleep 3;
};
if !(call _stillActive) exitWith {[false,"interrupted"]};
_record set ["sceneReady",true];
[true,""]
