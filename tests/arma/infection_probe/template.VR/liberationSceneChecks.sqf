// Complete and interrupted scene assembly with native FIA/CIV templates. This
// does not yet connect the helper to the parent mission or certify client play.
#include "\x\a3a\addons\core\script_component.hpp"
private _savedSceneReb = A3A_faction_reb;
private _savedSceneAnims = A3A_faction_civ get "animations";
private _savedSceneVariants = A3A_faction_civ get "variants";
private _sceneGlobals = ["A3A_faction_all","A3A_vehicleResourceCosts","markersX","A3A_GCThreshold",
    QGVAR(despawnQueue),"enableVehicleAutoLock","enableVehicleAutoLockCiv","destroyedBuildings",
    "A3A_resourcesAttackOcc","A3A_resourcesDefenceOcc","A3I_test_support"];
private _savedSceneGlobals = _sceneGlobals apply {[_x,!(isNil _x),missionNamespace getVariable [_x,[]]]};
A3A_faction_reb = ["\x\a3a\addons\core\Templates\Templates\Vanilla\Vanilla_Reb_FIA.sqf",teamPlayer]
    call A3A_fnc_compatibilityLoadFaction;
private _nativeSceneReb = A3A_faction_reb;
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],
    ["vehiclesIFVs",[]],["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMap;
{A3A_vehicleResourceCosts set [_x,300]} forEach (call A3I_fnc_liberationWreckClasses);
markersX = +_markers; A3A_GCThreshold = 600; GVAR(despawnQueue) = [];
enableVehicleAutoLock = false; enableVehicleAutoLockCiv = false;
destroyedBuildings = []; A3A_resourcesAttackOcc = 1234; A3A_resourcesDefenceOcc = 987; A3I_test_support = [];
private _sceneHouse = createVehicle ["Land_i_House_Small_01_V1_F",getMarkerPos _town vectorAdd [110,0,0],[],0,"CAN_COLLIDE"];
private _sceneHouse2 = createVehicle ["Land_i_House_Small_01_V1_F",getMarkerPos _town vectorAdd [-110,0,0],[],0,"CAN_COLLIDE"];
private _sceneHouse3 = createVehicle ["Land_i_House_Small_01_V1_F",getMarkerPos _town vectorAdd [0,110,0],[],0,"CAN_COLLIDE"];
sleep 0.3;
private _record = call _newSurvivor;
[_record] call A3I_fnc_createLiberationSurvivor;
private _vip = _record get "vip";
_vip enableSimulationGlobal false;
private _result = [A3I_fnc_createLiberationScene,[_record]] call CBA_fnc_directCall;
["lib_scene_unscheduled_refused",!(_result # 0) && {_result # 1 == "server_local_scheduled"}] call _check;
[_record] remoteExec ["A3I_fnc_createLiberationScene",2]; sleep 0.3;
["lib_scene_remote_creation_refused",!(_record getOrDefault ["sceneStarted",false])
    && {isNil {_record get "vipVehicle"}}] call _check;
_result = [_record] call A3I_fnc_createLiberationScene;
["lib_scene_uncompiled_campaign_refused",!(_result # 0) && {_result # 1 == "campaign_not_ready"}
    && {!(_record getOrDefault ["sceneStarted",false])}] call _check;
{
    private _key = _x;
    private _map = createHashMap;
    {_map set [_x # 0,_x # 1]} forEach (A3A_faction_civ get _key);
    A3A_faction_civ set [_key,_map];
} forEach ["animations","variants"];
A3A_faction_reb = createHashMap;
_result = [_record] call A3I_fnc_createLiberationScene;
["lib_scene_missing_pools_refused",!(_result # 0) && {_result # 1 == "scene_pools"}
    && {isNil {_record get "vipVehicle"}}] call _check;
A3A_faction_reb = _nativeSceneReb;
// Seed a known owned partial building so combined teardown always exercises
// restoration even when native random building selection chooses no houses.
[_record,_sceneHouse,0.8] call A3I_fnc_damageLiberationBuilding;
A3I_test_completeSceneMen = [];
private _createdHandler = addMissionEventHandler ["EntityCreated",{
    params ["_entity"];
    if (_entity isKindOf "CAManBase") then {A3I_test_completeSceneMen pushBack _entity};
}];
_result = [_record] call A3I_fnc_createLiberationScene;
removeMissionEventHandler ["EntityCreated",_createdHandler];
private _bodies = +(_record getOrDefault ["sceneBodies",[]]);
private _blood = +(_record getOrDefault ["sceneBlood",[]]);
private _bodyGroups = +(_record getOrDefault ["sceneBodyGroups",[]]);
private _wrecks = +(_record getOrDefault ["sceneWrecks",[]]);
private _effects = +(_record getOrDefault ["sceneEffects",[]]);
private _vipVehicle = _record getOrDefault ["vipVehicle",objNull];
["lib_scene_complete_native_assets",_result # 0 && {_record get "sceneReady"}
    && {alive _vip} && {alive _vipVehicle} && {count _wrecks > 0} && {count _bodies > 0}
    && {count _blood == count _bodies} && {count _effects > 0}
    && {_record get "sceneClustersBuilt" == _record get "sceneClustersPlanned"},
    [_result,count _wrecks,count _bodies,count _effects,_record get "sceneFailures"]] call _check;
["lib_scene_no_untracked_crew",A3I_test_completeSceneMen - _bodies isEqualTo []
    && {_bodies - A3I_test_completeSceneMen isEqualTo []}
    && {(_bodies findIf {alive _x}) == -1} && {crew _vipVehicle isEqualTo []}
    && {(_wrecks findIf {crew _x isNotEqualTo []}) == -1}] call _check;
["lib_scene_no_infected_resource_or_support_cost",A3A_resourcesAttackOcc == 1234
    && {A3A_resourcesDefenceOcc == 987} && {A3I_test_support isEqualTo []}] call _check;
_result = [_record] call A3I_fnc_createLiberationScene;
["lib_scene_repeated_creation_idempotent",_result # 0 && {_result # 1 == "existing"}
    && {_record get "vipVehicle" == _vipVehicle} && {_record get "sceneBodies" isEqualTo _bodies}
    && {_record get "sceneWrecks" isEqualTo _wrecks}] call _check;
[_record] remoteExecCall ["A3I_fnc_cleanupLiberationScene",2]; sleep 0.3;
["lib_scene_remote_cleanup_refused",alive _vip && {!(_record getOrDefault ["sceneRetired",false])}] call _check;
spawner setVariable [_town,0];
_result = [_record] call A3I_fnc_cleanupLiberationScene;
["lib_scene_active_town_cleanup_deferred",!(_result # 0) && {_result # 1 == "town_active"} && {alive _vip}] call _check;
spawner setVariable [_town,2];
private _savedParents = missionNamespace getVariable ["A3I_liberations",createHashMap];
A3I_liberations = createHashMapFromArray [[_record get "name",_record]];
_record set ["settled",false];
_result = [_record] call A3I_fnc_cleanupLiberationScene;
["lib_scene_active_parent_cleanup_refused",!(_result # 0) && {_result # 1 == "mission_active"} && {alive _vip}] call _check;
private _copy = createHashMapFromArray [["name",_record get "name"],["town",_town]];
_result = [_copy] call A3I_fnc_cleanupLiberationScene;
["lib_scene_foreign_parent_record_refused",!(_result # 0) && {_result # 1 == "ownership"} && {alive _vip}] call _check;
A3I_liberations = _savedParents;
private _claimed = _wrecks param [0,objNull];
_claimed setVariable ["ownerSide",teamPlayer,true];
_claimed setPosATL (getMarkerPos _town vectorAdd [300,0,0]);
private _ownedObjects = (_wrecks - [_claimed]) + _effects + _bodies + _blood + [_vip];
private _group = _record get "vipGroup";
private _cleanScene = {
    params ["_record"];
    private _deadline = diag_tickTime + 35;
    private _done = false;
    waitUntil {sleep 0.2; _done = ([_record] call A3I_fnc_cleanupLiberationScene) # 0;
        _done || {diag_tickTime > _deadline}};
    _done
};
private _cleaned = [_record] call _cleanScene;
private _deadline = diag_tickTime + 10;
waitUntil {sleep 0.1;((_ownedObjects findIf {!isNull _x}) == -1
    && {(_bodyGroups findIf {!isNull _x}) == -1} && {isNull _group}) || {diag_tickTime > _deadline}};
["lib_scene_complete_cleanup_restores_building",_cleaned && {_record get "sceneRetired"}
    && {(_ownedObjects findIf {!isNull _x}) == -1} && {(_bodyGroups findIf {!isNull _x}) == -1}
    && {isNull _group} && {damage _sceneHouse == 0} && {alive _sceneHouse}
    && {count A3I_liberationBuildings == 0} && {count A3I_liberationEffects == 0},
    [_cleaned,_ownedObjects select {!isNull _x},damage _sceneHouse]] call _check;
["lib_scene_native_vehicle_retention",alive _vipVehicle && {alive _claimed}
    && {_record get "vehicleReleased"} && {A3A_resourcesAttackOcc == 1234}
    && {A3A_resourcesDefenceOcc == 987} && {A3I_test_support isEqualTo []}] call _check;
["lib_scene_retirement_idempotent",([_record] call A3I_fnc_cleanupLiberationScene) # 0
    && {!(([_record] call A3I_fnc_createLiberationScene) # 0)}] call _check;
deleteVehicle _vipVehicle; deleteVehicle _claimed; sleep 0.3;

// Stop assembly after the first cluster, then retire the actual partial assets.
_record = call _newSurvivor;
[_record] call A3I_fnc_createLiberationSurvivor;
_vip = _record get "vip"; _vip enableSimulationGlobal false;
private _worker = [_record] spawn A3I_fnc_createLiberationScene;
_deadline = diag_tickTime + 12;
waitUntil {sleep 0.1;_record getOrDefault ["sceneClustersBuilt",0] >= 1 || {scriptDone _worker} || {diag_tickTime > _deadline}};
terminate _worker;
private _immediateDone = scriptDone _worker;
_deadline = diag_tickTime+2;
waitUntil {sleep 0.05; scriptDone _worker || {diag_tickTime > _deadline}};
_vipVehicle = _record getOrDefault ["vipVehicle",objNull];
_ownedObjects = (_record getOrDefault ["sceneBodies",[]]) + (_record getOrDefault ["sceneBlood",[]])
    + (_record getOrDefault ["sceneWrecks",[]]) + (_record getOrDefault ["sceneEffects",[]]) + [_vip];
_bodyGroups = +(_record getOrDefault ["sceneBodyGroups",[]]); _group = _record get "vipGroup";
["lib_scene_interrupted_creation_owned",scriptDone _worker && {!(_record getOrDefault ["sceneReady",false])}
    && {_record getOrDefault ["sceneClustersBuilt",0] >= 1} && {count _ownedObjects > 1}
    && {alive _vipVehicle} && {!(([_record] call A3I_fnc_createLiberationScene) # 0)},
    [_immediateDone,scriptDone _worker,_record getOrDefault ["sceneReady",false],
        _record getOrDefault ["sceneClustersBuilt",0],count _ownedObjects,alive _vipVehicle]] call _check;
_cleaned = [_record] call _cleanScene;
_deadline = diag_tickTime + 10;
waitUntil {sleep 0.1;((_ownedObjects findIf {!isNull _x}) == -1
    && {(_bodyGroups findIf {!isNull _x}) == -1} && {isNull _group}) || {diag_tickTime > _deadline}};
["lib_scene_interrupted_cleanup_exact",_cleaned && {(_ownedObjects findIf {!isNull _x}) == -1}
    && {(_bodyGroups findIf {!isNull _x}) == -1} && {isNull _group}
    && {alive _vipVehicle} && {count A3I_liberationBuildings == 0} && {count A3I_liberationEffects == 0}] call _check;
{deleteVehicle _x} forEach [_vipVehicle,_sceneHouse,_sceneHouse2,_sceneHouse3];
sleep 1;
A3A_faction_reb = _savedSceneReb;
A3A_faction_civ set ["animations",_savedSceneAnims]; A3A_faction_civ set ["variants",_savedSceneVariants];
{missionNamespace setVariable [_x # 0,if (_x # 1) then {_x # 2} else {nil}]} forEach _savedSceneGlobals;
["lib_scene_fixture_cleanup",isNull _vipVehicle && {isNull _sceneHouse} && {isNull _sceneHouse2}
    && {isNull _sceneHouse3} && {isNil "A3I_liberationBuildingHandler"}] call _check;
