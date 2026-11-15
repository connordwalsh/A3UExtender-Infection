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
private _source = "a3i_idis_source";
private _destination = "a3i_idis_destination";
private _town = "a3i_idis_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_idis_hq";
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
garrisonIsChanging = false; distanceSPWN1 = 1000;
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0; theBoss = objNull;
killZones = [true] call A3A_fnc_createNamespace;
A3I_test_originals = []; A3I_test_comms = []; hcArray = [];
A3I_interceptionSerial = 0; bigAttackInProgress = false; areOccupantsDefeated = false;
private _hqGroup = createGroup [teamPlayer,true];
petros = _hqGroup createUnit ["I_G_Soldier_F",_hqPosition,[],0,"NONE"];
petros enableSimulationGlobal false;
private _getJob = {
    [{count A3I_interceptions == 1},8] call _wait;
    private _job = (values A3I_interceptions) param [0,createHashMap];
    if (count _job > 0) then {
        [{_job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}},65] call _wait;
    };
    _job
};
private _retire = {
    params ["_job"];
    private _actors = +(_job getOrDefault ["units",[]]);
    if (_job getOrDefault ["taskRegistered",false]) then {
        {_x setDamage 1} forEach _actors;
    } else {terminate (_job get "script")};
    [{_job getOrDefault ["settled",false]},5] call _wait;
    _job set ["taskDeleteAt",time - 1];
    [{isNil {A3I_interceptions get (_job get "name")}},5] call _wait;
    {deleteVehicle _x} forEach _actors;
    sleep 0.5;
    A3I_majorSourceCooldowns = createHashMap;
};

