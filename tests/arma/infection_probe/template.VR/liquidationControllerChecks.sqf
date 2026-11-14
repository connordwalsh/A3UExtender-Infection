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
private _source = "a3i_lctrl_town";
private _target = "a3i_lctrl_factory";
private _ordinary = "a3i_lctrl_ordinary";
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
private _launch = {
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
private _record = [] call _launch;
if (count _record == 0) exitWith {["liq_controller_launch_refused",false] call _check};
// Installed setTask stores each literal text as a one-item array.
private _description = ([_record get "name"] call BIS_fnc_taskDescription) apply {
    if (_x isEqualType []) then {_x # 0} else {_x}
};
["liq_controller_native_task",[_record] call _state == "CREATED" && {"CON" in A3A_activeTasks}
    && {_description # 1 == "Liquidation Assignment"}
    && {(_description # 0) find "Cleanse the site of infected" != -1}
    && {_record get "deadline" > dateToNumber date},_description] call _check;
["liq_controller_duplicate_refused",!([_target] call A3I_fnc_startLiquidation)
    && {count A3I_liquidationClaims == 1} && {count A3A_tasksData == 1}] call _check;
["liq_controller_remaining_prevents_capture",!([_record] call A3I_fnc_captureLiquidation)
    && {sidesX getVariable _target == west} && {_record get "outcome" == "pending"}] call _check;
_site set ["clearanceRemaining",0]; spawner setVariable [_target,2]; sleep 1.2;
["liq_controller_despawn_not_success",_record get "outcome" == "pending"
    && {sidesX getVariable _target == west} && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;

{
    private _hard = _x; _record = [_hard] call _launch;
    _site set ["clearanceRemaining",0];
    [{_record get "settled" && {server getVariable "resourcesFIA" == ([600,800] select _hard)}}] call _wait;
    [_record] call A3I_fnc_finishLiquidation; sleep 0.2;
    ["liq_controller_success_once_" + str _hard,_record get "outcome" == "won"
        && {sidesX getVariable _target == teamPlayer} && {[_record] call _state == "SUCCEEDED"}
        && {server getVariable "resourcesFIA" == ([600,800] select _hard)}
        && {A3A_resourcesAttackOcc == ([-120,-180] select _hard)}
        && {A3A_resourcesDefenceOcc == ([-120,-180] select _hard)}
        && {A3A_resourcesAttackInv == 1000}
        && {A3I_test_support isEqualTo [[[-20,-25] select _hard,0,_position]]}
        && {_record get "taskDeleteAt" > time}] call _check;
    [_record] call _retire;
} forEach [false,true];

// Interrupt the task loop during native delayed flag work, not the capture worker.
_record = [] call _launch;
A3A_faction_reb set ["flagTexture","\A3\Data_F\Flags\flag_FIA_CO.paa"];
private _flag = createVehicle ["Flag_NATO_F",_position,[],0,"CAN_COLLIDE"];
_site set ["clearanceRemaining",0];
private _caughtFlagDelay = [{_record get "outcome" == "won"
    && {!scriptDone (_record getOrDefault ["captureScript",scriptNull])}}] call _wait;
terminate (_record get "script");
[{_record get "settled" && {markersChanging isEqualTo []} && {server getVariable "resourcesFIA" == 600}}] call _wait;
["liq_controller_interrupted_parent_keeps_capture",_caughtFlagDelay && {_record get "outcome" == "won"}
    && {scriptDone (_record get "captureScript")} && {markersChanging isEqualTo []}
    && {server getVariable "resourcesFIA" == 600}] call _check;
deleteVehicle _flag; [_record] call _retire;

citiesX pushBack _target; factories = [_ordinary];
_record = [] call _launch; _site set ["kind","City"]; _site set ["clearanceRemaining",0];
[{_record get "settled" && {server getVariable "resourcesFIA" == 600}}] call _wait;
["liq_controller_auto_city_capture",_record get "kind" == "City" && {_record get "outcome" == "won"}
    && {sidesX getVariable _target == teamPlayer} && {[-10,10,_target,false] in A3I_test_support}
    && {[-20,0,_position] in A3I_test_support}] call _check;
sleep 5.2; [_record] call _retire;
citiesX = [_source]; factories = [_target,_ordinary];

private _building = createVehicle ["Land_i_Barracks_V1_F",_position,[],0,"CAN_COLLIDE"];
milAdministrationsX = [_target]; A3A_milAdministrations = [_building];
_record = [] call _launch; _site set ["kind","MilAdmin"]; _site set ["remainingDefenders",0];
_site set ["building",_building]; _site set ["clearanceRemaining",0]; A3I_test_realAdminCapture = true;
[{_record get "settled" && {server getVariable "resourcesFIA" == 600}}] call _wait;
["liq_controller_auto_admin_capture",_record get "kind" == "MilAdmin" && {_record get "outcome" == "won"}
    && {_building in A3A_destroyedMilAdministrations} && {sidesX getVariable _target == teamPlayer}] call _check;
[_record] call _retire; A3I_test_realAdminCapture = false;
deleteVehicle _building; milAdministrationsX = []; A3A_milAdministrations = []; A3A_destroyedMilAdministrations = [];

// A native administration write refusal must preserve the existing fault
// contract, so the controller cancels instead of retrying until timeout.
_building = createVehicle ["Land_i_Barracks_V1_F",_position,[],0,"CAN_COLLIDE"];
milAdministrationsX = [_target]; A3A_milAdministrations = [_building];
_record = [] call _launch; _site set ["kind","MilAdmin"]; _site set ["remainingDefenders",0];
_site set ["building",_building]; _site set ["clearanceRemaining",0]; A3I_test_realAdminCapture = false;
[{_record get "settled"}] call _wait;
["liq_controller_native_capture_failure_cancels",_site get "fault" == "capture_failed"
    && {_record get "outcome" == "cancelled"} && {sidesX getVariable _target == west}
    && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;
deleteVehicle _building; milAdministrationsX = []; A3A_milAdministrations = [];

_record = [] call _launch; _record set ["deadline",dateToNumber date - 0.001];
[{_record get "settled" && {A3A_resourcesAttackOcc == 60}}] call _wait;
[_record] call A3I_fnc_finishLiquidation; sleep 0.2;
["liq_controller_timeout_once",_record get "outcome" == "timeout" && {[_record] call _state == "FAILED"}
    && {A3A_resourcesAttackOcc == 60} && {A3A_resourcesDefenceOcc == 60}
    && {server getVariable "resourcesFIA" == 0} && {A3I_test_support isEqualTo [[5,0,_position]]}] call _check;
[_record] call _retire;
_record = [true] call _launch; _record set ["deadline",dateToNumber date - 0.001];
[{_record get "settled" && {A3A_resourcesAttackOcc == 120}}] call _wait;
["liq_controller_hard_timeout",_record get "outcome" == "timeout" && {[_record] call _state == "FAILED"}
    && {A3A_resourcesDefenceOcc == 120} && {A3I_test_support isEqualTo [[25,0,_position]]}] call _check;
[_record] call _retire;

_record = [] call _launch;
[east,_target] call A3A_fnc_markerChange;
[{_record get "settled" && {[_record] call _state == "MISSING"}}] call _wait;
["liq_controller_russian_cancellation_free",_record get "outcome" == "cancelled"
    && {server getVariable "resourcesFIA" == 0} && {A3A_resourcesAttackOcc == 0}
    && {A3A_resourcesDefenceOcc == 0} && {A3I_test_support isEqualTo []}] call _check;
[_record] call _retire;
_record = [] call _launch; sidesX setVariable [_target,teamPlayer];
[{_record get "settled"}] call _wait;
["liq_controller_unverified_owner_not_success",_record get "outcome" == "cancelled"
    && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;
_record = [] call _launch; A3I_dependencies set ["available",false];
[{_record get "settled"}] call _wait; A3I_dependencies set ["available",true];
["liq_controller_dependency_loss_cancels",_record get "outcome" == "cancelled"
    && {A3A_resourcesAttackOcc == 0} && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;
_record = [] call _launch; _site set ["fault","fixture_fault"];
[{_record get "settled"}] call _wait;
["liq_controller_site_fault_cancels",_record get "outcome" == "cancelled"
    && {A3A_resourcesAttackOcc == 0} && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;
_record = [] call _launch; terminate (_record get "script");
[{_record get "settled" && {[_record] call _state == "MISSING"}}] call _wait;
["liq_controller_stopped_worker_recovers",_record get "outcome" == "interrupted"
    && {server getVariable "resourcesFIA" == 0} && {!("CON" in A3A_activeTasks)}] call _check;
[_record] call _retire;
_record = [] call _launch; _record set ["taskRegistered",false]; terminate (_record get "script");
[{_record get "settled" && {[_record] call _state == "MISSING"}}] call _wait;
["liq_controller_registration_gap_recovers",_record get "outcome" == "interrupted"
    && {A3A_tasksData isEqualTo []} && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;
_record = [] call _launch;
[_record get "name","CON","DELETED"] call A3A_fnc_taskUpdate;
terminate (_record get "script"); [{_record get "settled"}] call _wait;
["liq_controller_missing_task_cancels",_record get "outcome" == "cancelled"
    && {server getVariable "resourcesFIA" == 0}] call _check;
[_record] call _retire;
call _reset; [_target] remoteExec ["A3I_fnc_startLiquidation",2]; sleep 0.3;
["liq_controller_remote_start_rejected",count A3I_liquidationClaims == 0
    && {A3A_tasksData isEqualTo []}] call _check;
A3I_test_liqTicks = 0;
private _foreign = [{A3I_test_liqTicks = A3I_test_liqTicks + 1},0.1] call CBA_fnc_addPerFrameHandler;
[[],_foreign] remoteExecCall ["A3I_fnc_liquidationWatchdog",2]; sleep 0.6;
["liq_controller_remote_watchdog_rejected",A3I_test_liqTicks >= 2] call _check;
[_foreign] call CBA_fnc_removePerFrameHandler;
{spawner setVariable [_x,2]} forEach _markers; sleep 1.5;
terminate _worker; A3I_sites = createHashMap;
deleteVehicle petros; sleep 0.2; deleteGroup _petrosGroup;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
sleep 0.2;
["liq_controller_cleanup",(entities [[],[],true,false]) - _before isEqualTo []
    && {allGroups - _groupsBefore isEqualTo []} && {count A3I_liquidationClaims == 0}
    && {isNil "A3I_liquidationWatchdogHandle"} && {A3A_tasksData isEqualTo []}
    && {A3A_activeTasks isEqualTo []}] call _check;
