// Dedicated mission contracts. Arrivals/deadlines are injected; no player UI,
// HC process, save or complete campaign acceptance is implied.
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
private _wait = {
    params ["_predicate",["_timeout",8]];
    private _deadline = diag_tickTime + _timeout;
    waitUntil {sleep 0.05;call _predicate || {diag_tickTime > _deadline}};
    call _predicate
};
private _source = "a3i_comp_town";
private _target = "a3i_comp_factory";
private _ordinary = "a3i_comp_ordinary";
private _position = [5000,4500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
killZones = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "Synd_HQ";
createMarker [_source,[4000,4500,0]];
createMarker [_target,_position];
createMarker [_ordinary,[8000,4500,0]];
createMarker [respawnTeamPlayer,[5200,4500,0]];
private _markers = [_source,_target,_ordinary,respawnTeamPlayer];
{
    _x setMarkerShape "ELLIPSE"; _x setMarkerSize [50,50];
    sidesX setVariable [_x,west]; spawner setVariable [_x,2];
    garrison setVariable [_x,[]]; server setVariable [_x,0];
} forEach _markers;
sidesX setVariable [_target,Invaders]; sidesX setVariable [_ordinary,Invaders];
sidesX setVariable [respawnTeamPlayer,teamPlayer];
citiesX = [_source]; factories = [_target,_ordinary];
airportsX = []; outposts = []; milbases = []; resourcesX = []; seaports = [];
milAdministrationsX = []; controlsX = []; markersX = +_markers; forcedSpawn = [];
antennas = []; antennasDead = []; staticsToSave = []; A3A_milBuildingWhitelist = [];
distanceSPWN = 1000; distanceSPWN1 = 1000; distanceSPWN2 = 1000;
distanceForLandAttack = 2000; distanceMission = 1500;
NavGrid = [[[4000,4500,0],1,0,[[1,0,1000]]],[[5000,4500,0],1,0,[[0,0,1000]]]];
A3A_navCellHM = createHashMap; {_forEachIndex call A3A_fnc_addToNavCells} forEach NavGrid;
A3A_markerNavPoints = createHashMap;
A3A_recentDamageOcc = []; A3A_recentDamageInv = [];
A3A_hasACE = false; A3A_GCThreshold = 600;
GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_reb = createHashMapFromArray [["name","Fixture Rebels"],["diveGear",[]],["flyGear",[]]];
A3A_faction_inv = createHashMapFromArray [["name","Fixture Invaders"]];
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true],["currencySymbol","$"]];
A3A_supportStrikes = []; A3A_supportSpends = []; A3A_supportMarkerTypes = [[_target,0,0,1]];
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0;
A3A_balanceVehicleCost = 10; A3A_balancePlayerScale = 1; A3A_balanceResourceRate = 100;
bigAttackInProgress = false; HQAttackInProgress = false; theBoss = objNull;
areOccupantsDefeated = false; areInvadersDefeated = false;
tierWar = 0; gameMode = 3; plusGarrison = true; debug = false;
aggressionOccupants = 0; aggressionInvaders = 0;
resourcesIsChanging = false; limitHR = 0; server setVariable ["hr",100];
garrisonIsChanging = false; markersChanging = [];
{garrison setVariable [_x + "_preference",[["","","GROUP"]]]} forEach ["Other","Airport","Outpost","MilitaryBase"];
private _petrosGroup = createGroup [teamPlayer,true];
petros = _petrosGroup createUnit ["I_G_Soldier_F",[5200,4500,0],[],0,"NONE"];
petros enableSimulationGlobal false;
hcArray = [];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_comms = []; A3I_test_markerUpdates = [];
A3I_test_nativeMarkerChange = false; A3I_test_applyMarkerChange = false;
private _pressure = "";
private _reset = {
    if (_pressure != "") then {["close",[_pressure]] call A3I_fnc_budget; _pressure = ""};
    A3I_majorSourceCooldowns = createHashMap; A3A_recentDamageOcc = [];
    sidesX setVariable [_source,west]; spawner setVariable [_source,2];
    sidesX setVariable [_target,Invaders]; spawner setVariable [_target,2];
    server setVariable [_source,[100,0,70,0]];
    garrison setVariable [_target,[]];
    A3A_resourcesAttackOcc = 100; A3A_resourcesDefenceOcc = 100;
    A3A_resourcesAttackInv = 1000; A3A_resourcesDefenceInv = 1000;
    server setVariable ["resourcesFIA",0];
    A3I_test_support = []; A3I_test_comms = []; tierWar = 0;
    [1,1] call _setLimits;
    private _reserved = ["reserve",["competitive:pressure",1,1]] call A3I_fnc_budget;
    _pressure = _reserved # 1 # 0;
    (A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
};
private _getRecord = {A3I_competitiveMissions get ((keys A3I_competitiveMissions) # 0)};
private _launch = {
    params [["_hard",false]];
    call _reset; tierWar = [0,11] select _hard;
    if !([_target] call A3I_fnc_startCompetitiveMission) exitWith {createHashMap};
    private _record = call _getRecord;
    [{_record get "taskRegistered"}] call _wait;
    _record
};
private _state = {
    params ["_record"];
    private _index = A3A_tasksData findIf {_x # 0 == _record get "name"};
    if (_index < 0) then {"MISSING"} else {A3A_tasksData # _index # 2}
};
private _retire = {
    params ["_record"];
    [{_record get "settled"}] call _wait;
    private _horde = _record getOrDefault ["majorRecord",createHashMap];
    if (count _horde > 0) then {
        if (_horde get "outcome" == "pending") then {_horde set ["outcome","cancelled"]};
        [{_horde get "settled"}] call _wait;
        _horde set ["releaseAt",time - 1];
        [{!((_horde get "name") in A3I_majorAttacks)}] call _wait;
    };
    [{count A3I_competitiveMissions == 0}] call _wait;
    if (!isNil {_record get "taskDeleteScript"}) then {terminate (_record get "taskDeleteScript")};
    if ([_record] call _state != "MISSING") then {[_record get "name","CON",0] call A3A_fnc_taskDelete};
    [{!("CON" in A3A_activeTasks)}] call _wait;
    if (_pressure != "") then {["close",[_pressure]] call A3I_fnc_budget; _pressure = ""};
};
call _reset;
["comp_endpoints_registered",getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> "CON_Outpost_Compet" >> "file")
    == "\x\a3i\addons\core\overrides\fn_CON_Outpost_Compet.sqf" && {!isNil "A3I_fnc_competitiveCapture"}] call _check;
private _routes = [_target] call A3I_fnc_competitiveSources;
["comp_town_origin_available",count _routes == 1 && {_routes # 0 # 0 == _source}] call _check;
private _selection = [[_target,_ordinary],[_target,_ordinary]] call A3I_fnc_competitiveTargets;
["comp_town_frontline_added",!([_target] call A3A_fnc_isFrontlineNoFIA)
    && {_selection isEqualTo [[_target,_ordinary],[_target],[]]}] call _check;
citiesX = []; factories pushBack _source; server setVariable [_source,0];
["comp_factory_origin_available",count ([_target] call A3I_fnc_competitiveSources) == 1] call _check;
factories = factories - [_source]; citiesX = [_source]; server setVariable [_source,[100,0,70,0]];
A3I_majorSourceCooldowns set [_source,time + 600];
_selection = [[_target,_ordinary],[_target,_ordinary]] call A3I_fnc_competitiveTargets;
["comp_unavailable_not_ordinary_fallback",_selection isEqualTo [[_ordinary],[],[_target]]] call _check;
A3I_majorSourceCooldowns = createHashMap; A3A_recentDamageOcc = [[4000,4500,60]];
["comp_combat_source_unavailable",[_target] call A3I_fnc_competitiveSources isEqualTo []] call _check;
A3A_recentDamageOcc = []; _source setMarkerPos [9000,4500,0];
["comp_distant_source_unavailable",[_target] call A3I_fnc_competitiveSources isEqualTo []] call _check;
_source setMarkerPos [4000,4500,0];
private _savedNav = +NavGrid; NavGrid = [[[4000,4500,0],1,0,[]],[[5000,4500,0],1,0,[]]];
["comp_disconnected_source_unavailable",[_target] call A3I_fnc_competitiveSources isEqualTo []] call _check;
NavGrid = _savedNav; areOccupantsDefeated = true;
["comp_defeated_unavailable",!([_target] call A3I_fnc_startCompetitiveMission)] call _check;
areOccupantsDefeated = false; bigAttackInProgress = true;
["comp_foreign_attack_preserved",!([_target] call A3I_fnc_startCompetitiveMission) && {bigAttackInProgress}] call _check;
bigAttackInProgress = false;
private _atomic = true; isNil {_atomic = [_target] call A3I_fnc_startCompetitiveMission};
["comp_scheduled_entry_required",!_atomic] call _check;
A3A_faction_occ set ["infectionTemplate",""]; ["CON",2,true] call A3A_fnc_missionRequest;
[_target] call A3A_fnc_CON_Outpost_Compet;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"];
A3I_dependencies set ["available",false]; ["CON",2,true] call A3A_fnc_missionRequest;
A3I_dependencies set ["available",true]; ["DES",2,true] call A3A_fnc_missionRequest;
sidesX setVariable [_target,west]; [_target] call A3A_fnc_CON_Outpost_Compet;
sidesX setVariable [_target,Invaders];
["comp_unrelated_routes_delegate",A3I_test_originals isEqualTo [
    ["missionRequest",["CON",2,true]],["competitiveMission",[_target]],
    ["missionRequest",["CON",2,true]],["missionRequest",["DES",2,true]],
    ["competitiveMission",[_target]]]] call _check;
A3I_test_originals = []; A3I_majorSourceCooldowns set [_source,time + 600];
["CON",2,false] call A3A_fnc_missionRequest; sleep 0.2;
["comp_request_unavailable_has_no_fallback",A3I_test_originals isEqualTo []
    && {A3A_tasksData isEqualTo []} && {isNil "A3A_missionRequestInProgress"}
    && {count A3I_test_comms == 2} && {A3A_resourcesAttackOcc == 100}] call _check;

private _record = [] call _launch;
if (count _record == 0) exitWith {["comp_launch_refused",false] call _check; [_savedCap,_savedContext] call _setLimits};
private _horde = _record get "majorRecord";
["comp_native_task_and_link",[_record] call _state == "CREATED" && {"CON" in A3A_activeTasks}
    && {_horde get "mission" == _record get "name"} && {_horde get "fixedCost" == 0}
    && {_horde get "paidActors" == 0} && {A3A_resourcesAttackOcc == 100}] call _check;
["comp_duplicate_refused",!([_target] call A3I_fnc_startCompetitiveMission)
    && {count A3I_competitiveMissions == 1} && {count A3I_majorAttacks == 1}] call _check;
[_target,west] remoteExecCall ["A3I_fnc_competitiveCapture",2]; sleep 0.2;
["comp_unverified_remote_capture_rejected",_record get "outcome" == "pending" && {[_record] call _state == "CREATED"}] call _check;
isNil {
    sidesX setVariable [_target,west];
    [CBA_EVENT_SERVER_MARKER_CHANGE,[_target,west,Invaders]] call A3A_fnc_triggerLocalEvent;
    sidesX setVariable [_target,teamPlayer];
    [CBA_EVENT_SERVER_MARKER_CHANGE,[_target,teamPlayer,west]] call A3A_fnc_triggerLocalEvent;
};
["comp_first_infected_capture_freezes_failure",_record get "outcome" == "lost_race"] call _check;
[{[_record] call _state == "FAILED" && {A3A_resourcesAttackInv == 1060}}] call _wait;
[_record] call A3I_fnc_finishCompetitiveMission; sleep 0.2;
["comp_failure_immediate_and_once",[_record] call _state == "FAILED"
    && {A3A_resourcesAttackInv == 1060} && {A3A_resourcesDefenceInv == 1060}
    && {server getVariable "resourcesFIA" == 0} && {A3I_test_support isEqualTo [[5,0,_position]]}] call _check;
[_record] call _retire;

{
    private _hard = _x;
    _record = [_hard] call _launch;
    isNil {
        sidesX setVariable [_target,teamPlayer];
        [CBA_EVENT_SERVER_MARKER_CHANGE,[_target,teamPlayer,Invaders]] call A3A_fnc_triggerLocalEvent;
        sidesX setVariable [_target,west];
        [CBA_EVENT_SERVER_MARKER_CHANGE,[_target,west,teamPlayer]] call A3A_fnc_triggerLocalEvent;
    };
    [{server getVariable "resourcesFIA" == ([600,800] select _hard)}] call _wait;
    [_record] call A3I_fnc_finishCompetitiveMission; sleep 0.2;
    ["comp_success_once_" + str _hard,_record get "outcome" == "won" && {[_record] call _state == "SUCCEEDED"}
        && {server getVariable "resourcesFIA" == ([600,800] select _hard)}
        && {A3A_resourcesAttackInv == ([880,820] select _hard)}
        && {A3A_resourcesDefenceInv == ([880,820] select _hard)}
        && {A3I_test_support isEqualTo [[[ -20,-25] select _hard,0,_position]]}] call _check;
    [_record] call _retire;
} forEach [false,true];

_record = [true] call _launch;
_record set ["deadline",dateToNumber date - 0.001];
sidesX setVariable [_target,teamPlayer];
[CBA_EVENT_SERVER_MARKER_CHANGE,[_target,teamPlayer,Invaders]] call A3A_fnc_triggerLocalEvent;
[{[_record] call _state == "FAILED" && {A3A_resourcesAttackInv == 1120}}] call _wait;
["comp_late_capture_times_out",_record get "outcome" == "timeout" && {server getVariable "resourcesFIA" == 0}
    && {A3A_resourcesDefenceInv == 1120} && {A3I_test_support isEqualTo [[25,0,_position]]}] call _check;
[_record] call _retire;
_record = [] call _launch;
_record set ["deadline",dateToNumber date - 0.001];
sidesX setVariable [_target,teamPlayer];
[{_record get "settled"}] call _wait;
["comp_poll_deadline_precedes_late_owner",_record get "outcome" == "timeout"
    && {[_record] call _state == "FAILED"}] call _check;
[_record] call _retire;

_record = [] call _launch;
_horde = _record get "majorRecord"; _horde set ["emptyDeadline",time - 1];
[{_record get "settled"}] call _wait;
["comp_zero_force_cancels_without_reward",_record get "outcome" == "cancelled"
    && {_horde get "outcome" == "no_force"} && {A3A_resourcesAttackOcc == 100}
    && {A3A_resourcesAttackInv == 1000} && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;

_record = [] call _launch;
_horde = _record get "majorRecord";
["close",[_pressure]] call A3I_fnc_budget; _pressure = ""; [2,2] call _setLimits;
[{_horde get "paidActors" == 2},7] call _wait;
["comp_real_horde_shares_budget",_horde get "paidActors" == 2
    && {count (_horde get "queue") == (_horde get "planned") - 2}
    && {A3A_resourcesAttackOcc == 80} && {(["stats"] call A3I_fnc_budget) # 1 # 1 == 2}] call _check;
terminate (_record get "script"); [_record] call _retire;
[{A3A_resourcesAttackOcc == 100}] call _wait;
["comp_stopped_parent_cancels_refunds_horde",_record get "outcome" == "interrupted"
    && {_horde get "outcome" == "cancelled"} && {_horde get "queue" isEqualTo []}
    && {A3A_resourcesAttackOcc == 100} && {server getVariable "resourcesFIA" == 0}
    && {A3A_tasksData isEqualTo []}] call _check;

_record = [] call _launch;
// Reproduce interruption after native registration but before the local flag.
_record set ["taskRegistered",false]; terminate (_record get "script");
[{_record get "settled" && {!("CON" in A3A_activeTasks)}}] call _wait;
["comp_partial_registration_recovers",_record get "outcome" == "interrupted"
    && {[_record] call _state == "MISSING"} && {A3A_tasksData isEqualTo []}] call _check;
[_record] call _retire;
_record = [] call _launch; _horde = _record get "majorRecord";
// Reproduce a stopped parent before it saved the horde launch result.
_record deleteAt "majorRecord"; terminate (_record get "script");
[{_record get "settled" && {_horde get "outcome" == "cancelled"}}] call _wait;
["comp_unreturned_child_recovered_by_token",_horde get "outcome" == "cancelled"
    && {_horde get "queue" isEqualTo []} && {_horde get "creditRemaining" == 0}] call _check;
_record set ["majorRecord",_horde]; [_record] call _retire;

call _reset;
isNil {
    // Queue a valid launch, then the scheduled worker must still claim locally.
    [_target] remoteExec ["A3I_fnc_startCompetitiveMission",2];
};
sleep 0.3;
["comp_direct_remote_start_rejected",count A3I_competitiveMissions == 0 && {!bigAttackInProgress}] call _check;
hcArray = [98765]; [[_target],"A3A_fnc_CON_Outpost_Compet"] call A3A_fnc_scheduler;
[{count A3I_competitiveMissions == 1}] call _wait;
_record = call _getRecord; [{_record get "taskRegistered"}] call _wait;
["comp_scheduler_keeps_server_worker",_record get "taskRegistered" && {_record get "source" == _source}
    && {A3I_test_originals isEqualTo []}] call _check;
terminate (_record get "script"); [_record] call _retire; hcArray = [];
call _reset;
["CON",2,true] remoteExec ["A3A_fnc_missionRequest",2];
[{count A3I_competitiveMissions == 1}] call _wait;
_record = call _getRecord; [{_record get "taskRegistered" && {isNil "A3A_missionRequestInProgress"}}] call _wait;
["comp_remote_request_local_worker",_record get "taskRegistered" && {[_record] call _state == "CREATED"}
    && {isNil "A3A_missionRequestInProgress"}] call _check;
terminate (_record get "script"); [_record] call _retire;

// Actual installed capture transaction, including its remotely inherited event.
_record = [] call _launch;
reinforceMarkerOccupants = []; reinforceMarkerInvaders = [[0,_target]];
canReinforceOccupants = []; canReinforceInvaders = [_target];
A3I_test_nativeMarkerChange = true;
[west,_target] remoteExec ["A3A_fnc_markerChange",2];
[{_record get "outcome" == "lost_race" && {[_record] call _state == "FAILED"}}] call _wait;
["comp_native_remote_capture_fails",sidesX getVariable _target == west
    && {_record get "outcome" == "lost_race"} && {[_record] call _state == "FAILED"}
    && {markersChanging isEqualTo []}] call _check;
sleep 1.5; A3I_test_nativeMarkerChange = false;
[_record] call _retire;

A3I_test_compTicks = 0;
private _foreign = [{A3I_test_compTicks = A3I_test_compTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
[[],_foreign] remoteExecCall ["A3I_fnc_competitiveWatchdog",2]; sleep 0.6;
["comp_remote_watchdog_rejected",A3I_test_compTicks >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
deleteVehicle petros; [[_petrosGroup]] call A3I_fnc_cleanupGroups;
[{allGroups - _groupsBefore isEqualTo [] && {isNil "A3I_groupCleanupHandle"}}] call _wait;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
[_savedCap,_savedContext] call _setLimits;
sleep 0.2;
["comp_all_clean",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {isNil "A3I_groupCleanupHandle"}
    && {A3I_retiredGroups isEqualTo []} && {count A3I_competitiveMissions == 0}
    && {isNil "A3I_competitiveWatchdogHandle"} && {isNil "A3I_competitiveCaptureHandle"}
    && {count A3I_majorAttacks == 0} && {isNil "A3I_majorWatchdogHandle"}
    && {A3A_tasksData isEqualTo []} && {A3A_activeTasks isEqualTo []}
    && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}
    && {(["stats"] call A3I_fnc_budget) # 1 select [1,3] isEqualTo [0,0,0]}] call _check;
