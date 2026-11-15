// Actual native path queries and actors on controlled VR campaign records.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _savedCap = A3I_activeLimit;
private _savedContext = A3I_contextLimit;
private _setLimits = {
    params ["_global","_context"];
    ["A3I_activeLimit",_global,2,"server",false] call CBA_settings_fnc_set;
    ["A3I_contextLimit",_context,2,"server",false] call CBA_settings_fnc_set;
};
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
private _source = "a3i_iafter_source";
private _destination = "a3i_iafter_destination";
private _town = "a3i_iafter_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_iafter_hq";
createMarker [_source,_sourcePosition];
createMarker [_destination,_destinationPosition];
createMarker [_town,[8000,4500,0]];
createMarker [respawnTeamPlayer,_hqPosition];
private _markers = [_source,_destination,_town,respawnTeamPlayer];
{_x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50]; sidesX setVariable [_x,west]; spawner setVariable [_x,2]} forEach _markers;
citiesX = [_source]; factories = [_destination]; resourcesX = []; outposts = [];
airportsX = []; milbases = []; seaports = []; milAdministrationsX = []; controlsX = [];
markersX = [_source,_destination]; forcedSpawn = [];
distanceMission = 1800; distanceForLandAttack = 2000;
A3I_majorSourceCooldowns = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
server setVariable [_source,[90,0,0]];
NavGrid = [[_sourcePosition,1,0,[[1,0,1000]]],[_destinationPosition,1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap;
{_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
private _wait = {
    params ["_predicate",["_timeout",20]];
    private _deadline = diag_tickTime + _timeout;
    waitUntil {sleep 0.05; call _predicate || {diag_tickTime > _deadline}};
    call _predicate
};
A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 100;
A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = []; A3I_test_observers = [];
A3I_interceptions = createHashMap; A3I_sites = createHashMap;
tierWar = 0; plusGarrison = true; distanceSPWN = 1000;
[2,2] call _setLimits;
private _role = "loadouts_occ_militia_Rifleman";
private _serial = 0;
private _newJob = {
    params [["_size",4]];
    _serial = _serial + 1;
    private _name = "aftermath_" + str _serial;
    private _roles = []; for "_i" from 1 to _size do {_roles pushBack _role};
    private _record = createHashMapFromArray [["name",_name],["serial",_serial],
        ["context","interception:" + _name],["size",_size],["roles",_roles],
        ["source",_source],["target",_destination],["spawnPosition",+_sourcePosition],
        ["destinationPosition",+_destinationPosition],["phase","preparing"],["retired",false],
        ["fault",""],["remaining",_size],["missing",0],["killed",0],["arrived",false],
        ["created",0],["units",[]],["groups",[]],["prepared",false],
        ["script",[] spawn {sleep 600}]];
    A3I_interceptions set [_name,_record];
    _record
};
private _cleanup = {
    params ["_record"];
    A3I_test_observers = [];
    [_record] call A3I_fnc_retireInterceptionFormation;
    terminate (_record get "script");
    [{scriptDone (_record get "script")},2] call _wait;
    {deleteVehicle _x} forEach (_record get "units");
    [_record get "groups"] call A3I_fnc_cleanupGroups;
    sleep 0.3;
    A3I_interceptions deleteAt (_record get "name");
};

garrisonIsChanging = false; distanceSPWN1 = 1000; A3I_siteSerial = 0;
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0; theBoss = objNull;
killZones = [true] call A3A_fnc_createNamespace;
A3I_test_originals = []; markersChanging = [];
zoneChecksMutex = createHashMap; A3A_diameterExtendedCaptureArea = 0;
private _launch = {
    params [["_size",4]];
    private _job = [_size] call _newJob;
    _job set ["routeDistance",1000];
    [_job] call A3I_fnc_prepareInterception;
    [_job] call A3I_fnc_releaseInterceptionFormation;
    {_x disableAI "MOVE"} forEach (_job get "units");
    [_job] call A3I_fnc_registerInterceptionTask;
    diag_log format ["[INFECTION_DIAGNOSTIC] %1",["aftermath_launch",_job get "name",
        _job get "fault",_job get "created",_job get "phase",_job getOrDefault ["lastPreparation",""]]];
    _job
};
private _place = {
    params ["_job"];
    {_x setPosATL (_destinationPosition vectorAdd [(_forEachIndex mod 5) * 2,3 + floor (_forEachIndex / 5) * 2,0])}
        forEach (_job get "units");
};
private _settled = {
    params ["_job"];
    [{_job getOrDefault ["settled",false] && {
        (A3A_tasksData findIf {_x # 0 == _job get "name" && {_x # 2 == "FAILED"}}) >= 0
    }},5] call _wait
};
private _finishJob = {
    params ["_job"];
    _job set ["aftermathComplete",true]; _job set ["taskDeleteAt",time - 1];
    [{isNil {A3I_interceptions get (_job get "name")}},5] call _wait;
    [_job] call _cleanup;
};
private _stopSite = {
    private _site = A3I_sites getOrDefault [_destination,createHashMap];
    private _actors = +(_site getOrDefault ["units",[]]);
    spawner setVariable [_destination,2,true];
    [{!(_destination in A3I_sites)},5] call _wait;
    {deleteVehicle _x} forEach _actors;
    sleep 0.5;
};

private _job = [4] call _launch;
private _actors = +(_job get "units");
garrison setVariable [_destination,[]];
["iafter_marching_not_processed",!([_job] call A3I_fnc_interceptionAftermath)
    && {isNil {_job get "aftermathDeadline"}}] call _check;
(_actors # 0) setPosATL _destinationPosition;
[_job] call _settled;
sleep 1.2;
["iafter_partial_group_waits",_job get "outcome" == "arrived"
    && {garrison getVariable _destination isEqualTo []}
    && {!(_job getOrDefault ["aftermathComplete",false])}
    && {{alive _x} count _actors == 4}] call _check;
["iafter_one_hour_window",_job get "aftermathDeadline" > time + 3590
    && {_job get "aftermathDeadline" <= time + 3600}] call _check;
terminate (_job get "script");
sleep 1.2;
["iafter_stopped_worker_keeps_march",_job getOrDefault ["marchHandle",-1] >= 0
    && {!(_job getOrDefault ["aftermathComplete",false])}] call _check;
garrisonIsChanging = true;
[_job] call _place;
sleep 1.2;
["iafter_busy_garrison_defers",garrison getVariable _destination isEqualTo []
    && {{alive _x} count _actors == 4}] call _check;
private _funds = [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc];
garrisonIsChanging = false;
// deleteVehicle completes on a later frame than the atomic storage transaction.
[{_job getOrDefault ["retired",false] && {{alive _x} count _actors == 0}},5] call _wait;
["iafter_offscreen_automatic_storage",count (garrison getVariable _destination) == 4
    && {_job getOrDefault ["storedArrivals",0] == 4}
    && {{alive _x} count _actors == 0} && {_job get "aftermathComplete"},
    [count (garrison getVariable _destination),_job getOrDefault ["storedArrivals",0],
        {alive _x} count _actors,_job getOrDefault ["aftermathComplete",false]]] call _check;
["iafter_storage_no_second_reward",_funds isEqualTo [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc]
    && {(A3A_tasksData findIf {_x # 0 == _job get "name" && {_x # 2 == "FAILED"}}) >= 0}
    && {!(_job get "taskRetired")}] call _check;
sleep 1.2;
["iafter_storage_not_duplicated",count (garrison getVariable _destination) == 4] call _check;
[_job] call _finishJob;
["iafter_claim_released_after_retention",isNil {A3I_interceptions get (_job get "name")}
    && {A3A_tasksData isEqualTo []} && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;

// Observer presence defers storage until the normal destination controller starts.
garrison setVariable [_destination,[]];
_job = [4] call _launch; _actors = +(_job get "units");
private _observerGroup = createGroup civilian;
private _observer = _observerGroup createUnit ["C_man_1",_destinationPosition,[],0,"NONE"];
_observer allowDamage false; _observer enableSimulationGlobal false;
A3I_test_observers = [_observer];
[_job] call _place; [_job] call _settled; sleep 1.2;
["iafter_observed_offscreen_waits",count (garrison getVariable _destination) == 0
    && {{alive _x} count _actors == 4} && {!(_job getOrDefault ["aftermathComplete",false])},
    [_job get "fault",_job get "phase",count (garrison getVariable _destination),
        {alive _x} count _actors,_job getOrDefault ["lastArrivalHandoff",[]]]] call _check;
spawner setVariable [_destination,0,true];
[_destination,"Resource",false] call A3I_fnc_startSite;
[{_job getOrDefault ["adoptedArrivals",0] == 4},5] call _wait;
private _site = A3I_sites get _destination;
["iafter_live_site_automatic_adoption",count (garrison getVariable _destination) == 4
    && {{alive _x} count _actors == 4} && {_actors - (_site get "units") isEqualTo []}
    && {_site get "clearanceRemaining" == 4},
    [count (garrison getVariable _destination),{alive _x} count _actors,
        _site get "clearanceRemaining",_job getOrDefault ["lastArrivalHandoff",[]]]] call _check;
[_job] call _finishJob;
["iafter_old_owner_keeps_adopted_units",{alive _x} count _actors == 4
    && {!(([_destination] call A3I_fnc_siteClearance) # 0)}] call _check;
(_actors # 0) setDamage 1;
[{count (garrison getVariable _destination) == 3},5] call _wait;
["iafter_adopted_death_persists",count (garrison getVariable _destination) == 3
    && {_site get "clearanceRemaining" == 3}] call _check;
call _stopSite;
{deleteVehicle _x} forEach _actors;
deleteVehicle _observer; deleteGroup _observerGroup; A3I_test_observers = [];

// Two tickets must both move, even as each transaction edits the owner's arrays.
factories = []; citiesX pushBack _destination;
server setVariable [_destination,[10,0,0]]; garrison setVariable [_destination,[]];
A3A_townData = createHashMapFromArray [[_destination,[10,0,0,0]]];
townSkirmishes = []; destroyedSites = [];
spawner setVariable [_destination,0,true];
[_destination,"City",false] call A3I_fnc_startSite;
_site = A3I_sites getOrDefault [_destination,createHashMap];
_job = [16] call _launch; _actors = +(_job get "units");
["iafter_multiple_group_fixture",count (_job get "groups") == 2] call _check;
[_job] call _place; [_job] call _settled;
[{_job getOrDefault ["adoptedArrivals",0] == 16},5] call _wait;
["iafter_all_groups_automatically_adopted",_job getOrDefault ["adoptedArrivals",0] == 16
    && {count ([_destination] call A3I_fnc_siteExtraRoster) == 16}
    && {_site getOrDefault ["populationTarget",-1] == 26} && {{alive _x} count _actors == 16},
    [_job getOrDefault ["adoptedArrivals",0],count ([_destination] call A3I_fnc_siteExtraRoster),
        _site getOrDefault ["populationTarget",-1],{alive _x} count _actors,
        _job getOrDefault ["lastArrivalHandoff",[]]]] call _check;
[_job] call _finishJob; call _stopSite;
{deleteVehicle _x} forEach _actors;
citiesX = [_source]; factories = [_destination];

// Real native weighted 3:1 decision; only the final campaign transaction is a
// controlled endpoint. The broader markerChange transaction has separate tests.
sidesX setVariable [_destination,teamPlayer,true];
garrison setVariable [_destination,[_role,_role]];
_job = [4] call _launch; _actors = +(_job get "units");
[_job] call _place; [_job] call _settled;
A3I_test_zones = []; A3I_test_nativeZoneCheck = true; A3I_test_applyMarkerChange = true;
A3I_test_clearCapturedGarrison = true;
_job set ["nextCaptureAt",time - 1]; sleep 1.2;
["iafter_unspawned_destination_not_captured",A3I_test_zones isEqualTo []
    && {sidesX getVariable _destination == teamPlayer}] call _check;
spawner setVariable [_destination,0,true];
sleep 1.2;
["iafter_missing_defenders_block_capture",A3I_test_zones isEqualTo []
    && {sidesX getVariable _destination == teamPlayer}] call _check;
// A Russian takeover after the task failed does not abandon the destination.
sidesX setVariable [_destination,east,true];
private _defenderGroup = createGroup [east,true];
private _defenders = [];
for "_i" from 0 to 1 do {
    private _unit = _defenderGroup createUnit ["O_Soldier_F",_destinationPosition vectorAdd [0,-10 - _i,0],[],0,"NONE"];
    _unit setVariable ["markerX",_destination]; _unit enableSimulationGlobal false;
    _defenders pushBack _unit;
};
_job set ["nextCaptureAt",time - 1];
[{A3I_test_zones isNotEqualTo []},5] call _wait; sleep 0.5;
["iafter_native_ratio_holds_defended_site",sidesX getVariable _destination == east
    && {A3I_test_zones # 0 isEqualTo [_destination,east]}
    && {!(_job getOrDefault ["aftermathComplete",false])}] call _check;
(_defenders # 0) setDamage 1;
garrison setVariable [_destination,[_role]];
_job set ["nextCaptureAt",time - 1];
[{sidesX getVariable _destination == west},5] call _wait;
[{_job getOrDefault ["adoptedArrivals",0] == 4},5] call _wait;
["iafter_native_capture_then_reinforcement",sidesX getVariable _destination == west
    && {_job getOrDefault ["adoptedArrivals",0] == 4}
    && {count (garrison getVariable _destination) == 4}
    && {!((A3I_sites get _destination) get "assets")}
    && {{alive _x} count _actors == 4}] call _check;
["iafter_capture_does_not_reverse_failed_task",(A3A_tasksData findIf {
    _x # 0 == _job get "name" && {_x # 2 == "FAILED"}}) >= 0] call _check;
[_job] call _finishJob; call _stopSite;
{deleteVehicle _x} forEach (_defenders + _actors); deleteGroup _defenderGroup;
A3I_test_nativeZoneCheck = false; A3I_test_applyMarkerChange = false;
A3I_test_clearCapturedGarrison = false;

// A cleared administration remains removed, even while a surviving horde fights.
private _building = createVehicle ["Land_i_Barracks_V1_F",_destinationPosition,[],0,"CAN_COLLIDE"];
_destination setMarkerShape "ICON"; _destination setMarkerType "A3AU_miladmin_mrk";
factories = []; milAdministrationsX = [_destination];
A3A_milAdministrations = [_building]; A3A_destroyedMilAdministrations = [];
garrison setVariable [_destination,[]]; sidesX setVariable [_destination,west,true];
_job = [4] call _launch; _actors = +(_job get "units");
A3A_destroyedMilAdministrations = [_building]; sidesX setVariable [_destination,teamPlayer,true];
{_x setPosATL (_destinationPosition vectorAdd [40 + _forEachIndex * 2,0,0])} forEach _actors;
[_job] call _settled;
A3I_test_zones = []; _job set ["nextCaptureAt",time - 1];
terminate (_job get "script"); sleep 1.2;
["iafter_cleared_administration_stays_cleared",sidesX getVariable _destination == teamPlayer
    && {_building in A3A_destroyedMilAdministrations} && {A3I_test_zones isEqualTo []}
    && {{alive _x} count _actors == 4} && {_job getOrDefault ["marchHandle",-1] >= 0}] call _check;
_observerGroup = createGroup civilian;
_observer = _observerGroup createUnit ["C_man_1",_destinationPosition,[],0,"NONE"];
_observer allowDamage false; _observer enableSimulationGlobal false; A3I_test_observers = [_observer];
_job set ["aftermathDeadline",time - 1];
[{_job getOrDefault ["aftermathComplete",false]},5] call _wait;
["iafter_timeout_preserves_observed_horde",_job get "aftermathReason" == "timeout"
    && {!(_job get "retired")} && {{alive _x} count _actors == 4}] call _check;
deleteVehicle _observer; deleteGroup _observerGroup; A3I_test_observers = [];
[_job] call _finishJob;
["iafter_unobserved_timeout_retires",{alive _x} count _actors == 0
    && {isNil {A3I_interceptions get (_job get "name")}}] call _check;
deleteVehicle _building;
milAdministrationsX = []; A3A_milAdministrations = []; A3A_destroyedMilAdministrations = [];

[_savedCap,_savedContext] call _setLimits;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
A3I_test_observers = nil;
sleep 3;
["iafter_complete_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_interceptions == 0}
    && {count A3I_sites == 0} && {A3A_tasksData isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [count ((entities [[],[],true,false]) - _before),count (allGroups - _groupsBefore),call _stats]] call _check;


