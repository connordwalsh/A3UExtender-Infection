// Controlled live ownership transitions with native campaign side effects.
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
private _source = "a3i_ldis_town";
private _target = "a3i_ldis_factory";
private _ordinary = "a3i_ldis_ordinary";
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
A3A_invaderBalanceMul = 10; A3A_balanceVehicleCost = 10; A3A_balancePlayerScale = 1; A3A_balanceResourceRate = 100;
bigAttackInProgress = false; HQAttackInProgress = false; theBoss = objNull;
areOccupantsDefeated = false; areInvadersDefeated = false;
// Keep fixture garrison preferences fixed while native tierCheck still runs.
tierPreference = 10; tierWar = 0; gameMode = 3; plusGarrison = true; debug = false;
aggressionOccupants = 0; aggressionInvaders = 0;
resourcesIsChanging = false; limitHR = 0; server setVariable ["hr",100];
garrisonIsChanging = false; markersChanging = [];
{garrison setVariable [_x + "_preference",[]]} forEach ["Other","Airport","Outpost","MilitaryBase"];
private _petrosGroup = createGroup [teamPlayer,true];
petros = _petrosGroup createUnit ["I_G_Soldier_F",[5200,4500,0],[],0,"NONE"];
petros enableSimulationGlobal false;
hcArray = [];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_comms = []; A3I_test_markerUpdates = [];
A3I_test_nativeMarkerChange = false; A3I_test_applyMarkerChange = false;

A3I_liquidationClaims = createHashMap;
A3I_sites = createHashMap;
A3A_milAdministrations = []; A3A_destroyedMilAdministrations = [];
reinforceMarkerOccupants = []; reinforceMarkerInvaders = [];
canReinforceOccupants = []; canReinforceInvaders = [];
A3A_resourcesAttackOcc = 0; A3A_resourcesDefenceOcc = 0;
A3A_resourcesAttackInv = 0; A3A_resourcesDefenceInv = 0;
private _worker = [] spawn {sleep 600};
private _site = createHashMapFromArray [["id",1],["kind","Resource"],["context","site:" + _target],
    ["cleaned",false],["fault",""],["script",_worker],["queue",[]],["units",[]],
    ["clearanceRemaining",1],["clearanceMissing",0],["spawnedAny",true],["captured",sideUnknown],["road",true]];
A3I_sites set [_target,_site];

