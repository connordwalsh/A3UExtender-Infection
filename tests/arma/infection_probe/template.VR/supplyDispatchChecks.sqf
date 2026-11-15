// Actual truck creation/native tasks/resources with controlled VR travel/time.
#include "\x\a3a\addons\core\script_component.hpp"
private _before = entities [[],[],true,false];
private _groupsBefore = +allGroups;
private _vehicles = [];
private _group = createGroup teamPlayer;
sidesX = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_sdis_hq"; posHQ = [3000,4000,0];
private _town = "a3i_sdis_town"; private _site = "a3i_sdis_site";
private _friendly = "a3i_sdis_friendly";
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
A3I_test_originals = []; A3I_test_comms = []; hcArray = [];
private _bank = createVehicle ["Land_Can_V3_F",getMarkerPos _town,[],0,"CAN_COLLIDE"];
private _getJob = {
    [{count A3I_supplyTasks == 1}] call _wait;
    private _job = (values A3I_supplyTasks) param [0,createHashMap];
    if (count _job > 0) then {
        [{_job getOrDefault ["taskRegistered",false] || {_job getOrDefault ["settled",false]}}] call _wait;
        private _truck = _job get "truck"; _vehicles pushBack _truck;
        if (!isNull _truck) then {_truck enableSimulationGlobal false};
    };
    _job
};
private _retire = {
    params ["_job"];
    deleteVehicle (_job get "truck");
    [{_job get "settled"}] call _wait;
    _job set ["taskDeleteAt",time-1];
    [{count A3I_supplyTasks == 0 && {isNil "A3I_supplyTaskHandle"}}] call _wait;
};
private _variants = ["Ammo","Bank","Salvage","Airdrop","Crashsite","Helicrash"];
private _savedFaction = A3A_faction_occ;
A3A_faction_occ = createHashMap;
private _expected = [];
{
    private _arguments = [[_site],[_bank]] select (_x == "Bank");
    _arguments call (missionNamespace getVariable ("A3A_fnc_LOG_"+_x));
    _expected pushBack ["originalLOG"+_x,_arguments];
} forEach _variants;
["LOG",2,true] call A3A_fnc_missionRequest;
[["unchanged"],"A3A_fnc_LOG_Ammo"] call A3A_fnc_scheduler;
_expected append [["missionRequest",["LOG",2,true]],["originalScheduler",[["unchanged"],"A3A_fnc_LOG_Ammo"]]];
["sdis_ordinary_campaign_delegation",A3I_test_originals isEqualTo _expected] call _check;
A3A_faction_occ = _savedFaction; A3I_test_originals = [];
{
    private _kind = _x;
    private _arguments = [[_site],[_bank]] select (_kind == "Bank");
    _arguments call (missionNamespace getVariable ("A3A_fnc_LOG_"+_kind));
    private _job = call _getJob;
    ["sdis_direct_"+_kind,count _job > 0 && {_job getOrDefault ["taskRegistered",false]}
        && {_job get "source" == ([_site,_town] select (_kind == "Bank"))}
        && {alive (_job get "truck")} && {A3I_test_originals isEqualTo []}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach _variants;
{
    hcArray = [98765];
    [[_site],"A3A_fnc_LOG_"+_x] call A3A_fnc_scheduler;
    private _job = call _getJob;
    ["sdis_scheduler_"+_x,count _job > 0 && {_job getOrDefault ["taskRegistered",false]}
        && {local (_job get "truck")} && {A3I_test_originals isEqualTo []}] call _check;
    if (count _job > 0) then {[_job] call _retire};
} forEach _variants;
hcArray = [];
["LOG",2,false] call A3A_fnc_missionRequest;
private _job = call _getJob;
[{A3I_test_comms isNotEqualTo []},2] call _wait;
["sdis_request_registered_before_success",count _job > 0 && {_job getOrDefault ["taskRegistered",false]}
    && {A3I_test_comms findIf {(_x param [2,""]) == localize "STR_chats_mission_request_success"} >= 0}
    && {isNil "A3A_missionRequestInProgress"}] call _check;
private _serial = A3I_supplySerial;
["LOG",2,true] call A3A_fnc_missionRequest;
["sdis_duplicate_request_refused",A3I_supplySerial == _serial && {count A3I_supplyTasks == 1}] call _check;
if (count _job > 0) then {[_job] call _retire};
A3I_test_comms = [];
["LOG",2,true] remoteExecCall ["A3A_fnc_missionRequest",2];
_job = call _getJob; sleep 0.2;
["sdis_remote_silent_request",count _job > 0 && {_job getOrDefault ["taskRegistered",false]}
    && {A3I_test_comms isEqualTo []}] call _check;
if (count _job > 0) then {[_job] call _retire};
[_site,"fuel"] remoteExecCall ["A3I_fnc_startSupplySeizure",2]; sleep 0.2;
["sdis_remote_constructor_refused",count A3I_supplyTasks == 0] call _check;
A3A_missionRequestInProgress = true;
private _waiting = ["LOG",2,true] spawn A3A_fnc_missionRequest;
sleep 0.2;
["sdis_foreign_lock_waits",count A3I_supplyTasks == 0 && {!scriptDone _waiting}] call _check;
terminate _waiting; sleep 0.2;
["sdis_stopped_request_preserves_lock",A3A_missionRequestInProgress && {count A3I_supplyTasks == 0}] call _check;
A3A_missionRequestInProgress = nil;
sidesX setVariable [_site,east]; sidesX setVariable [_town,teamPlayer];
["LOG",2,false] call A3A_fnc_missionRequest; sleep 0.2;
["sdis_unavailable_no_fallback",count A3I_supplyTasks == 0 && {A3I_test_originals isEqualTo []}
    && {A3I_test_comms findIf {(_x param [2,""]) == "No Supplies Seizure is available."} >= 0}] call _check;
sidesX setVariable [_site,west]; sidesX setVariable [_town,west];
_bank setPosATL [9000,9000,0];
[_bank] call A3A_fnc_LOG_Bank;
[""] call A3A_fnc_LOG_Ammo;
["missing_marker"] call A3A_fnc_LOG_Crashsite;
sleep 0.5;
["sdis_invalid_legacy_source_refused",count A3I_supplyTasks == 0 && {A3I_test_originals isEqualTo []}] call _check;
private _leader = _group createUnit ["I_G_Soldier_F",posHQ,[],0,"NONE"];
_group selectLeader _leader;
["LOG",2,true] call A3A_fnc_missionRequest; sleep 0.2;
["sdis_hq_leader_gate",count A3I_supplyTasks == 0] call _check;
_group selectLeader petros; deleteVehicle _leader;
private _modern = configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent" >> "Controls" >> "LogisticsButton";
private _legacy = configFile >> "missionMenu" >> "Controls" >> "logButton";
["sdis_menu_hooks_preserve_native_actions",getText (_modern >> "onLoad") == "_this call A3I_fnc_labelSupplyControl"
    && {getText (_legacy >> "onLoad") == "_this call A3I_fnc_labelSupplyControl"}
    && {configName (inheritsFrom _modern) == "A3A_Button"} && {configName (inheritsFrom _legacy) == "SimpleButton"}
    && {getText (_modern >> "onButtonClick") != ""} && {getText (_legacy >> "action") != ""}] call _check;
["sdis_all_endpoints_registered",(_variants findIf {
    getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> ("LOG_"+_x) >> "file")
        != ("\x\a3i\addons\core\overrides\fn_LOG_"+_x+".sqf")
}) == -1] call _check;
{if (!isNull _x) then {deleteVehicle _x}} forEach _vehicles;
{deleteVehicle _x} forEach [petros,sidesX,server,_bank];
{deleteMarker _x} forEach _markers;
sleep 0.3; deleteGroup _group; sleep 0.5;
["sdis_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {A3A_tasksData isEqualTo []}
    && {A3A_activeTasks isEqualTo []} && {count A3I_supplyTasks == 0}
    && {isNil "A3I_supplyTaskHandle"}] call _check;
