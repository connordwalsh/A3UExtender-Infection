// Real native creatures/tasks/rewards; controlled travel, time and observers.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false]; private _groupsBefore = +allGroups;
sidesX = [true] call A3A_fnc_createNamespace; spawner = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_edis_hq"; private _site = "a3i_edis_site";
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
A3I_test_markerUpdates = []; A3I_test_eliminationNative = false;
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
A3I_test_originals = []; A3I_test_comms = []; hcArray = [];
private _variants = ["AS_Ambush","AS_Official","AS_Smasher","AS_specOP","AS_Traitor","AS_Zombies","RIV_AS_Traitor"];
private _savedFaction = A3A_faction_occ;
A3A_faction_occ = createHashMap;
private _expected = [];
{
    [_site] call (missionNamespace getVariable ("A3A_fnc_"+_x));
    _expected pushBack ["original"+((_x splitString "_") joinString ""),[_site]];
} forEach _variants;
["AS",2,true] call A3A_fnc_missionRequest;
[[_site],"A3A_fnc_AS_Zombies"] call A3A_fnc_scheduler;
_expected append [["missionRequest",["AS",2,true]],["originalScheduler",[[_site],"A3A_fnc_AS_Zombies"]]];
["edis_ordinary_delegation",A3I_test_originals isEqualTo _expected] call _check;
A3A_faction_occ = _savedFaction; A3I_test_originals = [];
private _getJob = {
    [{count A3I_eliminationTasks == 1}] call _wait;
    private _job = (values A3I_eliminationTasks) param [0,createHashMap];
    if (count _job > 0) then {
        [{_job get "phase" != "preparing"}] call _wait;
        {_x enableSimulationGlobal false} forEach (_job get "units");
    };
    _job
};
{
    [_site] call (missionNamespace getVariable ("A3A_fnc_"+_x));
    private _job = call _getJob;
    ["edis_direct_"+_x,count _job > 0 && {_job get "taskRegistered"}
        && {_job get "source" == _site} && {A3I_test_originals isEqualTo []}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach _variants;
{
    hcArray = [98765];
    [[_site],"A3A_fnc_"+_x] call A3A_fnc_scheduler;
    private _job = call _getJob;
    ["edis_scheduler_"+_x,count _job > 0 && {_job get "taskRegistered"}
        && {local ((_job get "ledger") get "unit")} && {A3I_test_originals isEqualTo []}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach _variants;
hcArray = [];
["AS",2,false] call A3A_fnc_missionRequest;
private _job = call _getJob;
[{A3I_test_comms isNotEqualTo []},2] call _wait;
["edis_request_registered_before_success",count _job > 0 && {_job get "taskRegistered"}
    && {A3I_test_comms findIf {(_x param [2,""]) == localize "STR_chats_mission_request_success"} >= 0}] call _check;
private _serial = A3I_eliminationTaskSerial;
["AS",2,true] call A3A_fnc_missionRequest;
["edis_duplicate_request",A3I_eliminationTaskSerial == _serial && {count A3I_eliminationTasks == 1}] call _check;
if (count _job > 0) then {[_job] call _retire};
A3I_test_comms = [];
["AS",2,true] remoteExecCall ["A3A_fnc_missionRequest",2];
_job = call _getJob; sleep 0.2;
["edis_remote_silent_request",count _job > 0 && {_job get "taskRegistered"} && {A3I_test_comms isEqualTo []}] call _check;
if (count _job > 0) then {[_job] call _retire};
[_site] remoteExecCall ["A3I_fnc_startElimination",2]; sleep 0.2;
["edis_remote_constructor_refused",count A3I_eliminationTasks == 0] call _check;
A3A_missionRequestInProgress = true;
private _waiting = ["AS",2,true] spawn A3A_fnc_missionRequest; sleep 0.2;
["edis_foreign_lock_waits",count A3I_eliminationTasks == 0 && {!scriptDone _waiting}] call _check;
terminate _waiting; sleep 0.2;
["edis_stopped_request_preserves_lock",A3A_missionRequestInProgress && {count A3I_eliminationTasks == 0}] call _check;
A3A_missionRequestInProgress = nil;
sidesX setVariable [_site,east];
["AS",2,false] call A3A_fnc_missionRequest; sleep 0.2;
["edis_unavailable_no_fallback",count A3I_eliminationTasks == 0 && {A3I_test_originals isEqualTo []}
    && {A3I_test_comms findIf {(_x param [2,""]) == "No Elimination Task is available."} >= 0}] call _check;
[_site] call A3A_fnc_AS_Zombies; ["missing_marker"] call A3A_fnc_AS_Official;
[""] call A3A_fnc_RIV_AS_Traitor; sleep 0.5;
["edis_invalid_source_refused",count A3I_eliminationTasks == 0 && {A3I_test_originals isEqualTo []}] call _check;
sidesX setVariable [_site,west];
private _leader = _group createUnit ["I_G_Soldier_F",[3000,4000,0],[],0,"NONE"]; _group selectLeader _leader;
["AS",2,true] call A3A_fnc_missionRequest; sleep 0.2;
["edis_hq_leader_gate",count A3I_eliminationTasks == 0] call _check;
_group selectLeader petros; deleteVehicle _leader;
private _modern = configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent" >> "Controls" >> "AssassinationButton";
private _legacy = configFile >> "missionMenu" >> "Controls" >> "asButton";
["edis_menu_hooks",getText (_modern >> "onLoad") == "_this call A3I_fnc_labelEliminationControl"
    && {getText (_legacy >> "onLoad") == "_this call A3I_fnc_labelEliminationControl"}
    && {configName (inheritsFrom _modern) == "A3A_Button"} && {configName (inheritsFrom _legacy) == "SimpleButton"}
    && {getText (_modern >> "onButtonClick") != ""} && {getText (_legacy >> "action") != ""}] call _check;
["edis_endpoint_registrations",(_variants findIf {
    getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> _x >> "file")
        != ("\x\a3i\addons\core\overrides\fn_"+_x+".sqf")
}) == -1] call _check;
["A3I_activeLimit",_savedCap,2,"server",false] call CBA_settings_fnc_set;
["A3I_contextLimit",_savedContext,2,"server",false] call CBA_settings_fnc_set;
{deleteVehicle _x} forEach [petros,sidesX,spawner,server]; deleteMarker _site; deleteMarker respawnTeamPlayer;
sleep 0.3; deleteGroup _group; sleep 1;
["edis_cleanup",(entities [[],[],true,false]) - _before isEqualTo [] && {allGroups - _groupsBefore isEqualTo []}
    && {A3A_tasksData isEqualTo []} && {A3A_activeTasks isEqualTo []}
    && {count A3I_eliminationTasks == 0} && {isNil "A3I_eliminationTaskHandle"}
    && {count A3I_eliminationLedgers == 0} && {isNil "A3I_eliminationLedgerHandle"}] call _check;
