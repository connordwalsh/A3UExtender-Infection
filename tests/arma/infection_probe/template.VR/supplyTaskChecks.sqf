// Actual truck creation/native tasks/resources with controlled VR travel/time.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _vehicles = [];
private _group = createGroup teamPlayer;
sidesX = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_stask_hq"; posHQ = [3000,4000,0];
private _town = "a3i_stask_town"; private _site = "a3i_stask_site";
private _friendly = "a3i_stask_friendly";
createMarker [respawnTeamPlayer,posHQ];
createMarker [_town,[4000,4000,0]]; createMarker [_site,[4500,4500,0]];
createMarker [_friendly,[3500,4500,0]];
private _markers = [respawnTeamPlayer,_town,_site,_friendly];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [100,100]; sidesX setVariable [_x,west]} forEach _markers;
sidesX setVariable [respawnTeamPlayer,teamPlayer]; sidesX setVariable [_friendly,teamPlayer];
markersX = +_markers; citiesX = [_town]; outposts = [_site]; factories = [_friendly];
milbases = []; airportsX = []; seaports = []; resourcesX = []; controlsX = []; milAdministrationsX = [];
petros = _group createUnit ["I_G_Soldier_F",posHQ,[],0,"NONE"]; petros enableSimulationGlobal false;
theBoss = objNull; distanceMission = 2000; distanceSPWN = 300;
A3A_faction_inv = createHashMap;
A3A_faction_civ = createHashMapFromArray [["animations",createHashMap],["variants",createHashMap],["currencySymbol","$"]];
A3A_faction_reb = createHashMapFromArray [["lootCrate","Box_NATO_Ammo_F"],["name","NATO"]];
A3A_faction_all = createHashMapFromArray [["vehiclesArmor",[]],["vehiclesAPCs",[]],
    ["vehiclesIFVs",[]],["vehiclesLightAPCs",[]],["vehiclesRivals",[]]];
