// Real dynamic vanilla houses, model events and repair. Terrain-placed Redux
// houses, connected observers and client presentation are separate acceptance.
private _globalNames = ["destroyedBuildings","antennas","antennasDead","A3A_milAdministrations","A3A_destroyedMilAdministrations"];
private _beforeGlobals = _globalNames apply {[_x,!(isNil _x),missionNamespace getVariable [_x,[]]]};
{missionNamespace setVariable [_x,[]]} forEach _globalNames;
// Pinned native initServer BuildingChanged transaction, installed before ours.
private _nativeHandler = addMissionEventHandler ["BuildingChanged", {
    params ["_oldBuilding","_newBuilding","_isRuin"];
    if (_isRuin) then {
        _oldBuilding setVariable ["ruins",_newBuilding];
        _newBuilding setVariable ["building",_oldBuilding];
        if !(_oldBuilding in antennas || {_oldBuilding in antennasDead || {_oldBuilding in A3A_destroyedMilAdministrations}}) then {
            destroyedBuildings pushBack _oldBuilding;
        };
    };
}];
private _building = createVehicle ["Land_i_House_Small_01_V1_F",getMarkerPos _town vectorAdd [0,70,0],[],0,"CAN_COLLIDE"];
private _damaged = createVehicle ["Land_i_House_Small_01_V1_F",getMarkerPos _town vectorAdd [70,70,0],[],0,"CAN_COLLIDE"];
private _foreignRuinHouse = createVehicle ["Land_i_House_Big_01_V1_F",getMarkerPos _town vectorAdd [-70,70,0],[],0,"CAN_COLLIDE"];
sleep 1;
private _record = call _newSurvivor;
private _result = [_record,objNull,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_invalid_object_refused",!(_result # 0) && {_result # 1 == "building"}] call _check;
_result = [_record,_building,2] call A3I_fnc_damageLiberationBuilding;
["lib_building_invalid_damage_refused",!(_result # 0) && {_result # 1 == "damage"} && {damage _building == 0}] call _check;
_damaged setDamage 0.25;
_result = [_record,_damaged,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_existing_damage_preserved",!(_result # 0) && {_result # 1 == "existing_damage"}
    && {damage _damaged == 0.25} && {isNil {_damaged getVariable "A3I_sceneBuilding"}}] call _check;
antennas = [_building];
_result = [_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_critical_object_refused",!(_result # 0) && {_result # 1 == "protected"} && {damage _building == 0}] call _check;
antennas = []; A3A_milAdministrations = [_building];
_result = [_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_administration_refused",!(_result # 0) && {_result # 1 == "protected"}] call _check;
A3A_milAdministrations = [];
private _savedFactory = getMarkerPos (_sources # 4);
private _savedFactories = +factories;
factories = [_sources # 4];
(_sources # 4) setMarkerPos getPosATL _building;
_result = [_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_permanent_site_refused",!(_result # 0) && {_result # 1 == "protected_site"},_result] call _check;
(_sources # 4) setMarkerPos _savedFactory;
factories = _savedFactories;
private _hqPosition = getMarkerPos respawnTeamPlayer;
respawnTeamPlayer setMarkerPos getPosATL _building;
_result = [_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_hq_refused",!(_result # 0) && {_result # 1 == "hq"} && {damage _building == 0}] call _check;
respawnTeamPlayer setMarkerPos _hqPosition;
private _occupantGroup = createGroup [civilian,false];
private _occupant = _occupantGroup createUnit ["C_man_1",getPosATL _building vectorAdd [8,0,0],[],0,"NONE"];
_occupant enableSimulationGlobal false;
_result = [_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
["lib_building_occupied_damage_refused",!(_result # 0) && {_result # 1 == "occupied"} && {alive _occupant}] call _check;
_occupant setPosATL (getMarkerPos _town vectorAdd [300,0,0]);
[_record,_building,0.8] remoteExecCall ["A3I_fnc_damageLiberationBuilding",2]; sleep 0.3;
["lib_building_remote_damage_refused",damage _building == 0 && {isNil {_record get "sceneBuildings"}}] call _check;
_building animate ["door_2_rot",0.35,true];
private _doorBefore = _building animationPhase "door_2_rot";
private _originalWorld = getPosWorld _building;
private _originalDir = vectorDir _building;
private _originalUp = vectorUp _building;
_result = [_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
private _entries = _record getOrDefault ["sceneBuildings",[]];
["lib_building_real_partial_owned",_result # 0 && {alive _building} && {abs (damage _building - 0.8) < 0.001}
    && {count _entries == 1} && {(_building getVariable "A3I_sceneBuilding") isEqualRef (_entries # 0)}
    && {((A3I_liberationBuildings get (_record get "name")) # 0) isEqualRef _record},_result] call _check;
_result = [_record,_building,1] call A3I_fnc_damageLiberationBuilding;
["lib_building_damage_idempotent",_result # 0 && {_result # 1 == "already_applied"}
    && {count _entries == 1} && {abs (damage _building - 0.8) < 0.001}] call _check;
private _copy = createHashMapFromArray [["name",_record get "name"],["town",_town],["sceneBuildings",_entries]];
_result = [_copy] call A3I_fnc_cleanupLiberationBuildings;
["lib_building_same_name_copy_refused",!(_result # 0) && {_result # 1 == "ownership"}
    && {!(([_copy,_building,1] call A3I_fnc_damageLiberationBuilding) # 0)}] call _check;
[_record] remoteExecCall ["A3I_fnc_cleanupLiberationBuildings",2]; sleep 0.3;
["lib_building_remote_cleanup_refused",abs (damage _building - 0.8) < 0.001] call _check;
_occupant setPosATL (getPosATL _building vectorAdd [8,0,0]);
_result = [_record] call A3I_fnc_cleanupLiberationBuildings;
["lib_building_occupied_cleanup_deferred",!(_result # 0) && {_result # 1 == "occupied"}
    && {abs (damage _building - 0.8) < 0.001} && {alive _occupant}] call _check;
_occupant setPosATL (getMarkerPos _town vectorAdd [300,0,0]);
private _cleanBuilding = {
    params ["_record"];
    private _deadline = diag_tickTime + 30;
    private _done = false;
    waitUntil {sleep 0.2; _done = ([_record] call A3I_fnc_cleanupLiberationBuildings) # 0;
        _done || {diag_tickTime > _deadline}};
    _done
};
private _cleaned = [_record] call _cleanBuilding;
["lib_building_partial_restored",_cleaned && {alive _building} && {damage _building == 0}
    && {getPosWorld _building distance _originalWorld < 0.1}
    && {vectorDir _building vectorDistance _originalDir < 0.001}
    && {vectorUp _building vectorDistance _originalUp < 0.001}
    && {abs ((_building animationPhase "door_2_rot") - _doorBefore) < 0.001}
    && {isNil {_building getVariable "A3I_sceneBuilding"}},[_cleaned,damage _building,
        getPosWorld _building,_originalWorld,_building animationPhase "door_2_rot",_doorBefore]] call _check;
["lib_building_unrelated_damage_untouched",damage _damaged == 0.25] call _check;
["lib_building_retirement_idempotent",([_record] call A3I_fnc_cleanupLiberationBuildings) # 0
    && {!(([_record,_building,0.8] call A3I_fnc_damageLiberationBuilding) # 0)}] call _check;

// Destroy another, unowned house at the same time. Native persistence must keep
// that ruin while the owned scene house is excluded and subsequently restored.
_foreignRuinHouse setDamage 1;
_record = call _newSurvivor;
_result = [_record,_building,1] call A3I_fnc_damageLiberationBuilding;
private _entry = (_record getOrDefault ["sceneBuildings",[]]) param [0,createHashMap];
private _early = [_record] call A3I_fnc_cleanupLiberationBuildings;
["lib_building_collapse_cleanup_waits",_result # 0 && {!(_early # 0)}
    && {!(_record getOrDefault ["sceneBuildingsRetired",false])}] call _check;
private _deadline = diag_tickTime + 15;
waitUntil {sleep 0.1;!isNull (_entry getOrDefault ["ruin",objNull])
    && {!isNull (_foreignRuinHouse getVariable ["ruins",objNull])} || {diag_tickTime > _deadline}};
private _ruin = _entry getOrDefault ["ruin",objNull];
private _foreignRuin = _foreignRuinHouse getVariable ["ruins",objNull];
["lib_building_real_ruin_owned",!alive _building && {!isNull _ruin}
    && {_building getVariable ["ruins",objNull] == _ruin}
    && {_ruin getVariable ["building",objNull] == _building}] call _check;
["lib_building_temporary_ruin_not_saved",!(_building in destroyedBuildings)
    && {_foreignRuinHouse in destroyedBuildings},destroyedBuildings apply {typeOf _x}] call _check;
_cleaned = [_record] call _cleanBuilding;
["lib_building_ruin_restored_at_original_position",_cleaned && {alive _building} && {damage _building == 0}
    && {isNull _ruin} && {getPosWorld _building distance _originalWorld < 0.1}
    && {!isObjectHidden _building} && {!(_building in destroyedBuildings)},
    [_cleaned,getPosWorld _building,_originalWorld,damage _building,isNull _ruin]] call _check;
["lib_building_foreign_ruin_preserved",!alive _foreignRuinHouse && {!isNull _foreignRuin}
    && {_foreignRuinHouse in destroyedBuildings}] call _check;

// Original deleted externally while a scene owns it: do not recreate a house.
_record = call _newSurvivor;
[_record,_building,0.8] call A3I_fnc_damageLiberationBuilding;
deleteVehicle _building; sleep 0.2;
_cleaned = [_record] call _cleanBuilding;
["lib_building_deleted_original_not_recreated",_cleaned && {isNull _building}
    && {_record get "sceneBuildingsRetired"}] call _check;
["lib_building_registry_and_handler_retired",count A3I_liberationBuildings == 0
    && {isNil "A3I_liberationBuildingHandler"}] call _check;
deleteVehicle _damaged; deleteVehicle _foreignRuinHouse; deleteVehicle _foreignRuin;
deleteVehicle _occupant; [[_occupantGroup]] call A3I_fnc_cleanupGroups;
removeMissionEventHandler ["BuildingChanged",_nativeHandler];
{missionNamespace setVariable [_x # 0,if (_x # 1) then {_x # 2} else {nil}]} forEach _beforeGlobals;
sleep 1;
["lib_building_fixture_cleanup",isNull _building && {isNull _damaged} && {isNull _foreignRuinHouse}
    && {isNull _foreignRuin} && {isNull _occupant} && {isNull _occupantGroup}] call _check;
