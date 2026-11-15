// Real empty land vehicle and native postmortem initialization. No scenery,
// player collection, garage/save behavior or Redux placement acceptance.
private _savedVehicleReb = A3A_faction_reb;
A3A_faction_reb = createHashMapFromArray [
    ["vehiclesBasic",["C_SUV_01_F"]],
    ["vehiclesLightUnarmed",["C_Offroad_01_F","missing_vehicle",17,"B_UGV_01_F",
        "B_Heli_Light_01_F","C_Boat_Civil_01_F","C_man_1"]]
];
private _categories = call A3I_fnc_liberationVehicleClasses;
["lib_vehicle_valid_native_categories",count _categories == 5
    && {{_x isEqualTo ["C_Offroad_01_F"]} count _categories == 1}
    && {{_x isEqualTo ["C_SUV_01_F"]} count _categories == 4}] call _check;
A3A_faction_reb = createHashMapFromArray [["vehiclesBasic",[]],["vehiclesLightArmed","invalid"]];
["lib_vehicle_empty_and_malformed_pools",call A3I_fnc_liberationVehicleClasses isEqualTo []] call _check;
A3A_faction_reb = [];
["lib_vehicle_nonmap_template_refused",call A3I_fnc_liberationVehicleClasses isEqualTo []] call _check;
A3A_faction_reb = createHashMap;
{
    private _value = _savedVehicleReb get _x;
    if (!isNil "_value") then {A3A_faction_reb set [_x,_value]};
} forEach keys _savedVehicleReb;
A3A_faction_reb set ["vehiclesBasic",["C_Offroad_01_F"]];
private _record = call _newSurvivor;
[_record] call A3I_fnc_createLiberationSurvivor;
private _vip = _record get "vip";
_vip enableSimulationGlobal false;
private _beforeVehicles = entities "LandVehicle";
private _beforeActors = entities "CAManBase";
private _beforeGroups = allGroups;
A3I_test_sceneCrewCreated = []; A3I_test_sceneGroupsCreated = [];
private _groupCreatedHandler = addMissionEventHandler ["GroupCreated",{
    params ["_group"]; A3I_test_sceneGroupsCreated pushBack str _group;
}];
private _createdHandler = addMissionEventHandler ["EntityCreated",{
    private _entity = if (_this isEqualType []) then {_this param [0,objNull]} else {_this};
    if (_entity isKindOf "CAManBase") then {A3I_test_sceneCrewCreated pushBack typeOf _entity};
}];
[_record] remoteExecCall ["A3I_fnc_createLiberationVehicle",2]; sleep 0.3;
["lib_vehicle_remote_create_refused",entities "LandVehicle" isEqualTo _beforeVehicles
    && {!(_record getOrDefault ["vehicleAttempted",false])}] call _check;
private _foreign = createHashMapFromArray [["name","foreign"],["town",_town],["vip",_vip],["survivorReady",true]];
["lib_vehicle_foreign_survivor_refused",!(([_foreign] call A3I_fnc_createLiberationVehicle) # 0)
    && {entities "LandVehicle" isEqualTo _beforeVehicles}] call _check;
A3A_faction_reb set ["vehiclesBasic",[]];
private _result = [_record] call A3I_fnc_createLiberationVehicle;
["lib_vehicle_missing_pool_has_no_fallback",!(_result # 0) && {_result # 1 == "vehicle_pool"}
    && {!(_record getOrDefault ["vehicleAttempted",false])}] call _check;
A3A_faction_reb set ["vehiclesBasic",["C_Offroad_01_F"]];
private _hqPosition = getMarkerPos respawnTeamPlayer;
respawnTeamPlayer setMarkerPos getPosATL _vip;
_result = [_record] call A3I_fnc_createLiberationVehicle;
["lib_vehicle_unsafe_placement_refused",!(_result # 0) && {_result # 1 == "placement"}
    && {!(_record getOrDefault ["vehicleAttempted",false])}
    && {entities "LandVehicle" isEqualTo _beforeVehicles}] call _check;
respawnTeamPlayer setMarkerPos _hqPosition;
_result = [_record] call A3I_fnc_createLiberationVehicle;
private _vehicle = _record getOrDefault ["vipVehicle",objNull];
["lib_vehicle_real_empty_usable",_result # 0 && {alive _vehicle} && {canMove _vehicle}
    && {fuel _vehicle > 0} && {locked _vehicle == 0} && {crew _vehicle isEqualTo []}
    && {typeOf _vehicle == "C_Offroad_01_F"},[_result,typeOf _vehicle]] call _check;
sleep 0.2;
removeMissionEventHandler ["EntityCreated",_createdHandler];
removeMissionEventHandler ["GroupCreated",_groupCreatedHandler];
["lib_vehicle_no_transient_crew_or_group",A3I_test_sceneCrewCreated isEqualTo []
    && {A3I_test_sceneGroupsCreated isEqualTo []}
    && {(entities "CAManBase") - _beforeActors isEqualTo []}
    && {allGroups - _beforeGroups isEqualTo []},
    [A3I_test_sceneCrewCreated,A3I_test_sceneGroupsCreated,
        entities "CAManBase" isEqualTo _beforeActors,allGroups isEqualTo _beforeGroups,
        count (_beforeActors - entities "CAManBase"),count (_beforeGroups - allGroups)]] call _check;
["lib_vehicle_owned_near_survivor",_vehicle getVariable ["A3I_liberationVehicleId",""] == _record get "name"
    && {_vehicle distance2D _vip <= 25} && {_vehicle inArea _town}] call _check;
_result = [_record] call A3I_fnc_createLiberationVehicle;
["lib_vehicle_creation_idempotent",_result # 0 && {_record get "vipVehicle" == _vehicle}
    && {entities "LandVehicle" - _beforeVehicles isEqualTo [_vehicle]}] call _check;
// The unfinished scene controller is not connected. This fixture owns teardown;
// keeping or claiming the native survivor vehicle needs its later scene tests.
deleteVehicle _vehicle;
private _deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;isNull _vehicle || {diag_tickTime > _deadline}};
["lib_vehicle_deleted_actor_not_recreated",!(([_record] call A3I_fnc_createLiberationVehicle) # 0)
    && {entities "LandVehicle" isEqualTo _beforeVehicles}] call _check;
[_record] call _waitSurvivorCleanup;
A3A_faction_reb = _savedVehicleReb;