server setVariable ["hr",100]; server setVariable ["resourcesFIA",0];
private _reset = {
    sidesX setVariable [_target,west]; spawner setVariable [_target,0]; garrison setVariable [_target,[]];
    tierWar = 0; _site set ["kind","Resource"]; _site set ["clearanceRemaining",1];
    _site set ["queue",[]]; _site set ["fault",""]; _site set ["captured",sideUnknown];
    A3A_resourcesAttackOcc = 0; A3A_resourcesDefenceOcc = 0;
    A3A_resourcesAttackInv = 1000; A3A_resourcesDefenceInv = 1000;
    server setVariable ["resourcesFIA",0]; A3I_test_support = [];
};
private _unusedLaunch = {
    params [["_hard",false]];
    call _reset; tierWar = [0,11] select _hard;
    if !([_target] call A3I_fnc_startLiquidation) exitWith {createHashMap};
    private _record = A3I_liquidationClaims get _target;
    [{_record get "taskRegistered"}] call _wait;
    _record
};
private _state = {
    params ["_record"];
    private _index = A3A_tasksData findIf {_x # 0 == _record get "name"};
    if (_index == -1) then {"MISSING"} else {A3A_tasksData # _index # 2}
};
private _retire = {
    params ["_record"];
    if (_record get "outcome" == "pending") then {terminate (_record get "script")};
    [{_record get "settled"}] call _wait;
    _record set ["taskDeleteAt",time - 1];
    [{count A3I_liquidationClaims == 0 && {isNil "A3I_liquidationWatchdogHandle"}}] call _wait;
};

private _entries = ["CON_Outpost","CON_Outpost_Compet","CON_Outpost_Zombies","CON_MilAdmin"];
private _getRecord = {
    [{count A3I_liquidationClaims == 1}] call _wait;
    private _record = A3I_liquidationClaims getOrDefault [_target,createHashMap];
    if (count _record > 0) then {[{_record get "taskRegistered"}] call _wait};
    _record
};
// Keep the real selector deterministic without replacing the selector function.
citiesX = []; factories = [_target];
["liq_dispatch_registered",(_entries findIf {
    getText (configFile >> "CfgFunctions" >> "A3A" >> "Missions" >> _x >> "file")
        != ("\x\a3i\addons\core\overrides\fn_" + _x + ".sqf")
}) == -1] call _check;
["liq_dispatch_race_controller_removed",isNil "A3I_fnc_startCompetitiveMission"
    && {isNil "A3I_fnc_competitiveSources"} && {isNil "A3I_fnc_competitiveCapture"}] call _check;
private _nativeNames = ["originalConquestMission","competitiveMission","originalZombieConquestMission","originalAdministrationMission"];
private _exerciseOrdinary = {
    A3I_test_originals = [];
    ["CON",2,true] call A3A_fnc_missionRequest;
    {[_target,"untouched"] call (missionNamespace getVariable ("A3A_fnc_" + _x))} forEach _entries;
    private _expected = [["missionRequest",["CON",2,true]]];
    {_expected pushBack [_x,[_target,"untouched"]]} forEach _nativeNames;
    A3I_test_originals isEqualTo _expected
};
A3A_faction_occ set ["infectionTemplate",""];
["liq_dispatch_ordinary_delegation",call _exerciseOrdinary] call _check;
A3A_faction_occ set ["infectionTemplate","A3I_Infected"]; A3I_dependencies set ["available",false];
["liq_dispatch_missing_dependencies_delegation",call _exerciseOrdinary] call _check;
A3I_dependencies set ["available",true]; A3I_test_originals = [];
{[_x,2,true] call A3A_fnc_missionRequest} forEach ["AS","RES","SUPP"];
["liq_dispatch_other_categories_preserved",A3I_test_originals isEqualTo
    (["AS","RES","SUPP"] apply {["missionRequest",[_x,2,true]]})] call _check;
call _reset; A3I_test_originals = []; sidesX setVariable [_target,east];
{[_target] call (missionNamespace getVariable ("A3A_fnc_" + _x))} forEach _entries;
sleep 0.4;
["liq_dispatch_russian_targets_refused",A3I_test_originals isEqualTo []
    && {count A3I_liquidationClaims == 0} && {A3A_tasksData isEqualTo []}
    && {isNil "A3I_majorGlobalOwner"}] call _check;

private _record = createHashMap;
{
    private _entry = _x; call _reset; A3I_test_originals = [];
    [_target] call (missionNamespace getVariable ("A3A_fnc_" + _entry));
    _record = call _getRecord;
    ["liq_dispatch_direct_" + _entry,count _record > 0 && {[_record] call _state == "CREATED"}
        && {_record get "target" == _target} && {A3I_test_originals isEqualTo []}
        && {isNil "A3I_majorGlobalOwner"}] call _check;
    if (count _record > 0) then {[_record] call _retire};
} forEach _entries;
{
    private _entry = _x; call _reset; A3I_test_originals = []; hcArray = [98765];
    [[_target],"A3A_fnc_" + _entry] call A3A_fnc_scheduler;
    _record = call _getRecord;
    ["liq_dispatch_scheduler_" + _entry,count _record > 0 && {[_record] call _state == "CREATED"}
        && {A3I_test_originals isEqualTo []} && {isNil "A3I_majorGlobalOwner"}] call _check;
    if (count _record > 0) then {[_record] call _retire};
} forEach _entries;
hcArray = [];
call _reset; A3I_test_comms = [];
["CON",2,false] call A3A_fnc_missionRequest;
_record = call _getRecord; sleep 0.2;
["liq_dispatch_request_creates_task",count _record > 0 && {[_record] call _state == "CREATED"}
    && {count A3I_test_comms == 1} && {isNil "A3A_missionRequestInProgress"}] call _check;
A3I_test_comms = [];
["CON",2,false] call A3A_fnc_missionRequest; sleep 0.2;
["liq_dispatch_duplicate_request_refused",count A3I_liquidationClaims == 1
    && {count A3A_tasksData == 1} && {count A3I_test_comms == 1}] call _check;
if (count _record > 0) then {[_record] call _retire};
call _reset;
["CON",2,true] remoteExecCall ["A3A_fnc_missionRequest",2];
_record = call _getRecord;
["liq_dispatch_remote_call_detaches_context",count _record > 0 && {_record get "taskRegistered"}
    && {isNil "A3A_missionRequestInProgress"}] call _check;
if (count _record > 0) then {[_record] call _retire};
call _reset; A3A_missionRequestInProgress = true;
private _waiting = ["CON",2,true] spawn A3A_fnc_missionRequest; sleep 0.3;
["liq_dispatch_foreign_request_lock_waits",count A3I_liquidationClaims == 0
    && {A3A_missionRequestInProgress} && {!scriptDone _waiting}] call _check;
terminate _waiting; sleep 0.2;
["liq_dispatch_stopped_request_keeps_foreign_lock",A3A_missionRequestInProgress
    && {count A3I_liquidationClaims == 0}] call _check;
_waiting = ["CON",2,true] spawn A3A_fnc_missionRequest; sleep 0.2;
A3A_missionRequestInProgress = nil;
_record = call _getRecord;
["liq_dispatch_foreign_lock_release_resumes",count _record > 0 && {_record get "taskRegistered"}
    && {scriptDone _waiting} && {isNil "A3A_missionRequestInProgress"}] call _check;
if (count _record > 0) then {[_record] call _retire};
call _reset; A3I_test_comms = []; A3I_test_originals = []; sidesX setVariable [_target,east];
["CON",2,false] call A3A_fnc_missionRequest; sleep 0.2;
["liq_dispatch_unavailable_no_legacy_fallback",count A3I_liquidationClaims == 0
    && {A3A_tasksData isEqualTo []} && {A3I_test_originals isEqualTo []}
    && {count A3I_test_comms == 2}] call _check;
call _reset; airportsX = [_target]; tierWar = 2;
[_target] call A3A_fnc_CON_Outpost; sleep 0.3;
["liq_dispatch_direct_military_tier_respected",count A3I_liquidationClaims == 0] call _check;
tierWar = 3; ["CON",2,true] call A3A_fnc_missionRequest; _record = call _getRecord;
["liq_dispatch_military_available_tier_three",count _record > 0 && {_record get "kind" == "Airport"}] call _check;
if (count _record > 0) then {[_record] call _retire}; airportsX = [];
call _reset;
private _leader = _petrosGroup createUnit ["I_G_Soldier_F",getPosATL petros,[],0,"NONE"];
_petrosGroup selectLeader _leader;
["CON",2,true] call A3A_fnc_missionRequest; sleep 0.2;
["liq_dispatch_native_hq_leader_gate",count A3I_liquidationClaims == 0] call _check;
_petrosGroup selectLeader petros; deleteVehicle _leader;
private _modern = configFile >> "A3A_RequestMissionDialog" >> "Controls" >> "MainContent" >> "Controls" >> "ConquestButton";
private _legacy = configFile >> "missionMenu" >> "Controls" >> "conButton";
["liq_dispatch_menu_hooks_preserve_native_actions",getText (_modern >> "onLoad") == "_this call A3I_fnc_labelLiquidationControl"
    && {getText (_legacy >> "onLoad") == "_this call A3I_fnc_labelLiquidationControl"}
    && {configName (inheritsFrom _modern) == "A3A_Button"} && {configName (inheritsFrom _legacy) == "SimpleButton"}
    && {getText (_modern >> "onButtonClick") != ""} && {getText (_legacy >> "action") != ""}] call _check;
terminate _worker; A3I_sites = createHashMap;
deleteVehicle petros; sleep 0.2; deleteGroup _petrosGroup;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers; sleep 0.2;
["liq_dispatch_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_liquidationClaims == 0}
    && {isNil "A3I_liquidationWatchdogHandle"} && {A3A_tasksData isEqualTo []}
    && {A3A_activeTasks isEqualTo []} && {isNil "A3A_missionRequestInProgress"}] call _check;
