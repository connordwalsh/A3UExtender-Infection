// Apply temporary scene damage only to an intact, ordinary, unoccupied house.
// The optional damage value lets the scene retain native partial/ruin choices.
params [["_record",createHashMap,[createHashMap]],["_building",objNull,[objNull]],
    ["_damage",-1,[0]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_damageLiberationBuilding,_this] call CBA_fnc_directCall};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["sceneBuildingsRetired",false]})
    exitWith {[false,"inactive"]};
private _name = _record getOrDefault ["name",""];
private _town = _record getOrDefault ["town",""];
if (_name == "" || {!(_town in allMapMarkers)} || {isNil "sidesX"}
    || {!(_town in (missionNamespace getVariable ["citiesX",[]]))}
    || {sidesX getVariable [_town,sideUnknown] != west}) exitWith {[false,"town"]};
if (_damage == -1) then {_damage = random [0.7,0.9,1]};
if (!finite _damage || {_damage <= 0} || {_damage > 1}) exitWith {[false,"damage"]};
if (isNull _building || {!local _building} || {!(_building isKindOf "House")}
    || {_building isKindOf "Ruins"}) exitWith {[false,"building"]};
private _owners = missionNamespace getVariable ["A3I_liberationBuildings",createHashMap];
private _owned = _owners getOrDefault [_name,[]];
private _entries = _record getOrDefault ["sceneBuildings",[]];
if (!(_entries isEqualType []) || {_owned isEqualTo [] && {_entries isNotEqualTo []}}
    || {_owned isNotEqualTo [] && {!((_owned # 0) isEqualRef _record)
        || {!((_owned # 1) isEqualRef _entries)}}}) exitWith {[false,"ownership"]};
private _existing = _building getVariable ["A3I_sceneBuilding",createHashMap];
if (count _existing > 0) exitWith {
    if ((_entries findIf {_x isEqualRef _existing}) != -1) then {[true,"already_applied"]}
    else {[false,"ownership"]}
};
if (isNil "destroyedBuildings" || {!(destroyedBuildings isEqualType [])})
    exitWith {[false,"campaign_not_ready"]};
private _hitPoints = getAllHitPointsDamage _building;
if (!alive _building || {isObjectHidden _building} || {!isDamageAllowed _building}
    || {damage _building > 0} || {(_hitPoints param [2,[]]) findIf {_x > 0} != -1}
    || {!isNull (_building getVariable ["ruins",objNull])}
    || {!isNull (_building getVariable ["BIS_fnc_createRuin_ruin",objNull])}
    || {_building in destroyedBuildings}) exitWith {[false,"existing_damage"]};
if ((_building buildingPos -1) isEqualTo []) exitWith {[false,"not_enterable"]};
private _protected = [];
{_protected append (missionNamespace getVariable [_x,[]])}
    forEach ["antennas","antennasDead","A3A_milAdministrations","A3A_destroyedMilAdministrations"];
if (_building in _protected) exitWith {[false,"protected"]};
private _position = getPosATL _building;
if !(_position inArea _town) exitWith {[false,"town_bounds"]};
private _sites = [];
{_sites append (missionNamespace getVariable [_x,[]])}
    forEach ["airportsX","outposts","milbases","seaports","factories","resourcesX","milAdministrationsX"];
if ((_sites findIf {_x in allMapMarkers && {_position inArea _x}}) != -1)
    exitWith {[false,"protected_site"]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if (!(_hq in allMapMarkers) || {_position distance2D getMarkerPos _hq < 200})
    exitWith {[false,"hq"]};
if (((call A3I_fnc_spawnObservers) findIf {
    _x distance2D _position < 150
        || {[vehicle _x,"VIEW",_x] checkVisibility [eyePos _x,getPosASL _building vectorAdd [0,0,3]] > 0.01}
}) != -1) exitWith {[false,"observed"]};
private _clearance = (sizeOf typeOf _building / 2) max 10;
if ((nearestObjects [_position,["CAManBase","LandVehicle","Air","Ship"],_clearance + 5]
    findIf {alive _x}) != -1) exitWith {[false,"occupied"]};
private _animations = [];
private _available = (animationNames _building) apply {toLower _x};
{
    if (toLower _x in _available) then {_animations pushBack [_x,_building animationPhase _x]};
} forEach ["door_1A_move","door_1B_move","door_2_rot","door_3_rot"];
private _entry = createHashMapFromArray [["building",_building],["position",getPosWorld _building],
    ["direction",vectorDir _building],["up",vectorUp _building],["animations",_animations],
    ["appliedAt",diag_tickTime],["lastChangeAt",diag_tickTime],["restored",false],
    ["clearance",_clearance + 5],["name",_name],["ruin",objNull]];
if (_owned isEqualTo []) then {_owners set [_name,[_record,_entries]]};
missionNamespace setVariable ["A3I_liberationBuildings",_owners];
_record set ["sceneBuildings",_entries];
_entries pushBack _entry;
_building setVariable ["A3I_sceneBuilding",_entry];
if (isNil "A3I_liberationBuildingHandler") then {
    A3I_liberationBuildingHandler = addMissionEventHandler ["BuildingChanged",A3I_fnc_liberationBuildingChanged];
};
// Ownership and restoration state exist before model changes can fire events.
_building setDamage _damage;
{_building animate [_x # 0,1]} forEach _animations;
[true,""]
