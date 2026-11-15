// Real empty wrecks and native vehicle initialization/capture/resource handlers.
// No player driving, garage, save, actual towing or client lock-action acceptance.
#include "\x\a3a\addons\core\script_component.hpp"
private _wreckSavedReb = A3A_faction_reb;
private _wreckSavedAnims = A3A_faction_civ get "animations";
private _wreckSavedVariants = A3A_faction_civ get "variants";
private _wreckSavedAll = missionNamespace getVariable ["A3A_faction_all",createHashMap];
private _wreckSavedCosts = missionNamespace getVariable ["A3A_vehicleResourceCosts",createHashMap];
private _wreckSavedMarkers = missionNamespace getVariable ["markersX",[]];
private _wreckSavedGC = missionNamespace getVariable ["A3A_GCThreshold",600];
private _wreckSavedQueue = missionNamespace getVariable [QGVAR(despawnQueue),[]];
private _wreckSavedLock = missionNamespace getVariable ["enableVehicleAutoLock",false];
private _wreckSavedCivLock = missionNamespace getVariable ["enableVehicleAutoLockCiv",false];
private _wreckClass = "C_Offroad_01_F";
A3A_faction_reb = createHashMapFromArray [["vehiclesLightArmed",[_wreckClass,_wreckClass,
    "missing",3,"B_UGV_01_F","B_Heli_Light_01_F","C_Boat_Civil_01_F","C_man_1"]],
    ["vehiclesLightUnarmed",[]],["vehiclesAT","invalid"]];
