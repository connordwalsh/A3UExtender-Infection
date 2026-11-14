// Real actor/cost/task metadata contracts. Deadlines and arrivals are injected;
// task presentation, connected-player observation and Redux walking are not run.
#include "\x\a3a\addons\core\script_component.hpp"
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
A3A_resourcesAttackOcc = 5; A3A_resourcesDefenceOcc = 100;
A3A_hasACE = false; A3A_GCThreshold = 600; GVAR(despawnQueue) = []; GVAR(despawnerRunning) = nil;
A3A_faction_civ = createHashMapFromArray [["attributeLowCiv",true]];
A3A_faction_reb = createHashMapFromArray [["diveGear",[]],["flyGear",[]]];
A3I_test_originals = []; A3I_test_support = []; A3I_test_aggression = []; A3I_test_zones = [];
A3I_test_lootCalls = []; A3I_test_logisticsCalls = []; A3I_test_vehicleCleanup = [];
A3A_supportStrikes = []; A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0;
A3A_balanceVehicleCost = 10; A3A_balancePlayerScale = 1;
bigAttackInProgress = false; HQAttackInProgress = false; theBoss = objNull;
private _creditScript = [] spawn {sleep 120};
private _credit = createHashMapFromArray [["context","major:credit"],["outcome","pending"],
    ["creditRemaining",1],["paidActors",0],["script",_creditScript]];
A3I_majorAttacks = createHashMapFromArray [["credit_test",_credit]];
A3I_majorGlobalOwner = "credit_test";
[4,4] call _setLimits;
private _spawn = ["major:credit",[_role,_role],[4000,4500,0],0,100,"","attack",4,false,{true},true,"credit_test"]
    call A3I_fnc_spawnGroup;
