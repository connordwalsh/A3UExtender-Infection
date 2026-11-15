// Real native creatures/tasks/rewards; controlled travel, time and observers.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace; spawner = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_etask_hq"; private _site = "a3i_etask_site";
createMarker [respawnTeamPlayer,[3000,4000,0]]; createMarker [_site,[4500,4500,0]];
_site setMarkerShape "ELLIPSE"; _site setMarkerSize [100,100];
sidesX setVariable [_site,west]; spawner setVariable [_site,2];
markersX = [_site,respawnTeamPlayer]; citiesX = [_site];
airportsX = []; milbases = []; outposts = []; factories = []; resourcesX = []; seaports = []; milAdministrationsX = []; controlsX = [];
A3A_townData = createHashMapFromArray [[_site,[200,0,50,20]]]; destroyedSites = [];
private _group = createGroup teamPlayer;
petros = _group createUnit ["I_G_Soldier_F",[3000,4000,0],[],0,"NONE"];
petros enableSimulationGlobal false; petros setCaptive true; petros allowDamage false;
distanceMission = 3000; distanceSPWN = 300; tierWar = 0; plusGarrison = false;
A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_resourcesAttackOcc = 1000; A3A_resourcesDefenceOcc = 1000;
A3A_recentDamageOcc = []; A3A_hasACE = false;
A3A_faction_reb = createHashMapFromArray [["name","NATO"]];
A3A_faction_civ = createHashMapFromArray [["currencySymbol","$"]]; theBoss = objNull;
A3I_test_comms = [];
A3I_test_support = []; A3I_test_aggression = []; A3I_test_observers = [];
A3I_test_markerUpdates = []; A3I_test_eliminationNative = true;
cityIsSupportChanging = false; gameMode = 1;
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0;
A3I_eliminationTasks = createHashMap; resourcesIsChanging = false; limitHR = 0;
server setVariable ["hr",10]; server setVariable ["resourcesFIA",1000];
private _savedCap = A3I_activeLimit; private _savedContext = A3I_contextLimit;
["A3I_activeLimit",40,2,"server",false] call CBA_settings_fnc_set;
["A3I_contextLimit",12,2,"server",false] call CBA_settings_fnc_set;
private _wait = {
    params ["_condition",["_seconds",8]]; private _until = diag_tickTime+_seconds;
    waitUntil {sleep 0.05; call _condition || {diag_tickTime > _until}}; call _condition
};
private _stats = {(["stats"] call A3I_fnc_budget) # 1};
private _start = {
    params [["_class","Zombie_Special_BLUFOR_Screamer"]];
    private _accepted = [_site,_class] call A3I_fnc_startElimination;
    private _job = A3I_eliminationTasks getOrDefault ["A3I_ELIM_"+str A3I_eliminationTaskSerial,createHashMap];
    if (count _job > 0) then {
        [{_job get "phase" != "preparing"}] call _wait;
        {_x enableSimulationGlobal false} forEach (_job get "units");
    };
    [_accepted,_job]
};
private _state = {
    params ["_job"]; private _idx = A3A_tasksData findIf {_x # 0 == _job get "name"};
    if (_idx < 0) then {"MISSING"} else {A3A_tasksData # _idx # 2}
};
private _retire = {
    params ["_job"];
    if !(_job get "settled") then {
        _job set ["fault","fixture_retirement"];
        [{_job get "settled"}] call _wait;
    };
    _job set ["taskDeleteAt",time-1]; A3I_test_observers = [];
    [{!((_job get "name") in A3I_eliminationTasks) && {(call _stats) select [1,2] isEqualTo [0,0]}}] call _wait;
};
A3A_tasksData = [["foreign_as","AS","CREATED",time]];
["etask_foreign_task_busy",!([_site] call A3I_fnc_startElimination) && {count A3I_eliminationTasks == 0}] call _check;
A3A_tasksData = [];
private _made = [] call _start; private _job = _made # 1;
private _target = (_job get "ledger") get "unit";
private _search = _job get "searchMarker";
private _description = [_job get "name"] call BIS_fnc_taskDescription;
["etask_created",_made # 0 && {_job get "phase" == "active"} && {count (_job get "units") == 6}
    && {[_job] call _state == "CREATED"} && {"AS" in A3A_activeTasks}] call _check;
["etask_search_and_type",_search in allMapMarkers && {markerShape _search == "ELLIPSE"}
    && {markerSize _search isEqualTo [100,100]} && {getMarkerPos _search isEqualTo getMarkerPos _site}
    && {(format (_description # 0)) find getText (configFile >> "CfgVehicles" >> typeOf _target >> "displayName") >= 0},[_search,markerShape _search,markerSize _search,_description]] call _check;
["etask_escorts_different_type",((_job get "units") select [1]) findIf {typeOf _x == typeOf _target} == -1] call _check;
["etask_normal_deadline",_job get "duration" == 3600 && {_job get "deadline" > time+3590}] call _check;
["etask_duplicate_refused",!([_site] call A3I_fnc_startElimination) && {count A3I_eliminationTasks == 1}] call _check;
private _lastPosition = getMarkerPos _search;
_target setPosATL [4700,4500,0]; sleep 0.2;
["etask_search_does_not_track",getMarkerPos _search isEqualTo _lastPosition] call _check;
sidesX setVariable [_site,teamPlayer];
["etask_rebel_capture_continues",[_job] call A3I_fnc_eliminationTaskOutcome == "pending"] call _check;
sidesX setVariable [_site,east];
["etask_russian_capture_continues",[_job] call A3I_fnc_eliminationTaskOutcome == "pending"] call _check;
sidesX setVariable [_site,west];
private _escort = (_job get "units") # 1; _escort setPosATL [6000,6000,0]; _escort setDamage 1;
sleep 0.2;
["etask_escort_death_not_success",[_job] call A3I_fnc_eliminationTaskOutcome == "pending"] call _check;
petros setPosATL getPosATL _target; A3I_test_observers = [petros];
_target setDamage 1;
[{_job get "settled" && {server getVariable "resourcesFIA" == 2000} && {([_job] call _state) == "SUCCEEDED"}}] call _wait;
["etask_neutralized",_job get "outcome" == "neutralized" && {([_job] call _state) == "SUCCEEDED"},[_job get "outcome",[_job] call _state]] call _check;
[{(A3A_townData get _site) # 3 == 30}] call _wait;
["etask_native_rewards",server getVariable "resourcesFIA" == 2000 && {server getVariable "hr" == 10}
    && {(A3A_townData get _site) # 3 == 30}] call _check;
[_job] call A3I_fnc_finishElimination; sleep 0.2;
["etask_rewards_once",server getVariable "resourcesFIA" == 2000 && {count A3I_test_support == 1}] call _check;
["etask_marker_and_ledger_retired",!(_search in allMapMarkers) && {count A3I_eliminationLedgers == 0}] call _check;
["etask_native_task_retention",_job get "taskDeleteAt" > time+590 && {_job get "taskDeleteAt" <= time+1800}
    && {call A3I_fnc_eliminationTaskBusy}] call _check;
["etask_nearby_escorts_retained",((_job get "units") findIf {alive _x}) >= 0 && {!(_job get "assetRetired")}] call _check;
petros setPosATL [3000,4000,0]; [_job] call _retire;
["etask_unobserved_retirement",count A3I_eliminationTasks == 0 && {(call _stats) select [1,2] isEqualTo [0,0]}] call _check;
tierWar = 10; _made = ["Zombie_Special_BLUFOR_Leaper_2"] call _start; _job = _made # 1;
["etask_hard_roster_and_deadline",_made # 0 && {count (_job get "units") == 11} && {_job get "duration" == 1800}] call _check;
((_job get "ledger") get "unit") setDamage 1;
[{_job get "settled" && {server getVariable "resourcesFIA" == 4000}}] call _wait;
[{(A3A_townData get _site) # 3 == 50}] call _wait;
["etask_hard_rewards",_job get "outcome" == "neutralized" && {server getVariable "resourcesFIA" == 4000}
    && {(A3A_townData get _site) # 3 == 50}] call _check;
[_job] call _retire; tierWar = 0;
_made = [] call _start; _job = _made # 1;
(_job get "ledger") set ["deadline",time-1];
[{_job get "settled" && {([_job] call _state) == "FAILED"}}] call _wait;
["etask_timeout_fails",_job get "outcome" == "failed" && {[_job] call _state == "FAILED"}
    && {server getVariable "resourcesFIA" == 4000} && {sidesX getVariable _site == west}
    && {!(_site in destroyedSites)}] call _check;
[_job] call _retire;
_made = [] call _start; _job = _made # 1;
deleteVehicle ((_job get "ledger") get "unit");
[{_job get "settled"}] call _wait;
["etask_live_deletion_cancelled",_job get "outcome" == "interrupted"
    && {[_job get "name"] call BIS_fnc_taskState == "CANCELED"}
    && {server getVariable "resourcesFIA" == 4000}] call _check;
[_job] call _retire;
_made = [] call _start; _job = _made # 1;
private _foreign = (_job get "units") # 1;
_foreign setVariable ["A3I_eliminationTaskOwner",["other",77]];
[_job] call _retire;
["etask_foreign_actor_preserved",alive _foreign && {(_foreign getVariable "A3I_eliminationTaskOwner") isEqualTo ["other",77]}] call _check;
deleteVehicle _foreign; sleep 0.3;
// Stop the scheduled worker; the independent watchdog must retire it.
private _accepted = [_site] call A3I_fnc_startElimination;
_job = A3I_eliminationTasks get ("A3I_ELIM_"+str A3I_eliminationTaskSerial);
terminate (_job get "script");
[{count A3I_eliminationTasks == 0}] call _wait;
["etask_stopped_worker_recovered",_accepted && {count A3I_eliminationTasks == 0}
    && {(call _stats) select [1,2] isEqualTo [0,0]}] call _check;
// A rejected registration must roll back actual actors and budget slots.
private _rollback = [_site,"Zombie_Special_BLUFOR_Screamer",{false}] call A3I_fnc_spawnEliminationScene;
sleep 0.5;
["etask_registration_rollback",!(_rollback # 0) && {_rollback # 2 == "registration_failed"}
    && {(call _stats) select [1,2] isEqualTo [0,0]}] call _check;
A3I_test_eliminationNative = false;
["A3I_activeLimit",_savedCap,2,"server",false] call CBA_settings_fnc_set;
["A3I_contextLimit",_savedContext,2,"server",false] call CBA_settings_fnc_set;
{deleteVehicle _x} forEach [petros,sidesX,spawner,server]; deleteMarker _site; deleteMarker respawnTeamPlayer;
sleep 0.3; deleteGroup _group; sleep 1;
["etask_cleanup",(entities [[],[],true,false]) - _before isEqualTo [] && {allGroups - _groupsBefore isEqualTo []}
    && {A3A_tasksData isEqualTo []} && {A3A_activeTasks isEqualTo []}
    && {count A3I_eliminationTasks == 0} && {isNil "A3I_eliminationTaskHandle"}
    && {count A3I_eliminationLedgers == 0} && {isNil "A3I_eliminationLedgerHandle"}] call _check;