["lib_wreck_pool_preserves_native_weights",call A3I_fnc_liberationWreckClasses isEqualTo [_wreckClass,_wreckClass]] call _check;
A3A_faction_reb = [];
["lib_wreck_malformed_template_refused",call A3I_fnc_liberationWreckClasses isEqualTo []] call _check;
A3A_faction_reb = createHashMapFromArray [["vehiclesLightUnarmed",[]]];
private _record = call _newSurvivor;
private _position = getMarkerPos _town;
private _result = [_record,_position] call A3I_fnc_createLiberationWreck;
["lib_wreck_empty_pool_has_no_fallback",!(_result # 0) && {_result # 1 == "wreck_pool"}
    && {isNil {_record get "sceneWrecks"}}] call _check;
A3A_faction_reb set ["vehiclesLightUnarmed",[_wreckClass]];
_result = [_record,_position,_wreckClass] call A3I_fnc_createLiberationWreck;
["lib_wreck_uncompiled_template_refused",!(_result # 0) && {_result # 1 == "campaign_not_ready"}
    && {isNil {_record get "sceneWrecks"}}] call _check;
// Exact skin-map conversion from pinned compileMissionAssets.
{
    private _key = _x;
    private _map = createHashMap;
    {_map set [_x # 0,_x # 1]} forEach (A3A_faction_civ get _key);
    A3A_faction_civ set [_key,_map];
} forEach ["animations","variants"];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],
    ["vehiclesIFVs",[]],["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMapFromArray [[_wreckClass,300]];
markersX = +_markers;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
enableVehicleAutoLock = false; enableVehicleAutoLockCiv = false;
A3A_resourcesAttackOcc = 1234; A3A_resourcesDefenceOcc = 987;
private _resources = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc];
A3I_test_support = [];
private _unchanged = {[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc] isEqualTo _resources
    && {A3I_test_support isEqualTo []}};
_result = [_record,["invalid",0,0],_wreckClass] call A3I_fnc_createLiberationWreck;
["lib_wreck_invalid_position_refused",!(_result # 0) && {isNil {_record get "sceneWrecks"}}] call _check;
_result = [_record,_position,"B_Heli_Light_01_F"] call A3I_fnc_createLiberationWreck;
["lib_wreck_arbitrary_class_refused",!(_result # 0) && {_result # 1 == "class"}
    && {isNil {_record get "sceneWrecks"}}] call _check;
private _hqPosition = getMarkerPos respawnTeamPlayer;
respawnTeamPlayer setMarkerPos _position;
_result = [_record,_position,_wreckClass] call A3I_fnc_createLiberationWreck;
["lib_wreck_hq_refused",!(_result # 0) && {_result # 1 == "hq"}
    && {isNil {_record get "sceneWrecks"}}] call _check;
respawnTeamPlayer setMarkerPos _hqPosition;
private _beforeVehicles = entities "LandVehicle";
[_record,_position,_wreckClass] remoteExecCall ["A3I_fnc_createLiberationWreck",2]; sleep 0.3;
["lib_wreck_remote_creation_refused",entities "LandVehicle" isEqualTo _beforeVehicles
    && {isNil {_record get "sceneWrecks"}}] call _check;
A3I_test_wreckCrew = [];
private _createdHandler = addMissionEventHandler ["EntityCreated",{
    params ["_entity"];
    if (_entity isKindOf "CAManBase") then {A3I_test_wreckCrew pushBack _entity};
}];
_result = [_record,_position,_wreckClass] call A3I_fnc_createLiberationWreck;
private _vehicle = (_record getOrDefault ["sceneWrecks",[]]) param [0,objNull];
// Stabilize the vehicle after testing native initial state; this fixture does
// not certify overturn physics, driving or the random lock presentation.
["lib_wreck_real_repairable_neutral",_result # 0 && {alive _vehicle}
    && {damage _vehicle >= 0.49} && {damage _vehicle <= 0.71} && {fuel _vehicle == 0}
    && {_vehicle getVariable ["ownerSide",west] == sideUnknown}
    && {_vehicle getVariable ["originalSide",west] == sideUnknown}
    && {_vehicle getVariable ["A3I_sceneWreckId",""] == _record get "name"},_result] call _check;
_vehicle setVectorUp [0,0,1]; _vehicle enableSimulationGlobal false;
sleep 0.2; removeMissionEventHandler ["EntityCreated",_createdHandler];
["lib_wreck_no_transient_crew",A3I_test_wreckCrew isEqualTo [] && {crew _vehicle isEqualTo []}] call _check;
["lib_wreck_creation_no_infected_cost",call _unchanged] call _check;
_vehicle setDamage 0; _vehicle setFuel 1;
["lib_wreck_repair_and_refuel",alive _vehicle && {canMove _vehicle} && {damage _vehicle == 0}
    && {fuel _vehicle == 1}] call _check;
private _rebelGroup = createGroup [teamPlayer,false];
private _rebel = _rebelGroup createUnit ["I_G_Soldier_F",_position vectorAdd [10,0,0],[],0,"NONE"];
_rebel moveInDriver _vehicle;
private _deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;_vehicle getVariable ["ownerSide",sideUnknown] == teamPlayer || {diag_tickTime > _deadline}};
["lib_wreck_native_getin_claim",driver _vehicle == _rebel
    && {_vehicle getVariable ["ownerSide",sideUnknown] == teamPlayer} && {call _unchanged}] call _check;
_result = [_record] call A3I_fnc_cleanupLiberationWrecks;
["lib_wreck_claimed_vehicle_retained",_result # 0 && {alive _vehicle} && {alive _rebel}
    && {_record get "sceneWrecks" isEqualTo []}] call _check;
moveOut _rebel; deleteVehicle _rebel; [[_rebelGroup]] call A3I_fnc_cleanupGroups;
private _claimed = _vehicle;

_record = call _newSurvivor;
_result = [_record,_position vectorAdd [30,0,0],_wreckClass] call A3I_fnc_createLiberationWreck;
_vehicle = (_record getOrDefault ["sceneWrecks",[]]) param [0,objNull];
_vehicle setVectorUp [0,0,1]; _vehicle enableSimulationGlobal false;
[_record] remoteExecCall ["A3I_fnc_cleanupLiberationWrecks",2]; sleep 0.3;
["lib_wreck_remote_cleanup_refused",alive _vehicle && {!(_record getOrDefault ["sceneWrecksRetired",false])}] call _check;
private _foreign = createHashMapFromArray [["name","foreign"],["sceneWrecks",[_vehicle]]];
_result = [_foreign] call A3I_fnc_cleanupLiberationWrecks;
["lib_wreck_foreign_cleanup_refused",!(_result # 0) && {_result # 1 == "ownership"} && {alive _vehicle}] call _check;
private _civilGroup = createGroup [civilian,false];
private _civil = _civilGroup createUnit ["C_man_1",_position vectorAdd [40,0,0],[],0,"NONE"];
_civil moveInDriver _vehicle; sleep 0.2;
_result = [_record] call A3I_fnc_cleanupLiberationWrecks;
["lib_wreck_occupied_cleanup_deferred",!(_result # 0) && {_result # 1 == "in_use"}
    && {alive _vehicle} && {alive _civil} && {driver _vehicle == _civil}] call _check;
moveOut _civil; deleteVehicle _civil; [[_civilGroup]] call A3I_fnc_cleanupGroups;
sleep 0.2;
private _anchor = createVehicle ["Land_HelipadEmpty_F",_position vectorAdd [30,0,0],[],0,"CAN_COLLIDE"];
_vehicle attachTo [_anchor,[0,0,1]];
_result = [_record] call A3I_fnc_cleanupLiberationWrecks;
["lib_wreck_attached_cleanup_deferred",!(_result # 0) && {_result # 1 == "in_use"} && {alive _vehicle}] call _check;
detach _vehicle; deleteVehicle _anchor;
_result = [_record] call A3I_fnc_cleanupLiberationWrecks;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;isNull _vehicle || {diag_tickTime > _deadline}};
["lib_wreck_unclaimed_cleanup_no_infected_cost",_result # 0 && {isNull _vehicle} && {call _unchanged}] call _check;
["lib_wreck_retirement_idempotent",([_record] call A3I_fnc_cleanupLiberationWrecks) # 0
    && {!(([_record,_position vectorAdd [30,0,0],_wreckClass] call A3I_fnc_createLiberationWreck) # 0)}] call _check;

_record = call _newSurvivor;
_result = [_record,_position vectorAdd [60,0,0],_wreckClass] call A3I_fnc_createLiberationWreck;
_vehicle = (_record getOrDefault ["sceneWrecks",[]]) param [0,objNull];
_vehicle setVectorUp [0,0,1]; _vehicle enableSimulationGlobal false;
sleep 6; // pass native cleanserVeh's creation interval before destruction
_vehicle setDamage 1;
// Invoke the native server destruction transaction with Rebel attribution.
// Full initServer's EntityKilled wiring is not claimed by this isolated test.
[_vehicle,teamPlayer,false] call A3A_fnc_vehKilledOrCaptured;
sleep 0.3;
["lib_wreck_native_destruction_no_infected_cost",!isNull _vehicle && {!alive _vehicle}
    && {call _unchanged}] call _check;
_result = [_record] call A3I_fnc_cleanupLiberationWrecks;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;isNull _vehicle || {diag_tickTime > _deadline}};
["lib_wreck_destroyed_cleanup_no_infected_cost",_result # 0 && {isNull _vehicle} && {call _unchanged}] call _check;
deleteVehicle _claimed;
_deadline = diag_tickTime + 8;
waitUntil {sleep 0.05;(isNull _claimed && {isNull _rebelGroup} && {isNull _civilGroup}) || {diag_tickTime > _deadline}};
["lib_wreck_fixture_cleanup",isNull _claimed && {isNull _rebelGroup} && {isNull _civilGroup}
    && {call _unchanged} && {entities "LandVehicle" isEqualTo _beforeVehicles}] call _check;
A3A_faction_reb = _wreckSavedReb; A3A_faction_all = _wreckSavedAll;
A3A_faction_civ set ["animations",_wreckSavedAnims]; A3A_faction_civ set ["variants",_wreckSavedVariants];
A3A_vehicleResourceCosts = _wreckSavedCosts; markersX = _wreckSavedMarkers;
A3A_GCThreshold = _wreckSavedGC; GVAR(despawnQueue) = _wreckSavedQueue;
enableVehicleAutoLock = _wreckSavedLock; enableVehicleAutoLockCiv = _wreckSavedCivLock;