// Fill the ordinary shared allowance before starting the separate horde.
private _shared = ["reserve",["idis-shared",2,2]] call A3I_fnc_budget;
private _result = [_destination,_source] call A3I_fnc_startInterception;
private _job = A3I_interceptions getOrDefault [_result # 1,createHashMap];
["idis_atomic_preparation_claim",_result # 0 && {count _job > 0}
    && {_job get "phase" == "preparing"} && {!(_job get "taskRegistered")}
    && {A3A_tasksData isEqualTo []} && {call A3I_fnc_interceptionBusy}] call _check;
["idis_duplicate_preparation_refused",!(([_destination,_source] call A3I_fnc_startInterception) # 0)
    && {count A3I_interceptions == 1}] call _check;
_job = call _getJob;
["idis_full_horde_before_task",_job getOrDefault ["taskRegistered",false]
    && {_job get "size" == 40} && {_job get "created" == 40}
    && {count (_job get "units") == 40}
    && {((_job get "units") findIf {!alive _x || {isObjectHidden _x}
        || {!simulationEnabled _x} || {side group _x != west}}) == -1}
    && {count A3A_tasksData == 1}] call _check;
private _budget = call _stats;
private _extraShared = ["reserve",["idis-extra-shared",1,1]] call A3I_fnc_budget;
["idis_separate_allowance",_shared # 0 && {A3I_activeLimit == 2}
    && {_budget select [0,3] isEqualTo [42,40,2]}
    && {!(_extraShared # 0)} && {_extraShared # 2 == "capacity"},
    [_budget,_shared,_extraShared]] call _check;
["cancel",[(_shared # 1) # 0]] call A3I_fnc_budget;
if (_extraShared # 0) then {["cancel",[(_extraShared # 1) # 0]] call A3I_fnc_budget};
["idis_real_route_record",_job get "source" == _source && {_job get "target" == _destination}
    && {_job get "routeDistance" == 1000}] call _check;
["idis_source_cooldown_preserves_population",(A3I_majorSourceCooldowns get _source) > time + 590
    && {server getVariable _source isEqualTo [90,0,0]}] call _check;
[_job] call _retire;
["idis_real_worker_cleanup",count A3I_interceptions == 0 && {A3A_tasksData isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;

_result = [_destination,_source] call A3I_fnc_startInterception;
_job = A3I_interceptions get (_result # 1);
terminate (_job get "script");
[{isNil {A3I_interceptions get (_job get "name")}},5] call _wait;
["idis_interrupted_preparation_releases_claim",_job getOrDefault ["retired",false]
    && {count A3I_interceptions == 0} && {A3A_tasksData isEqualTo []}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]}] call _check;
[_destination,_source] remoteExecCall ["A3I_fnc_startInterception",2]; sleep 0.3;
["idis_constructor_remote_refused",count A3I_interceptions == 0] call _check;
bigAttackInProgress = true;
["idis_major_battle_blocks_creation",!(([_destination,_source] call A3I_fnc_startInterception) # 0)] call _check;
bigAttackInProgress = false;
A3A_tasksData = [["foreign","CONVOY","CREATED"]];
["idis_existing_native_task_blocks_creation",!(([_destination,_source] call A3I_fnc_startInterception) # 0)
    && {A3A_tasksData isEqualTo [["foreign","CONVOY","CREATED"]]}] call _check;
A3A_tasksData = [];
sidesX setVariable [_source,east,true];
["idis_russian_source_refused",!(([_destination,_source] call A3I_fnc_startInterception) # 0)
    && {count A3I_interceptions == 0}] call _check;
sidesX setVariable [_source,west,true];

private _savedFaction = A3A_faction_occ;
A3A_faction_occ = createHashMap;
["CONVOY",2,true] call A3A_fnc_missionRequest;
[_destination,_source] call A3A_fnc_CONVOY;
[["unchanged"],"A3A_fnc_convoy"] call A3A_fnc_scheduler;
["Medium",east] call A3A_fnc_selectIntel;
["idis_ordinary_delegation",A3I_test_originals isEqualTo [
    ["missionRequest",["CONVOY",2,true]],["originalConvoy",[_destination,_source]],
    ["originalScheduler",[["unchanged"],"A3A_fnc_convoy"]],["originalSelectIntel",["Medium",east]]]] call _check;
A3A_faction_occ = _savedFaction; A3I_test_originals = [];
{
    private _entry = _x;
    switch (_entry) do {
        case "direct": {[_destination,_source] call A3A_fnc_CONVOY};
        case "scheduler": {hcArray = [98765]; [[_destination,_source],"a3a_fnc_convoy"] call A3A_fnc_scheduler};
        case "request": {["CONVOY",2,false] call A3A_fnc_missionRequest};
        case "remote_request": {["CONVOY",2,true] remoteExecCall ["A3A_fnc_missionRequest",2]};
    };
    _job = call _getJob;
    ["idis_entry_" + _entry,count _job > 0 && {_job getOrDefault ["taskRegistered",false]}
        && {_job get "created" == 40} && {A3I_test_originals isEqualTo []}
        && {isNil "A3A_missionRequestInProgress"}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach ["direct","scheduler","request","remote_request"];
hcArray = [];
A3A_missionRequestInProgress = true;
private _waiting = ["CONVOY",2,true] spawn A3A_fnc_missionRequest;
sleep 0.3;
["idis_foreign_request_lock_waits",count A3I_interceptions == 0
    && {A3A_missionRequestInProgress} && {!scriptDone _waiting}] call _check;
terminate _waiting; sleep 0.2;
["idis_stopped_request_preserves_foreign_lock",A3A_missionRequestInProgress
    && {count A3I_interceptions == 0}] call _check;
A3A_missionRequestInProgress = nil;
private _leader = _hqGroup createUnit ["I_G_Soldier_F",_hqPosition,[],0,"NONE"];
_hqGroup selectLeader _leader;
["CONVOY",2,true] call A3A_fnc_missionRequest;
["idis_native_hq_leader_gate",count A3I_interceptions == 0] call _check;
_hqGroup selectLeader petros; deleteVehicle _leader;
sidesX setVariable [_source,east,true]; A3I_test_comms = [];
["CONVOY",2,false] call A3A_fnc_missionRequest; sleep 0.3;
["idis_unavailable_request_has_no_legacy_fallback",count A3I_interceptions == 0
    && {A3I_test_originals isEqualTo []} && {count A3I_test_comms == 2}] call _check;
sidesX setVariable [_source,west,true];
private _intel = [] call A3I_fnc_interceptionIntel;
_job = call _getJob;
["idis_intel_matches_actual_route",count _job > 0 && {_job getOrDefault ["taskRegistered",false]}
    && {_intel find "Horde Interception" >= 0}
    && {_intel find ([_job get "source"] call A3A_fnc_localizar) >= 0}
    && {_intel find ([_job get "target"] call A3A_fnc_localizar) >= 0}] call _check;
if (count _job > 0) then {[_job] call _retire};
["idis_both_menus_label_horde",getText (configFile >> "A3A_RequestMissionDialog" >> "Controls"
    >> "MainContent" >> "Controls" >> "ConvoyButton" >> "onLoad") == "_this call A3I_fnc_labelInterceptionControl"
    && {getText (configFile >> "missionMenu" >> "Controls" >> "convoyButton" >> "onLoad")
        == "_this call A3I_fnc_labelInterceptionControl"}] call _check;
["idis_intel_override_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "Intel" >> "selectIntel" >> "file")
    == "\x\a3i\addons\core\overrides\fn_selectIntel.sqf"] call _check;
[_savedCap,_savedContext] call _setLimits;
deleteVehicle petros; deleteGroup _hqGroup;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
A3I_test_observers = nil;
sleep 3;
["idis_complete_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_interceptions == 0}
    && {A3A_tasksData isEqualTo []} && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [count ((entities [[],[],true,false]) - _before),count (allGroups - _groupsBefore),call _stats]] call _check;
