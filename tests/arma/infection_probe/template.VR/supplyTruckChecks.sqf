// Real native vehicle initialization/capture/deletion; no player driving or save.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _saved = [];
{
    _saved pushBack (if (isNil _x) then {[_x,false]} else {[_x,true,missionNamespace getVariable _x]});
} forEach ["A3A_faction_inv","A3A_faction_civ","A3A_faction_all","A3A_faction_reb",
    "A3A_vehicleResourceCosts","markersX","sidesX","respawnTeamPlayer","posHQ","serverInitDone",
    "enableVehicleAutoLock","enableVehicleAutoLockCiv","A3A_GCThreshold",QGVAR(despawnQueue),
    QGVAR(despawnerRunning),"A3I_test_convoyMode","A3I_test_observers","A3I_test_support",
    "A3A_resourcesAttackOcc","A3A_resourcesDefenceOcc","A3A_resourcesAttackInv","A3A_resourcesDefenceInv"];
A3I_test_convoyMode = false; A3I_test_observers = []; A3I_test_support = [];
A3A_faction_inv = createHashMap;
private _types = ["O_Truck_03_ammo_F","O_Truck_03_fuel_F","O_Truck_03_repair_F"];
{
    private _kind = _x;
    private _pool = [_kind] call A3I_fnc_supplyTruckClasses;
    ["struck_vanilla_" + _kind,count _pool == 2 && {(_types # _forEachIndex) in _pool}
        && {getNumber (configFile >> "CfgVehicles" >> (_types # _forEachIndex)
            >> (["transportAmmo","transportFuel","transportRepair"] # _forEachIndex)) > 0},_pool] call _check;
} forEach ["ammunition","fuel","repair"];
["struck_unknown_kind_refused",(["passengers"] call A3I_fnc_supplyTruckClasses) isEqualTo []] call _check;
A3A_faction_inv set ["vehiclesAmmoTrucks",["B_Truck_01_ammo_F","B_Truck_01_ammo_F","missing",3,
    "B_Heli_Light_01_F","B_UGV_01_F","C_man_1","Car"]];
["struck_selected_template_weights",(["ammunition"] call A3I_fnc_supplyTruckClasses)
    isEqualTo ["B_Truck_01_ammo_F","B_Truck_01_ammo_F"]] call _check;
A3A_faction_inv set ["vehiclesFuelTrucks","malformed"];
["struck_bad_pool_falls_back",count (["fuel"] call A3I_fnc_supplyTruckClasses) == 2] call _check;
A3A_faction_inv = [];
["struck_bad_template_falls_back",count (["repair"] call A3I_fnc_supplyTruckClasses) == 2] call _check;
A3A_faction_inv = createHashMap;
private _faction = A3A_faction_occ; A3A_faction_occ = createHashMap;
private _position = [4000,5000,0];
["struck_inactive_refused",(["fuel"] call A3I_fnc_supplyTruckClasses) isEqualTo []
    && {isNull ((["fuel",_position] call A3I_fnc_createSupplyTruck) # 0)}] call _check;
A3A_faction_occ = _faction;
serverInitDone = false;
["struck_incomplete_campaign_refused",(["fuel",_position] call A3I_fnc_createSupplyTruck) # 1 == "campaign_not_ready"] call _check;
serverInitDone = true;
A3A_faction_civ = createHashMapFromArray [["animations",createHashMap],["variants",createHashMap]];
A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_NATO_Ammo_F"]];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],
    ["vehiclesIFVs",[]],["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMapFromArray (_types apply {[_x,300]});
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
enableVehicleAutoLock = true; enableVehicleAutoLockCiv = true;
sidesX = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_struck_hq"; posHQ = [1000,1000,0];
private _site = "a3i_struck_site";
createMarker [respawnTeamPlayer,posHQ]; createMarker [_site,_position];
_site setMarkerShape "ELLIPSE"; _site setMarkerSize [150,150];
sidesX setVariable [_site,west]; sidesX setVariable [respawnTeamPlayer,teamPlayer];
markersX = [respawnTeamPlayer,_site];
A3A_resourcesAttackOcc = 1234; A3A_resourcesDefenceOcc = 987;
A3A_resourcesAttackInv = 876; A3A_resourcesDefenceInv = 765;
private _resources = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc,A3A_resourcesAttackInv,A3A_resourcesDefenceInv];
private _unchanged = {[_resources,A3I_test_support] isEqualTo
    [[A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc,A3A_resourcesAttackInv,A3A_resourcesDefenceInv],[]]};
["struck_unlisted_class_refused",(["fuel",_position,0,"B_MBT_01_cannon_F"] call A3I_fnc_createSupplyTruck) # 1 == "class_or_heading"] call _check;
["struck_invalid_position_refused",(["fuel",["bad",0,0]] call A3I_fnc_createSupplyTruck) # 1 == "invalid_request"] call _check;
["struck_hq_refused",(["fuel",posHQ] call A3I_fnc_createSupplyTruck) # 1 == "hq"] call _check;
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",_position vectorAdd [20,0,0],[],0,"NONE"];
A3I_test_observers = [_observer];
["struck_observer_refused",(["fuel",_position] call A3I_fnc_createSupplyTruck) # 1 == "player_distance"] call _check;
A3I_test_observers = []; deleteVehicle _observer; sleep 0.2; deleteGroup _observerGroup;
private _oldVehicles = entities "LandVehicle";
["fuel",_position] remoteExecCall ["A3I_fnc_createSupplyTruck",2]; sleep 0.2;
["struck_remote_refused",entities "LandVehicle" isEqualTo _oldVehicles] call _check;
A3I_test_supplyCrew = [];
private _createdHandler = addMissionEventHandler ["EntityCreated",{
    params ["_entity"]; if (_entity isKindOf "CAManBase") then {A3I_test_supplyCrew pushBack _entity};
}];
private _vehicles = [];
{
    private _kind = _x;
    private _result = [_kind,_position vectorAdd [40*_forEachIndex,0,0],90,_types # _forEachIndex]
        call A3I_fnc_createSupplyTruck;
    private _vehicle = _result # 0; _vehicles pushBack _vehicle;
    ["struck_created_" + _kind,alive _vehicle && {typeOf _vehicle == _types # _forEachIndex}
        && {canMove _vehicle} && {fuel _vehicle > 0} && {locked _vehicle < 2}
        && {_vehicle getVariable ["ownerSide",west] == sideUnknown}
        && {_vehicle getVariable ["originalSide",west] == sideUnknown}
        && {_vehicle getVariable ["A3I_abandoned",false]}
        && {_vehicle getVariable ["A3I_supplyKind",""] == _kind}
        && {isNil {_vehicle getVariable "A3A_despawnerHandle"}},_result # 1] call _check;
    _vehicle enableSimulationGlobal false;
} forEach ["ammunition","fuel","repair"];
sleep 0.2; removeMissionEventHandler ["EntityCreated",_createdHandler];
["struck_no_crew_created",A3I_test_supplyCrew isEqualTo [] && {(_vehicles findIf {crew _x isNotEqualTo []}) == -1}] call _check;
["struck_creation_resource_neutral",call _unchanged] call _check;
private _ammo = _vehicles # 0; private _fuel = _vehicles # 1; private _repair = _vehicles # 2;
private _group = createGroup teamPlayer;
private _driver = _group createUnit ["I_G_Soldier_F",_position vectorAdd [0,30,0],[],0,"NONE"];
_driver moveInDriver _ammo;
private _until = diag_tickTime+8;
waitUntil {sleep 0.05; _ammo getVariable ["ownerSide",sideUnknown] == teamPlayer || {diag_tickTime > _until}};
["struck_native_capture",driver _ammo == _driver && {_ammo getVariable ["ownerSide",sideUnknown] == teamPlayer}
    && {call _unchanged}] call _check;
private _despawner = [_ammo] spawn A3I_fnc_testNativeVEHdespawner;
_until = diag_tickTime+3; waitUntil {sleep 0.05; scriptDone _despawner || {diag_tickTime > _until}};
["struck_claimed_truck_retained",scriptDone _despawner && {alive _ammo} && {alive _driver}] call _check;
moveOut _driver; deleteVehicle _driver; sleep 0.2; deleteGroup _group;
sleep 6; // do not confuse native spawn-failure cleanup with later destruction
_fuel setDamage 1;
[_fuel,teamPlayer,false] call A3A_fnc_vehKilledOrCaptured;
sleep 0.2;
["struck_destruction_resource_neutral",!alive _fuel && {call _unchanged}] call _check;
_repair setDamage 0.4; deleteVehicle _repair; sleep 0.3;
["struck_live_cleanup_resource_neutral",isNull _repair && {call _unchanged}] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _vehicles;
deleteVehicle sidesX; deleteMarker _site; deleteMarker respawnTeamPlayer;
sleep 0.5;
["struck_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {call _unchanged}] call _check;
{
    if (_x # 1) then {missionNamespace setVariable [_x # 0,_x # 2]}
    else {missionNamespace setVariable [_x # 0,nil]};
} forEach _saved;
