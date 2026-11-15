// Real native abandoned vehicle initialization/repair/capture/deletion; no player driving or disk save.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _saved = [];
{
    _saved pushBack (if (isNil _x) then {[_x,false]} else {[_x,true,missionNamespace getVariable _x]});
} forEach ["citiesX","destroyedSites","A3A_faction_inv","A3A_faction_civ","A3A_faction_all","A3A_faction_reb",
    "A3A_vehicleResourceCosts","markersX","sidesX","respawnTeamPlayer","posHQ","serverInitDone",
    "enableVehicleAutoLock","enableVehicleAutoLockCiv","A3A_GCThreshold",QGVAR(despawnQueue),
    QGVAR(despawnerRunning),"A3I_test_convoyMode","A3I_test_observers","A3I_test_support",
    "A3A_resourcesAttackOcc","A3A_resourcesDefenceOcc","A3A_resourcesAttackInv","A3A_resourcesDefenceInv"];
A3I_test_convoyMode = false; A3I_test_observers = []; A3I_test_support = [];
A3A_faction_inv = createHashMap; A3A_faction_civ = createHashMap;
private _types = ["C_Offroad_01_F","B_GEN_Offroad_01_gen_F","O_MRAP_02_F"];
{
    private _kind = _x;
    private _pool = [_kind] call A3I_fnc_abandonedVehicleClasses;
    ["abveh_vanilla_" + _kind,(_types # _forEachIndex) in _pool
        && {count _pool == ([3,1,1] # _forEachIndex)},_pool] call _check;
} forEach ["civilian","police","military"];
["abveh_unknown_kind_refused",(["passengers"] call A3I_fnc_abandonedVehicleClasses) isEqualTo []] call _check;
A3A_faction_civ set ["vehiclesCivCar",["C_Offroad_01_F","C_Offroad_01_F","missing",3,
    "B_Heli_Light_01_F","B_UGV_01_F","C_man_1","Car"]];
["abveh_selected_template_weights",(["civilian"] call A3I_fnc_abandonedVehicleClasses)
    isEqualTo ["C_Offroad_01_F","C_Offroad_01_F"]] call _check;
A3A_faction_inv set ["vehiclesPolice","malformed"];
["abveh_bad_pool_falls_back",count (["police"] call A3I_fnc_abandonedVehicleClasses) == 1] call _check;
A3A_faction_inv = [];
["abveh_bad_template_falls_back",count (["military"] call A3I_fnc_abandonedVehicleClasses) == 1] call _check;
A3A_faction_inv = createHashMap;
private _position = [4000,5000,0];
serverInitDone = true;
A3A_faction_civ = createHashMapFromArray [["animations",createHashMap],["variants",createHashMap]];
A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_NATO_Ammo_F"]];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],
    ["vehiclesIFVs",[]],["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMapFromArray (_types apply {[_x,300]});
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
enableVehicleAutoLock = true; enableVehicleAutoLockCiv = true;
sidesX = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_abveh_hq"; posHQ = [1000,1000,0];
private _site = "a3i_abveh_site";
createMarker [respawnTeamPlayer,posHQ]; createMarker [_site,_position];
_site setMarkerShape "ELLIPSE"; _site setMarkerSize [150,150];
sidesX setVariable [_site,west]; sidesX setVariable [respawnTeamPlayer,teamPlayer];
markersX = [respawnTeamPlayer,_site];
citiesX = [_site]; destroyedSites = [];
private _create = {
    params ["_kind","_pos",["_dir",0],["_class",""]];
    [_site,_kind,_pos,_dir,_class] call A3I_fnc_createAbandonedVehicle
};
private _faction = A3A_faction_occ; A3A_faction_occ = createHashMap;
["abveh_inactive_refused",(["police"] call A3I_fnc_abandonedVehicleClasses) isEqualTo []
    && {isNull ((["police",_position] call _create) # 0)}] call _check;
A3A_faction_occ = _faction;
serverInitDone = false;
["abveh_incomplete_campaign_refused",(["police",_position] call _create) # 1 == "campaign_not_ready"] call _check;
serverInitDone = true;
sidesX setVariable [_site,east];
["abveh_russian_town_refused",(["police",_position] call _create) # 1 == "town_unavailable"] call _check;
sidesX setVariable [_site,teamPlayer];
["abveh_rebel_town_refused",(["police",_position] call _create) # 1 == "town_unavailable"] call _check;
sidesX setVariable [_site,west]; destroyedSites = [_site];
["abveh_destroyed_town_refused",(["police",_position] call _create) # 1 == "town_unavailable"] call _check;
destroyedSites = [];
["abveh_town_distance_refused",(["police",_position vectorAdd [300,0,0]] call _create) # 1 == "town_distance"] call _check;
["abveh_native_counts",([100,50,0,1,12] call A3I_fnc_abandonedParkedCount) == 3
    && {([100,50,0,1,7] call A3I_fnc_abandonedParkedCount) == 4}
    && {([1600,50,10,1,12] call A3I_fnc_abandonedParkedCount) == 5}
    && {([1600,3,0,1,12] call A3I_fnc_abandonedParkedCount) == 3}
    && {([0,50,0,0,12] call A3I_fnc_abandonedParkedCount) == 1}
    && {([100,0,0,1,12] call A3I_fnc_abandonedParkedCount) == 0}
    && {([-1,50,0,1,12] call A3I_fnc_abandonedParkedCount) == -1}] call _check;
A3A_resourcesAttackOcc = 1234; A3A_resourcesDefenceOcc = 987;
A3A_resourcesAttackInv = 876; A3A_resourcesDefenceInv = 765;
private _resources = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc,A3A_resourcesAttackInv,A3A_resourcesDefenceInv];
private _unchanged = {[_resources,A3I_test_support] isEqualTo
    [[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc,A3A_resourcesAttackInv,A3A_resourcesDefenceInv],[]]};
["abveh_unlisted_class_refused",(["police",_position,0,"B_MBT_01_cannon_F"] call _create) # 1 == "class_or_heading"] call _check;
["abveh_invalid_position_refused",(["police",["bad",0,0]] call _create) # 1 == "invalid_request"] call _check;
["abveh_hq_refused",(["police",posHQ] call _create) # 1 == "hq"] call _check;
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",_position vectorAdd [20,0,0],[],0,"NONE"];
A3I_test_observers = [_observer];
["abveh_observer_refused",(["police",_position] call _create) # 1 == "player_distance"] call _check;
A3I_test_observers = []; deleteVehicle _observer; sleep 0.2; deleteGroup _observerGroup;
private _oldVehicles = entities "LandVehicle";
[_site,"police",_position] remoteExecCall ["A3I_fnc_createAbandonedVehicle",2]; sleep 0.2;
["abveh_remote_refused",entities "LandVehicle" isEqualTo _oldVehicles] call _check;
A3I_test_supplyCrew = [];
private _createdHandler = addMissionEventHandler ["EntityCreated",{
    params ["_entity"]; if (_entity isKindOf "CAManBase") then {A3I_test_supplyCrew pushBack _entity};
}];
private _vehicles = [];
{
    private _kind = _x;
    private _result = [_kind,_position vectorAdd [40*_forEachIndex,0,0],90,_types # _forEachIndex]
        call _create;
    private _vehicle = _result # 0; _vehicles pushBack _vehicle;
    ["abveh_created_" + _kind,alive _vehicle && {typeOf _vehicle == _types # _forEachIndex}
        && {damage _vehicle >= 0.14} && {damage _vehicle <= 0.56} && {fuel _vehicle >= 0.09} && {fuel _vehicle <= 0.51} && {locked _vehicle < 2}
        && {_vehicle getVariable ["ownerSide",west] == sideUnknown}
        && {_vehicle getVariable ["originalSide",west] == sideUnknown}
        && {_vehicle getVariable ["A3I_abandoned",false]}
        && {_vehicle getVariable ["A3I_abandonedKind",""] == _kind}
        && {isNil {_vehicle getVariable "A3A_despawnerHandle"}},_result # 1] call _check;
    _vehicle enableSimulationGlobal false;
} forEach ["civilian","police","military"];
sleep 0.2; removeMissionEventHandler ["EntityCreated",_createdHandler];
["abveh_no_crew_created",A3I_test_supplyCrew isEqualTo [] && {(_vehicles findIf {crew _x isNotEqualTo []}) == -1}] call _check;
["abveh_creation_resource_neutral",call _unchanged] call _check;
{_x setDamage 0} forEach _vehicles;
sleep 0.2;
["abveh_repair_restores_drivability",(_vehicles findIf {!alive _x || {!canMove _x} || {damage _x != 0}}) == -1] call _check;
["abveh_cargo_empty",(_vehicles findIf {getWeaponCargo _x # 0 isNotEqualTo []
    || {getMagazineCargo _x # 0 isNotEqualTo []} || {getItemCargo _x # 0 isNotEqualTo []}
    || {getBackpackCargo _x # 0 isNotEqualTo []}}) == -1] call _check;
private _ammo = _vehicles # 0; private _fuel = _vehicles # 1; private _repair = _vehicles # 2;
private _group = createGroup teamPlayer;
private _driver = _group createUnit ["I_G_Soldier_F",_position vectorAdd [0,30,0],[],0,"NONE"];
_driver moveInDriver _ammo;
private _until = diag_tickTime+8;
waitUntil {sleep 0.05; _ammo getVariable ["ownerSide",sideUnknown] == teamPlayer || {diag_tickTime > _until}};
["abveh_native_capture",driver _ammo == _driver && {_ammo getVariable ["ownerSide",sideUnknown] == teamPlayer}
    && {call _unchanged}] call _check;
private _despawner = [_ammo] spawn A3I_fnc_testNativeVEHdespawner;
_until = diag_tickTime+3; waitUntil {sleep 0.05; scriptDone _despawner || {diag_tickTime > _until}};
["abveh_claimed_truck_retained",scriptDone _despawner && {alive _ammo} && {alive _driver}] call _check;
moveOut _driver; deleteVehicle _driver; sleep 0.2; deleteGroup _group;
sleep 6; // do not confuse native spawn-failure cleanup with later destruction
_fuel setDamage 1;
[_fuel,teamPlayer,false] call A3A_fnc_vehKilledOrCaptured;
sleep 0.2;
["abveh_destruction_resource_neutral",!alive _fuel && {call _unchanged}] call _check;
_repair setDamage 0.4; deleteVehicle _repair; sleep 0.3;
["abveh_live_cleanup_resource_neutral",isNull _repair && {call _unchanged}] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _vehicles;
deleteVehicle sidesX; deleteMarker _site; deleteMarker respawnTeamPlayer;
sleep 0.5;
["abveh_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {call _unchanged}] call _check;
{
    if (_x # 1) then {missionNamespace setVariable [_x # 0,_x # 2]}
    else {missionNamespace setVariable [_x # 0,nil]};
} forEach _saved;
