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
private _source = "a3i_itask_source";
private _destination = "a3i_itask_destination";
private _town = "a3i_itask_budgettown";
private _sourcePosition = [4000,4500,0];
private _destinationPosition = [5000,4500,0];
private _hqPosition = [5500,5500,0];
sidesX = [true] call A3A_fnc_createNamespace;
spawner = [true] call A3A_fnc_createNamespace;
garrison = [true] call A3A_fnc_createNamespace;
server = [true] call A3A_fnc_createNamespace;
killZones = [true] call A3A_fnc_createNamespace;
respawnTeamPlayer = "a3i_itask_hq";
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
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0; theBoss = objNull;
tierWar = 0; plusGarrison = true; distanceSPWN = 1000;
[2,2] call _setLimits;
private _role = "loadouts_occ_militia_Rifleman";
private _serial = 0;
private _newJob = {
    params [["_size",4]];
    _serial = _serial + 1;
    private _name = "task_" + str _serial;
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
private _cleanupFormation = {
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
private _launch = {
    params ["_record"];
    terminate (_record get "script");
    isNil {
        _record set ["script",[_record] spawn {
            params ["_record"];
            _record set ["preparationResult",[_record] call A3I_fnc_prepareInterception];
            sleep 600;
        }];
    };
};

private _state = {
    params ["_record"];
    private _index = A3A_tasksData findIf {_x # 0 == _record get "name"};
    if (_index < 0) then {"MISSING"} else {A3A_tasksData # _index # 2}
};
private _makeTask = {
    params ["_record"];
    [[teamPlayer,civilian],_record get "name",["Fixture interception","Horde Interception",_destination],
        _destinationPosition,false,0,true,"attack",true] call BIS_fnc_taskCreate;
    [_record get "name","CONVOY","CREATED"] call A3A_fnc_taskUpdate;
    _record set ["outcome","pending"]; _record set ["settled",false];
    _record set ["deadline",time + 120]; _record set ["difficult",false];
};
private _cleanup = {
    params ["_record"];
    _record set ["fault","fixture_cleanup"];
    [_record] call A3I_fnc_finishInterception;
    sleep 0.3; // Allow native taskSetState's remote registry update to finish.
    _record set ["taskDeleteAt",time - 1];
    [_record] call A3I_fnc_cleanupInterceptionTask;
    [_record] call _cleanupFormation;
};
private _start = {
    private _record = [4] call _newJob;
    A3A_resourcesAttackOcc = 100; A3A_resourcesDefenceOcc = 100;
    A3I_test_support = []; A3I_test_aggression = []; killZones setVariable [_source,[]];
    sidesX setVariable [_destination,west];
    _destination setMarkerShape "ELLIPSE"; _destination setMarkerSize [50,50];
    [_record] call _launch;
    [{!isNil {_record get "preparationResult"}}] call _wait;
    [_record] call A3I_fnc_releaseInterceptionFormation;
    {_x disableAI "MOVE"} forEach (_record get "units");
    [_record] call _makeTask;
    _record
};
private _await = {params ["_record"]; [{_record get "settled"},5] call _wait; sleep 0.2};
private _killAll = {params ["_record"]; {_x setDamage 1} forEach (_record get "units")};

private _record = [4] call _newJob;
[_record] call _makeTask;
["itask_preparation_not_watchable",!([_record] call A3I_fnc_watchInterceptionTask)] call _check;
[_record] call _cleanup;
_record = call _start;
["itask_watch_released",[_record] call A3I_fnc_watchInterceptionTask] call _check;
["itask_duplicate_watch_refused",!([_record] call A3I_fnc_watchInterceptionTask)] call _check;
[_record] call A3I_fnc_finishInterception;
["itask_pending_not_settled",!(_record get "settled") && {[_record] call A3I_fnc_interceptionTaskOutcome == "pending"}] call _check;
private _handle = _record get "taskHandle";
[_record] remoteExecCall ["A3I_fnc_finishInterception",2];
[[_record get "name",_record get "serial"],_handle] remoteExecCall ["A3I_fnc_interceptionTaskTick",2];
sleep 0.2;
["itask_remote_mutation_denied",!(_record get "settled") && {_record get "taskHandle" == _handle}] call _check;
sidesX setVariable [_destination,east];
["itask_russian_takeover_continues",[_record] call A3I_fnc_interceptionTaskOutcome == "pending"] call _check;
_destination setMarkerShape "RECTANGLE"; _destination setMarkerSize [20,80];
private _first = (_record get "units") # 0;
_first setPosATL (_destinationPosition vectorAdd [40,0,0]);
sleep 0.1;
["itask_actual_marker_boundary",!(_record get "settled") && {!(_first inArea _destination)}] call _check;
_first setPosATL _destinationPosition;
[_record] call _await;
["itask_first_living_arrival_fails",_record get "outcome" == "arrived" && {[_record] call _state == "FAILED"}
    && {_record get "remaining" == 4} && {_record get "phase" == "arrived"}] call _check;
["itask_arrival_penalty_once",A3A_resourcesAttackOcc == 120 && {A3A_resourcesDefenceOcc == 120}] call _check;
[_record] call A3I_fnc_finishInterception; sleep 0.2;
["itask_repeat_settlement_no_effect",A3A_resourcesAttackOcc == 120 && {A3A_resourcesDefenceOcc == 120}
    && {isNil {_record get "taskHandle"}}] call _check;
["itask_survivors_preserved",{alive _x} count (_record get "units") == 4 && {!(_record get "retired")}] call _check;
["itask_native_retention_range",_record get "taskDeleteAt" >= time + 299 && {_record get "taskDeleteAt" <= time + 900}] call _check;
["itask_retention_not_early",!([_record] call A3I_fnc_cleanupInterceptionTask)
    && {[_record] call _state == "FAILED"}] call _check;
private _cleanupHandle = _record get "taskCleanupHandle";
[_record] remoteExecCall ["A3I_fnc_cleanupInterceptionTask",2];
[[_record get "name",_record get "serial"],_cleanupHandle] remoteExecCall ["A3I_fnc_interceptionTaskCleanupTick",2];
sleep 0.2;
["itask_remote_cleanup_refused",!(_record get "taskRetired") && {_record get "taskCleanupHandle" == _cleanupHandle}] call _check;
_record set ["taskDeleteAt",time - 1];
[{_record get "taskRetired"},3] call _wait;
// BIS deleteTask clears OWNERS, but keeps ID on dedicated servers with no
// matching local units. taskExists therefore is not a task-removal assertion.
private _ownersKey = format ["%1.3",(_record get "name") call BIS_fnc_taskVar];
["itask_retention_auto_cleanup",_record get "taskRetired" && {[_record] call _state == "MISSING"}
    && {isNil {missionNamespace getVariable _ownersKey}} && {isNil {_record get "taskCleanupHandle"}}
    && {{alive _x} count (_record get "units") == 4},
    [_record get "taskRetired",[_record] call _state,
        isNil {missionNamespace getVariable _ownersKey},isNil {_record get "taskCleanupHandle"},
        {alive _x} count (_record get "units")]] call _check;
["itask_task_cleanup_idempotent",[_record] call A3I_fnc_cleanupInterceptionTask && {A3A_tasksData isEqualTo []}] call _check;

[_record] call _cleanup;

{
    private _hard = _x;
    _record = call _start; _record set ["difficult",_hard];
    [_record] call A3I_fnc_watchInterceptionTask;
    [_record] call _killAll; [_record] call _await;
    private _suffix = ["normal","hard"] select _hard;
    ["itask_elimination_" + _suffix,_record get "outcome" == "won" && {[_record] call _state == "SUCCEEDED"}
        && {_record get "killed" == 4} && {_record get "remaining" == 0}] call _check;
    ["itask_rewards_" + _suffix,A3A_resourcesAttackOcc == ([40,20] select _hard)
        && {A3A_resourcesDefenceOcc == ([40,20] select _hard)}
        && {(A3I_test_support select {_x # 0 == 0}) isEqualTo [[0,[10,15] select _hard,_source]]}
        && {A3I_test_aggression isEqualTo [[west,10,120]]}
        && {killZones getVariable [_source,[]] isEqualTo [_destination,_destination]},
        [A3A_resourcesAttackOcc,A3A_resourcesDefenceOcc]] call _check;
    [_record] call A3I_fnc_finishInterception; sleep 0.1;
    ["itask_no_duplicate_rewards_" + _suffix,count A3I_test_aggression == 1
        && {killZones getVariable [_source,[]] isEqualTo [_destination,_destination]}] call _check;
    [_record] call _cleanup;
} forEach [false,true];

_record = call _start;
[_record] call A3I_fnc_watchInterceptionTask;
isNil {
    ((_record get "units") # 0) setPosATL _destinationPosition;
    [_record] call _killAll;
};
[_record] call _await;
["itask_entry_then_last_kill_fails",_record get "outcome" == "arrived" && {_record get "remaining" == 0}
    && {[_record] call _state == "FAILED"}] call _check;
[_record] call _cleanup;

_record = call _start;
[_record] call A3I_fnc_watchInterceptionTask;
deleteVehicle ((_record get "units") # 0);
[_record] call _await;
["itask_live_deletion_not_elimination",_record get "outcome" == "interrupted" && {_record get "remaining" == 4}
    && {_record get "missing" == 1} && {([_record] call _state == "MISSING" || {[_record get "name"] call BIS_fnc_taskState == "CANCELED"})}
    && {A3A_resourcesAttackOcc == 100}] call _check;
[_record] call _cleanup;

_record = call _start;
[_record] call A3I_fnc_watchInterceptionTask;
terminate (_record get "script"); [_record] call _await;
["itask_stopped_owner_cancels",_record get "outcome" == "interrupted" && {A3A_resourcesAttackOcc == 100}
    && {([_record] call _state == "MISSING" || {[_record get "name"] call BIS_fnc_taskState == "CANCELED"})}
    && {_record get "taskDeleteAt" <= time}] call _check;
[_record] call _cleanup;

_record = call _start;
[_record get "name","CONVOY","DELETED"] call A3A_fnc_taskUpdate;
["itask_absent_task_watch_refused",!([_record] call A3I_fnc_watchInterceptionTask)] call _check;
[_record] call A3I_fnc_finishInterception;
["itask_absent_task_no_reward",_record get "outcome" == "cancelled" && {A3A_resourcesAttackOcc == 100}] call _check;
[_record get "name"] call BIS_fnc_deleteTask;
[_record] call _cleanup;

_record = call _start;
[_record] call A3I_fnc_watchInterceptionTask;
_record set ["deadline",_record get "departedAt"];
[_record] call _await;
["itask_timeout_fails",_record get "outcome" == "timeout" && {[_record] call _state == "FAILED"}
    && {A3A_resourcesAttackOcc == 120}] call _check;
[_record] call _cleanup;

_record = call _start;
[_record] call _killAll;
[{_record get "remaining" == 0 && {!isNil {_record get "eliminatedAt"}}},3] call _wait;
_record set ["deadline",(_record get "eliminatedAt") + 0.01]; sleep 0.1;
[_record] call A3I_fnc_watchInterceptionTask; [_record] call _await;
["itask_timely_kills_survive_poll_delay",_record get "outcome" == "won"] call _check;
[_record] call _cleanup;

_record = call _start;
_record set ["deadline",_record get "departedAt"]; sleep 0.1;
[_record] call _killAll;
[_record] call A3I_fnc_watchInterceptionTask; [_record] call _await;
["itask_late_kills_fail",_record get "outcome" == "timeout"] call _check;
[_record] call _cleanup;

_record = call _start;
[_record] call A3I_fnc_watchInterceptionTask;
private _oldFaction = A3A_faction_occ; A3A_faction_occ = createHashMap;
[_record] call _await;
["itask_disabled_campaign_cancels",_record get "outcome" == "interrupted" && {A3A_resourcesAttackOcc == 100}] call _check;
A3A_faction_occ = _oldFaction; [_record] call _cleanup;

_record = call _start;
_record deleteAt "deadline";
["itask_missing_deadline_refused",!([_record] call A3I_fnc_watchInterceptionTask)
    && {[_record] call A3I_fnc_interceptionTaskOutcome == "interrupted"}] call _check;
[_record] call _cleanup;

_record = call _start;
[_record] call A3I_fnc_watchInterceptionTask;
_record set ["deadline","invalid"];
[_record] call _await;
["itask_invalid_deadline_cancels_without_reward",_record get "outcome" == "interrupted"
    && {A3A_resourcesAttackOcc == 100} && {A3A_resourcesDefenceOcc == 100}
    && {([_record] call _state == "MISSING" || {[_record get "name"] call BIS_fnc_taskState == "CANCELED"})}] call _check;
[_record] call _cleanup;

[_savedCap,_savedContext] call _setLimits;
{deleteVehicle _x} forEach [sidesX,spawner,garrison,server,killZones];
{deleteMarker _x} forEach _markers;
sleep 0.5;
["itask_cleanup",(entities [[],[],true,false]) - _before isEqualTo [] && {allGroups - _groupsBefore isEqualTo []}
    && {A3A_tasksData isEqualTo []} && {A3A_activeTasks isEqualTo []} && {count A3I_interceptions == 0}
    && {(call _stats) select [1,3] isEqualTo [0,0,0]},
    [count ((entities [[],[],true,false]) - _before),count (allGroups - _groupsBefore),
        count A3A_tasksData,count A3A_activeTasks,count A3I_interceptions,call _stats]] call _check;
