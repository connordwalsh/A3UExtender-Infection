// Actual Altis road placement and native salvage lifecycle; no connected player or save acceptance.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
A3I_test_abandonedMode = true; distanceSPWN = 150;
A3I_test_convoyMode = false; A3I_test_observers = []; A3I_test_support = [];
A3A_faction_inv = createHashMap;
A3A_faction_civ = createHashMapFromArray [["animations",createHashMap],["variants",createHashMap]];
A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_NATO_Ammo_F"]];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],["vehiclesIFVs",[]],
    ["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMap;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
serverInitDone = true; enableVehicleAutoLock = true; enableVehicleAutoLockCiv = true;
civTraffic = 1; tierWar = 1; seaSpawn = []; areRivalsEnabled = false;
sidesX = [true] call A3A_fnc_createNamespace; spawner = [true] call A3A_fnc_createNamespace;
private _roads = nearestTerrainObjects [[worldSize/2,worldSize/2,0],["MAIN ROAD","ROAD","TRACK"],2000,false,true];
private _position = if (_roads isEqualTo []) then {[0,0,0]} else {getPosATL (_roads # 0)};
_position set [2,0];
["abtown_altis_roads",worldName == "Altis" && {_roads isNotEqualTo []},count _roads] call _check;
private _site = "a3i_abtown_site";
respawnTeamPlayer = "a3i_abtown_hq"; posHQ = _position vectorAdd [3000,0,0];
createMarker [respawnTeamPlayer,posHQ]; createMarker [_site,_position];
_site setMarkerShape "ELLIPSE"; _site setMarkerSize [250,250];
sidesX setVariable [_site,west]; sidesX setVariable [respawnTeamPlayer,teamPlayer];
spawner setVariable [_site+"_civ",0]; markersX = [respawnTeamPlayer,_site];
citiesX = [_site]; destroyedSites = [];
A3A_townData = createHashMapFromArray [[_site,[1600,0,0,0]]];
["abtown_override_registered",getText(configFile >> "CfgFunctions" >> "A3A" >> "Civilian" >> "createAmbientCivTraffic" >> "file")
    == "\x\a3i\addons\core\overrides\fn_createAmbientCivTraffic.sqf"] call _check;
private _faction = A3A_faction_occ; A3A_faction_occ = createHashMap;
["abtown_inactive_refused",!([_site] call A3I_fnc_startAbandonedTown)] call _check;
A3A_faction_occ = _faction;
sidesX setVariable [_site,east];
["abtown_russian_refused",!([_site] call A3I_fnc_startAbandonedTown)] call _check;
sidesX setVariable [_site,teamPlayer];
["abtown_rebel_refused",!([_site] call A3I_fnc_startAbandonedTown)] call _check;
sidesX setVariable [_site,west]; spawner setVariable [_site+"_civ",2];
["abtown_inactive_visit_refused",!([_site] call A3I_fnc_startAbandonedTown)] call _check;
spawner setVariable [_site+"_civ",0];
[[_site],"A3A_fnc_createAmbientCivTraffic"] call A3A_fnc_scheduler;
private _until = diag_tickTime + 20;
waitUntil {sleep 0.1; _site in (missionNamespace getVariable ["A3I_abandonedTowns",createHashMap]) || {diag_tickTime > _until}};
private _record = (missionNamespace getVariable ["A3I_abandonedTowns",createHashMap]) getOrDefault [_site,createHashMap];
["abtown_scheduler_started",count _record > 0] call _check;
if (count _record == 0) exitWith {diag_log "[ABANDONED_TOWN_FIXTURE_ABORT] no controller"};
["abtown_duplicate_refused",!([_site] call A3I_fnc_startAbandonedTown)] call _check;
[] remoteExec ["A3I_fnc_runAbandonedTown",2];
[] remoteExecCall ["A3I_fnc_cleanupAbandonedTown",2];
_until = diag_tickTime + 20;
waitUntil {sleep 0.1; _record getOrDefault ["parkingComplete",false] || {diag_tickTime > _until}};
private _vehicles = +(_record get "vehicles");
["abtown_native_attempt_count",_record getOrDefault ["parkingComplete",false]
    && {_record getOrDefault ["parkedAttempts",-1] == _record get "parkedTarget"}
    && {_record get "parkedTarget" == ([1600,_record get "roadCount",1,1,daytime] call A3I_fnc_abandonedParkedCount)},
    [_record getOrDefault ["parkedAttempts",-1],_record getOrDefault ["parkedTarget",-1],count _vehicles]] call _check;
["abtown_roadside_assets",count _vehicles >= 2 && {count _vehicles <= _record get "parkedTarget"}
    && {(_vehicles findIf {!alive _x || {_x distance2D _position > 250} || {crew _x isNotEqualTo []}
        || {!(_x getVariable ["A3I_abandoned",false])} || {_x getVariable ["ownerSide",west] != sideUnknown}}) == -1},
    _vehicles apply {[typeOf _x,getPosATL _x]}] call _check;
["abtown_neutral_creation",A3I_test_support isEqualTo []] call _check;
["abtown_native_traffic_gates",(_record get "nativeParked") isEqualTo []
    && {(_record get "trafficVehicles") isEqualTo []} && {(_record get "trafficGroups") isEqualTo []}] call _check;
private _claimed = _vehicles param [0,objNull]; private _watched = _vehicles param [1,objNull];
private _group = createGroup teamPlayer;
private _driver = _group createUnit ["I_G_Soldier_F",getPosATL _claimed,[],0,"NONE"];
_driver moveInDriver _claimed;
_until = diag_tickTime+8; waitUntil {sleep 0.1; _claimed getVariable ["ownerSide",sideUnknown] == teamPlayer || {diag_tickTime > _until}};
["abtown_native_salvage_capture",!isNull _claimed && {_claimed getVariable ["ownerSide",sideUnknown] == teamPlayer}
    && {A3I_test_support isEqualTo []}] call _check;
moveOut _driver; _driver setPosATL getPosATL _watched; A3I_test_observers = [_driver];
spawner setVariable [_site+"_civ",2]; sleep 2.5;
["abtown_observed_cleanup_deferred",alive _watched && {_site in A3I_abandonedTowns}
    && {_record get "ended"}] call _check;
["abtown_claimed_preserved",alive _claimed && {isNil {_claimed getVariable "A3I_abandonedTownOwner"}}] call _check;
A3I_test_observers = []; deleteVehicle _driver; sleep 0.2; deleteGroup _group;
_until = diag_tickTime+5; waitUntil {sleep 0.1; !(_site in A3I_abandonedTowns) || {diag_tickTime > _until}};
["abtown_unclaimed_cleaned",!(_site in A3I_abandonedTowns)
    && {(_vehicles findIf {_x != _claimed && {!isNull _x}}) == -1} && {alive _claimed}] call _check;
["abtown_monitor_retired",isNil "A3I_abandonedTownHandle"] call _check;
deleteVehicle _claimed; sleep 0.5;
spawner setVariable [_site+"_civ",0];
private _oldSerial = _record get "serial";
["abtown_revisit_started",[_site] call A3I_fnc_startAbandonedTown] call _check;
_record = A3I_abandonedTowns get _site;
_until = diag_tickTime+20;
waitUntil {sleep 0.1; _record getOrDefault ["parkingComplete",false] || {diag_tickTime > _until}};
["abtown_revisit_repopulates",_record get "serial" > _oldSerial && {count (_record get "vehicles") > 0}] call _check;
_vehicles = +(_record get "vehicles");
private _moved = _vehicles param [0,objNull];
private _attached = _vehicles param [1,objNull];
private _foreign = _vehicles param [2,objNull];
private _anchor = "Land_HelipadEmpty_F" createVehicle (_position vectorAdd [400,0,0]);
_attached attachTo [_anchor,[0,0,1]];
_moved setPosATL (_position vectorAdd [700,0,0]);
_foreign setVariable ["A3I_abandonedTownOwner",[_site,(_record get "serial")+1000]];
terminate (_record get "script");
_until = diag_tickTime+5; waitUntil {sleep 0.1; !(_site in A3I_abandonedTowns) || {diag_tickTime > _until}};
["abtown_interrupted_worker_cleanup",_record get "ended" && {alive _attached}
    && {alive _foreign} && {!isNil {_moved getVariable "A3A_despawnerHandle"}}] call _check;
["abtown_foreign_owner_preserved",(_foreign getVariable ["A3I_abandonedTownOwner",[]])
    isEqualTo [_site,(_record get "serial")+1000]] call _check;
["abtown_moved_native_cleanup_handoff",alive _moved && {isNil {_moved getVariable "A3I_abandonedTownOwner"}}] call _check;
detach _attached; _attached setPosATL (_attached getVariable "originalPos"); deleteVehicle _anchor;
_until = diag_tickTime+5; waitUntil {sleep 0.1; !(_site in A3I_abandonedTowns) || {diag_tickTime > _until}};
["abtown_detached_cleanup",!(_site in A3I_abandonedTowns) && {isNull _attached} && {alive _foreign}] call _check;
_until = diag_tickTime+70; waitUntil {sleep 0.2; isNull _moved || {diag_tickTime > _until}};
["abtown_moved_native_despawn",isNull _moved] call _check;
deleteVehicle _foreign;
deleteVehicle sidesX; deleteVehicle spawner; deleteMarker _site; deleteMarker respawnTeamPlayer;
sleep 1;
["abtown_cleanup",(entities [[],[],true,false]) - _before isEqualTo [] && {allGroups - _groupsBefore isEqualTo []},
    [(entities [[],[],true,false]) - _before,allGroups - _groupsBefore]] call _check;