A3A_vehicleResourceCosts = createHashMap;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
enableVehicleAutoLock = false; enableVehicleAutoLockCiv = false; serverInitDone = true;
A3I_test_convoyMode = false; A3I_test_support = []; A3I_test_observers = [];
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0; staticsToSave = [];
A3I_supplyTasks = createHashMap; tierWar = 0; resourcesIsChanging = false; limitHR = 0;
server setVariable ["hr",10]; server setVariable ["resourcesFIA",1000];
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
private _wait = {
    params ["_condition",["_seconds",8]];
    private _until = diag_tickTime+_seconds;
    waitUntil {sleep 0.05; call _condition || {diag_tickTime > _until}};
    call _condition
};
private _start = {
    params ["_source",["_kind","fuel"]];
    private _accepted = [_source,_kind] call A3I_fnc_startSupplySeizure;
    private _r = A3I_supplyTasks getOrDefault ["A3I_SUPPLY_" + str A3I_supplySerial,createHashMap];
    [{_r get "phase" != "preparing"},8] call _wait;
    private _truck = _r get "truck"; _vehicles pushBack _truck;
    if (!isNull _truck) then {_truck enableSimulationGlobal false};
    [_accepted,_r]
};
private _cleanup = {
    params ["_r"];
    _r set ["taskDeleteAt",time-1];
    [{!((_r get "name") in A3I_supplyTasks)},5] call _wait
};
private _state = {
    params ["_r"];
    private _index = A3A_tasksData findIf {_x # 0 == _r get "name"};
    if (_index < 0) then {"MISSING"} else {A3A_tasksData # _index # 2}
};
["stask_town_fuel_only",([_town] call A3I_fnc_supplySiteKinds) isEqualTo ["fuel"]] call _check;
["stask_site_three_roles",([_site] call A3I_fnc_supplySiteKinds) isEqualTo ["ammunition","fuel","repair"]] call _check;
["stask_targets_infected_only",(call A3I_fnc_supplyTargets) isEqualTo [_town,_site]] call _check;
private _count = count A3I_supplyTasks;
["stask_wrong_town_role_refused",!([_town,"ammunition"] call A3I_fnc_startSupplySeizure)
    && {!([_town,"repair"] call A3I_fnc_startSupplySeizure)} && {count A3I_supplyTasks == _count}] call _check;
A3A_tasksData = [["foreign_log","LOG","CREATED",time]]; A3A_activeTasks = ["LOG"];
["stask_foreign_log_busy",!([_town,"fuel"] call A3I_fnc_startSupplySeizure) && {count A3I_supplyTasks == 0}] call _check;
A3A_tasksData = []; A3A_activeTasks = [];
private _made = [_town,"fuel"] call _start; private _r = _made # 1; private _truck = _r get "truck";
["stask_real_creation",_made # 0 && {_r get "phase" == "active"} && {alive _truck}
    && {_truck getVariable ["A3I_supplyKind",""] == "fuel"} && {[_truck,_town] call A3I_fnc_interceptionContains}
    && {([_r] call _state) == "CREATED"} && {"LOG" in A3A_activeTasks}] call _check;
["stask_timer_normal",_r get "duration" == 3600 && {_r get "deadline" > time+3590}] call _check;
["stask_duplicate_refused",!([_site,"repair"] call A3I_fnc_startSupplySeizure) && {count A3I_supplyTasks == 1}] call _check;
sidesX setVariable [_town,east];
["stask_russian_takeover_continues",([_r] call A3I_fnc_supplyTaskOutcome) == "pending"] call _check;
sidesX setVariable [_town,teamPlayer];
["stask_rebel_town_takeover_continues",([_r] call A3I_fnc_supplyTaskOutcome) == "pending"] call _check;
_truck setPosATL posHQ;
[{([_r] call _state) == "SUCCEEDED" && {server getVariable "resourcesFIA" == 1300}
    && {A3A_resourcesAttackOcc == 880} && {A3A_resourcesDefenceOcc == 880}},8] call _wait;
["stask_hq_delivered",_r get "outcome" == "delivered" && {([_r] call _state) == "SUCCEEDED"}] call _check;
["stask_native_rewards_normal",server getVariable "resourcesFIA" == 1300 && {server getVariable "hr" == 10}
    && {A3A_resourcesAttackOcc == 880} && {A3A_resourcesDefenceOcc == 880}] call _check;
["stask_truck_retained_and_save_registered",alive _truck && {canMove _truck}
    && {_truck getVariable ["ownerSide",sideUnknown] == teamPlayer}
    && {{_x isEqualTo _truck} count staticsToSave == 1}] call _check;
[_r] call A3I_fnc_finishSupplySeizure; sleep 0.2;
["stask_reward_once",server getVariable "resourcesFIA" == 1300 && {A3A_resourcesAttackOcc == 880}] call _check;
["stask_retention_native_window",_r get "taskDeleteAt" > time+590 && {_r get "taskDeleteAt" <= time+1800}
    && {call A3I_fnc_supplyTaskBusy}] call _check;
[_r] call _cleanup;
["stask_task_cleanup_preserves_truck",alive _truck && {isNil {_truck getVariable "A3I_supplyTaskOwner"}}
    && {!call A3I_fnc_supplyTaskBusy} && {([_r] call _state) == "MISSING"}] call _check;
sidesX setVariable [_town,west];

tierWar = 10;
_made = [_site,"ammunition"] call _start; _r = _made # 1; _truck = _r get "truck";
["stask_timer_difficult",_made # 0 && {_r get "duration" == 1800}] call _check;
_truck setPosATL getMarkerPos _friendly;
[{([_r] call _state) == "SUCCEEDED" && {server getVariable "resourcesFIA" == 1900}
    && {A3A_resourcesAttackOcc == 640} && {A3A_resourcesDefenceOcc == 640}},8] call _wait;
["stask_site_delivery_and_hard_rewards",_r get "deliveryDestination" == _friendly
    && {server getVariable "resourcesFIA" == 1900} && {A3A_resourcesAttackOcc == 640}
    && {A3A_resourcesDefenceOcc == 640} && {alive _truck}] call _check;
[_r] call _cleanup; tierWar = 0;

_made = [_site,"repair"] call _start; _r = _made # 1; _truck = _r get "truck";
// Keep a real corpse until after the result is observed; no native initServer
// destruction-resource wiring is claimed by this controlled fixture.
_truck setDamage 1;
[{([_r] call _state) == "FAILED" && {A3A_resourcesAttackOcc == 760} && {A3A_resourcesDefenceOcc == 760}},8] call _wait;
["stask_destroyed_fails",_r get "outcome" == "destroyed" && {([_r] call _state) == "FAILED"}
    && {server getVariable "resourcesFIA" == 1900} && {A3A_resourcesAttackOcc == 760}
    && {A3A_resourcesDefenceOcc == 760}] call _check;
[_r] call _cleanup;

_made = [_town,"fuel"] call _start; _r = _made # 1; _truck = _r get "truck";
[_truck,teamPlayer,true] call A3A_fnc_vehKilledOrCaptured;
_r set ["deadline",time-1];
[{([_r] call _state) == "FAILED" && {A3A_resourcesAttackOcc == 880}},8] call _wait;
["stask_deadline_fails_without_delivery",_r get "outcome" == "timeout"
    && {server getVariable "resourcesFIA" == 1900} && {alive _truck}] call _check;
_truck setPosATL posHQ; [_r] call A3I_fnc_finishSupplySeizure; sleep 0.1;
["stask_late_delivery_not_rewarded",_r get "outcome" == "timeout" && {server getVariable "resourcesFIA" == 1900}] call _check;
[_r] call _cleanup;
["stask_failed_claimed_truck_retained",alive _truck && {isNil {_truck getVariable "A3I_supplyTaskOwner"}}] call _check;

_made = [_town,"fuel"] call _start; _r = _made # 1; _truck = _r get "truck";
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",(getPosATL _truck) vectorAdd [5,0,0],[],0,"NONE"];
A3I_test_observers = [_observer]; _r set ["deadline",time-1];
[{_r get "settled"},5] call _wait;
_r set ["taskDeleteAt",time-1]; sleep 1.2;
["stask_observed_cleanup_deferred",alive _truck && {!(_r get "assetRetired")}
    && {_r get "taskRetired"} && {(_r get "name") in A3I_supplyTasks}] call _check;
A3I_test_observers = []; _observer moveInDriver _truck;
[_r] call A3I_fnc_cleanupSupplySeizure;
["stask_occupied_cleanup_deferred",alive _truck && {!(_r get "assetRetired")}] call _check;
private _anchor = objNull;
isNil {
    // Keep the independent cleanup owner from running in a fixture-only gap
    // between occupied and attached states.
    _anchor = createVehicle ["Land_HelipadEmpty_F",getPosATL _truck,[],0,"CAN_COLLIDE"];
    _truck attachTo [_anchor,[0,0,1]];
    moveOut _observer; deleteVehicle _observer;
};
sleep 0.2; deleteGroup _observerGroup; [_r] call A3I_fnc_cleanupSupplySeizure;
["stask_attached_cleanup_deferred",alive _truck && {!(_r get "assetRetired")}] call _check;
detach _truck; deleteVehicle _anchor;
[{isNull _truck && {!((_r get "name") in A3I_supplyTasks)}},5] call _wait;
["stask_unclaimed_cleanup_completes",isNull _truck && {!((_r get "name") in A3I_supplyTasks)}] call _check;

_made = [_site,"fuel"] call _start; _r = _made # 1; _truck = _r get "truck";
private _funds = server getVariable "resourcesFIA"; private _army = A3A_resourcesAttackOcc;
deleteVehicle _truck;
[{_r get "settled"},5] call _wait;
["stask_missing_cancels_without_reward",_r get "outcome" == "interrupted"
    && {server getVariable "resourcesFIA" == _funds} && {A3A_resourcesAttackOcc == _army}] call _check;
[_r] call _cleanup;

_made = [_site,"repair"] call _start; _r = _made # 1; _truck = _r get "truck";
private _foreign = createHashMapFromArray [["name",_r get "name"],["serial",(_r get "serial")-1]];
["stask_stale_record_refused",!([_foreign] call A3I_fnc_finishSupplySeizure)
    && {!([_foreign] call A3I_fnc_cleanupSupplySeizure)} && {!(_r get "settled")}] call _check;
_truck setVariable ["A3I_supplyTaskOwner",["foreign",123]];
[{_r get "settled"},5] call _wait; [_r] call _cleanup;
["stask_foreign_asset_preserved",alive _truck && {_r get "outcome" == "interrupted"}
    && {(_truck getVariable "A3I_supplyTaskOwner") isEqualTo ["foreign",123]}] call _check;

private _accepted = [_town,"fuel"] call A3I_fnc_startSupplySeizure;
_r = A3I_supplyTasks get ("A3I_SUPPLY_" + str A3I_supplySerial);
terminate (_r get "script");
[{_r get "settled"},5] call _wait;
["stask_stopped_preparation_reclaimed",_accepted && {_r get "outcome" == "interrupted"}
    && {isNull (_r get "truck")} && {!(_r get "taskRegistered")} && {!call A3I_fnc_supplyTaskBusy}] call _check;
[{count A3I_supplyTasks == 0 && {isNil "A3I_supplyTaskHandle"}},5] call _wait;
["stask_handlers_retired",count A3I_supplyTasks == 0 && {isNil "A3I_supplyTaskHandle"}] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _vehicles;
{deleteVehicle _x} forEach [petros,sidesX,server];
{deleteMarker _x} forEach _markers;
sleep 0.3; deleteGroup _group; sleep 0.5;
["stask_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []}] call _check;