["major_credit_allows_debt",_spawn # 0 && {count (_spawn # 1 # 1) == 1}
    && {A3A_resourcesAttackOcc == -5} && {_credit get "paidActors" == 1}
    && {_credit get "creditRemaining" == 0},[_spawn # 2,A3A_resourcesAttackOcc]] call _check;
private _again = ["major:credit",[_role],[4000,4500,0],0,100,"","attack",4,false,{true},true,"credit_test"]
    call A3I_fnc_spawnGroup;
["major_credit_cannot_exceed_authority",!(_again # 0) && {_again # 2 == "credit"}
    && {A3A_resourcesAttackOcc == -5}] call _check;
private _ordinary = ["major:ordinary",[_role],[4000,4500,0],0,100,"","attack",4,false,{true},true]
    call A3I_fnc_spawnGroup;
["major_debt_not_available_to_ordinary_jobs",!(_ordinary # 0) && {_ordinary # 2 == "resources"}] call _check;
_credit set ["creditRemaining",1];
private _wrong = ["major:other",[_role],[4000,4500,0],0,100,"","attack",4,false,{true},true,"credit_test"]
    call A3I_fnc_spawnGroup;
["major_credit_context_bound",!(_wrong # 0) && {_wrong # 2 == "credit"}] call _check;
A3I_majorGlobalOwner = "other";
_wrong = ["major:credit",[_role],[4000,4500,0],0,100,"","attack",4,false,{true},true,"credit_test"]
    call A3I_fnc_spawnGroup;
["major_credit_owner_bound",!(_wrong # 0) && {_wrong # 2 == "credit"}] call _check;
A3I_majorGlobalOwner = "credit_test";
terminate _creditScript;
[{scriptDone _creditScript}] call _wait;
_wrong = ["major:credit",[_role],[4000,4500,0],0,100,"","attack",4,false,{true},true,"credit_test"]
    call A3I_fnc_spawnGroup;
["major_stopped_worker_credit_refused",!(_wrong # 0) && {_wrong # 2 == "credit"}] call _check;
if (_spawn # 0) then {["cancel",[_spawn # 1 # 2]] call A3I_fnc_budget};
[{A3A_resourcesAttackOcc == 5}] call _wait;
["major_credit_actual_refund_once",A3A_resourcesAttackOcc == 5] call _check;
{if (count units _x == 0) then {deleteGroup _x}} forEach (allGroups - _groupsBefore);
A3I_majorGlobalOwner = nil; A3I_majorAttacks = createHashMap; A3I_majorSerial = 0;
private _source = _sources # 6;
private _reset = {
    A3I_majorSourceCooldowns = createHashMap; A3A_recentDamageOcc = [];
    sidesX setVariable [_source,west]; spawner setVariable [_source,2];
    sidesX setVariable [_town,teamPlayer]; spawner setVariable [_town,2];
    A3A_resourcesAttackOcc = 1;
};
private _waitJob = {
    params ["_job"];
    [{_job get "settled"}] call _wait;
    _job set ["releaseAt",time - 1];
    [{!((_job get "name") in A3I_majorAttacks)}] call _wait;
    if (!isNil {_job get "taskDeleteScript"}) then {
        terminate (_job get "taskDeleteScript");
        if ((A3A_tasksData findIf {_x # 0 == _job get "taskId"}) != -1) then {
            [_job get "taskId",_job get "taskType",0] call A3A_fnc_taskDelete;
        };
    };
    [{!((_job get "taskType") in A3A_activeTasks)},3] call _wait;
};
call _reset;
private _rejected = [_town,_source,0,0] call A3I_fnc_startMajorAttack;
["major_launch_rejects_invalid_strength",!(_rejected # 0) && {_rejected # 2 == "invalid_request"}] call _check;
bigAttackInProgress = true;
_rejected = [_town,_source,1,0] call A3I_fnc_startMajorAttack;
["major_launch_preserves_foreign_attack",!(_rejected # 0) && {bigAttackInProgress}
    && {A3A_resourcesAttackOcc == 1} && {forcedSpawn isEqualTo []}] call _check;
bigAttackInProgress = false;
private _accepted = [_town,_source,3,300] call A3I_fnc_startMajorAttack;
["major_launch_combines_strength",_accepted # 0 && {_accepted # 1 >= 17} && {_accepted # 1 <= 23},_accepted] call _check;
if !(_accepted # 0) exitWith {[_savedCap,_savedContext] call _setLimits};
private _job = A3I_majorAttacks get A3I_majorGlobalOwner;
[{_job get "taskRegistered"}] call _wait;
["major_launch_native_town_charge",A3A_resourcesAttackOcc == -199 && {_job get "paidActors" == 0}
    && {count A3A_tasksData == 1} && {_town in forcedSpawn} && {bigAttackInProgress}] call _check;
["major_launch_preserves_town_data",server getVariable _source isEqualTo _sourceTownData
    && {server getVariable _town isEqualTo _targetTownData}] call _check;
_job set ["emptyDeadline",time - 1];
[_job] call _waitJob;
["major_no_force_cancels_without_reward",_job get "outcome" == "no_force"
    && {A3A_resourcesAttackOcc == 1} && {!(_job getOrDefault ["rewarded",false])}
    && {A3A_tasksData isEqualTo []} && {!bigAttackInProgress} && {forcedSpawn isEqualTo []},
    [_job get "outcome",A3A_resourcesAttackOcc,A3A_tasksData,A3A_activeTasks,bigAttackInProgress,forcedSpawn]] call _check;
call _reset; [4,2] call _setLimits;
_accepted = [_town,_source,3,0] call A3I_fnc_startMajorAttack;
if !(_accepted # 0) exitWith {["major_live_accept",false,_accepted] call _check; [_savedCap,_savedContext] call _setLimits};
_job = A3I_majorAttacks get A3I_majorGlobalOwner;
[{count (_job get "units") == 2}] call _wait;
["major_shared_limit_and_waiting_strength",count (_job get "units") == 2 && {_job get "outcome" == "pending"}
    && {count (_job get "queue") == (_job get "planned") - 2}
    && {A3A_resourcesAttackOcc == -219}] call _check;
private _first = (_job get "units") # 0; _first setDamage 1;
[{_job get "paidActors" == 3 && {{alive _x} count (_job get "units") == 2}},20] call _wait;
["major_later_attackers_paid_in_debt",_job get "paidActors" == 3 && {A3A_resourcesAttackOcc == -229}
    && {{alive _x} count (_job get "units") == 2},
    [_job get "paidActors",A3A_resourcesAttackOcc,{alive _x} count (_job get "units")]] call _check;
_job set ["endTime",time - 1]; [_job] call _waitJob;
["major_unreached_horde_no_free_victory",_job get "outcome" == "unreached"
    && {!(_job getOrDefault ["rewarded",false])} && {A3A_resourcesAttackOcc == -209}
    && {A3A_tasksData isEqualTo []}] call _check;
deleteVehicle _first;
call _reset;
_accepted = [_town,_source,1,300] call A3I_fnc_startMajorAttack;
if !(_accepted # 0) exitWith {["major_cancel_accept",false,_accepted] call _check; [_savedCap,_savedContext] call _setLimits};
_job = A3I_majorAttacks get A3I_majorGlobalOwner;
[{_job get "taskRegistered"}] call _wait;
terminate (_job get "script");
[_job] call _waitJob;
["major_stopped_controller_recovers",_job get "outcome" == "interrupted"
    && {A3A_resourcesAttackOcc == 1} && {A3A_tasksData isEqualTo []}
    && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}] call _check;
call compile preprocessFileLineNumbers "majorLifecycleExtraChecks.sqf";
call compile preprocessFileLineNumbers "majorDispatchChecks.sqf";
[_savedCap,_savedContext] call _setLimits;
