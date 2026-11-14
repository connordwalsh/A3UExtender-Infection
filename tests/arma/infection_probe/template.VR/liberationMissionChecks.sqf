// Real mission/task/resource transactions; artificial preparation, arrival and
// expiry timestamps. No connected-player, campaign entry or pacing acceptance.
private _savedCap = A3I_activeLimit; private _savedContext = A3I_contextLimit;
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
private _source = _sources # 6;
garrison = [true] call A3A_fnc_createNamespace;
citiesX = [_source,_town]; markersX = +citiesX; controlsX = [];
milAdministrationsX = []; A3A_milAdministrations = [];
A3A_townData = createHashMapFromArray [[_town,[100,0,20,80]],[_source,[100,0,70,0]]];
A3A_faction_reb set ["name","Fixture Rebels"]; A3A_faction_civ set ["currencySymbol","$"];
overallHRGain = 100; limitHR = 0; resourcesIsChanging = false;
tierPreference = 10; theBoss = objNull;
A3I_test_markerUpdates = []; A3I_test_support = []; A3I_test_comms = []; A3I_test_aggression = [];
private _rescuerGroup = createGroup [teamPlayer,true];
private _rescuer = _rescuerGroup createUnit ["I_G_Soldier_F",getMarkerPos _town,[],0,"NONE"];
_rescuer enableSimulationGlobal false; petros = _rescuer;
private _pressure = "";
private _resetMission = {
    A3I_majorSourceCooldowns = createHashMap; A3A_recentDamageOcc = [];
    sidesX setVariable [_source,west]; sidesX setVariable [_town,west];
    spawner setVariable [_source,2]; spawner setVariable [_town,2];
    server setVariable ["hr",100]; server setVariable ["resourcesFIA",0];
    limitHR = 0;
    garrison setVariable [_town,[]];
    A3A_resourcesAttackOcc = 0; tierWar = 1;
    A3I_test_markerUpdates = []; A3I_test_support = []; A3I_test_comms = []; A3I_test_aggression = [];
    [1,1] call _setLimits;
};
private _launchMission = {
    call _resetMission;
    private _launch = [_town,_source] call A3I_fnc_startLiberation;
    if !(_launch # 0) exitWith {createHashMap};
    private _mission = A3I_liberations get (_launch # 1);
    [{_mission get "taskRegistered"}] call _wait;
    private _vip = _mission getOrDefault ["vip",objNull];
    _vip enableSimulationGlobal false;
    _mission
};
private _taskState = {
    params ["_mission"];
    private _index = A3A_tasksData findIf {_x # 0 == _mission get "name"};
    if (_index < 0) then {"MISSING"} else {A3A_tasksData # _index # 2}
};
private _recruit = {
    params ["_mission"];
    [_mission get "vip",_rescuer] call A3A_fnc_liberateVIP;
    [{_mission get "phase" == "prepare"}] call _wait
};
private _retireMission = {
    params ["_mission"];
    private _settled = [{_mission get "settled"}] call _wait;
    _mission set ["taskDeleteAt",time - 1];
    private _horde = _mission getOrDefault ["majorRecord",createHashMap];
    if (count _horde > 0) then {
        [{_horde get "settled"}] call _wait; _horde set ["releaseAt",time - 1];
        [{!((_horde get "name") in A3I_majorAttacks)}] call _wait;
    };
    private _removed = [{!((_mission get "name") in A3I_liberations)
        && {[_mission] call _taskState == "MISSING"}
        && {isNull (_mission getOrDefault ["vip",objNull])}
        && {isNull (_mission getOrDefault ["vipGroup",grpNull])}}] call _wait;
    if (_pressure != "") then {["close",[_pressure]] call A3I_fnc_budget; _pressure = ""};
    _settled && {_removed}
};
call _resetMission;
["foreign_town_task","townBattle","CREATED"] call A3A_fnc_taskUpdate;
private _result = [_town,_source] call A3I_fnc_startLiberation;
["lib_mission_native_task_type_preserved",!(_result # 0) && {_result # 1 == "task_pending"}
    && {count A3A_tasksData == 1} && {townSkirmishes isEqualTo []}] call _check;
["foreign_town_task","townBattle",0] call A3A_fnc_taskDelete;
[{!("townBattle" in A3A_activeTasks)}] call _wait;
private _mission = call _launchMission;
["lib_mission_native_task_and_claim",count _mission > 0 && {[_mission] call _taskState == "CREATED"}
    && {_town in townSkirmishes} && {_mission get "phase" == "rescue"}
    && {alive (_mission get "vip")} && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}] call _check;
["lib_mission_duplicate_refused",!(([_town,_source] call A3I_fnc_startLiberation) # 0)
    && {count A3I_liberations == 1} && {count A3A_tasksData == 1}] call _check;
private _recruited = [_mission] call _recruit;
["lib_mission_native_recruit_starts_preparation",_recruited && {_mission get "recruited"}
    && {(_mission get "readyAt") - time > 178} && {(_mission get "readyAt") - time <= 180}
    && {isNil {_mission get "majorRecord"}}] call _check;
private _reservation = ["reserve",["liberation:mission-pressure",1,1]] call A3I_fnc_budget;
_pressure = _reservation # 1 # 0; (A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
_mission set ["readyAt",time - 1];
private _launched = [{!isNil {_mission get "majorRecord"}}] call _wait;
private _horde = _mission getOrDefault ["majorRecord",createHashMap];
["lib_mission_preparation_launches_owned_horde",_launched && {_horde get "mission" == _mission get "name"}
    && {_horde get "paidActors" == 0} && {count A3A_tasksData == 1}
    && {sidesX getVariable _town == west}] call _check;
["close",[_pressure]] call A3I_fnc_budget; _pressure = "";
[{count (_horde get "units") > 0},10] call _wait;
private _infected = (_horde get "units") param [0,objNull];
_infected enableSimulationGlobal false;
_infected setPosATL (getMarkerPos _town vectorAdd [190,0,0]);
[{_horde get "arrived"}] call _wait;
// The old-tier HR cap is 200; capture raises the real native tier to eight and
// its cap to 900. Paying before that update would incorrectly discard 51 HR.
limitHR = 100; server setVariable ["hr",250];
resourcesIsChanging = true; _horde set ["arrivedAt",time - 601];
[{scriptDone (_mission get "script")}] call _wait;
["lib_mission_busy_native_resource_lock_defers",!(_mission get "settled")
    && {sidesX getVariable _town == west} && {server getVariable "hr" == 250}
    && {server getVariable "resourcesFIA" == 0}] call _check;
resourcesIsChanging = false;
[{_mission get "settled" && {[_mission] call _taskState == "SUCCEEDED"}}] call _wait;
["lib_mission_rewards_wait_for_tier",sidesX getVariable _town == teamPlayer
    && {tierWar == 1} && {!(_mission getOrDefault ["rewarded",false])}
    && {server getVariable "hr" == 250} && {server getVariable "resourcesFIA" == 0}] call _check;
// The watchdog must retain the completed mission until its delayed payment can
// acquire the native lock, even if task deletion would otherwise be due.
resourcesIsChanging = true; _mission set ["taskDeleteAt",time - 1];
[{_mission getOrDefault ["cityMaintenanceDone",false]}] call _wait;
["lib_mission_rewards_wait_for_native_lock",tierWar == 8 && {_mission get "rewardTier" == 8}
    && {!(_mission getOrDefault ["rewarded",false])}
    && {(_mission get "name") in A3I_liberations}
    && {server getVariable "hr" == 250} && {server getVariable "resourcesFIA" == 0}] call _check;
_mission set ["taskDeleteAt",time + 60]; resourcesIsChanging = false;
[{_mission getOrDefault ["rewarded",false]}] call _wait;
["lib_mission_native_capture_and_rewards",_mission get "outcome" == "won"
    && {sidesX getVariable _town == teamPlayer} && {garrison getVariable _town isEqualTo []}
    && {server getVariable "hr" == 251} && {server getVariable "resourcesFIA" == 100}
    && {_mission get "rewarded"}] call _check;
sleep 0.3;
private _supportCalls = +A3I_test_support; private _aggressionCalls = +A3I_test_aggression;
[_mission] call A3I_fnc_finishLiberation; [_mission] call A3I_fnc_rewardLiberation; sleep 0.3;
["lib_mission_settlement_once",server getVariable "hr" == 251 && {server getVariable "resourcesFIA" == 100}
    && {A3I_test_support isEqualTo _supportCalls} && {A3I_test_aggression isEqualTo _aggressionCalls}] call _check;
["lib_mission_native_support_changes",[0,10,_town,false] in A3I_test_support
    && {[-10,10,_town,false] in A3I_test_support}
    && {[west,-10,90] in A3I_test_aggression} && {[west,10,60] in A3I_test_aggression}] call _check;
private _retired = [_mission] call _retireMission;
["lib_mission_success_cleanup_and_native_tier",_retired && {townSkirmishes isEqualTo []}
    && {tierWar == (1 + floor (9 * sqrt (1 / 1.4)))}
    && {isNull (_mission get "vip")} && {alive _rescuer} && {units _rescuerGroup isEqualTo [_rescuer]},
    [_retired,+townSkirmishes,tierWar,isNull (_mission get "vip"),alive _rescuer,
        (units _rescuerGroup) apply {typeOf _x}]] call _check;

_mission = call _launchMission;
(_mission get "vip") setVariable ["incapacitated",true];
[{_mission get "settled" && {[_mission] call _taskState == "FAILED"}}] call _wait;
sleep 0.2;
["lib_mission_early_loss_native_penalty",_mission get "outcome" == "survivor_lost"
    && {[10,-10,_town,false] in A3I_test_support} && {A3A_resourcesAttackOcc == 0}
    && {server getVariable "hr" == 100} && {server getVariable "resourcesFIA" == 0}
    && {sidesX getVariable _town == west}] call _check;
[_mission] call _retireMission;

_mission = call _launchMission; [_mission] call _recruit;
(_mission get "vip") setVariable ["incapacitated",true];
[{_mission get "settled" && {[_mission] call _taskState == "FAILED"}}] call _wait;
sleep 0.2;
["lib_mission_defense_loss_native_penalty",_mission get "outcome" == "survivor_lost"
    && {A3A_resourcesAttackOcc == -400} && {[0,-20,_town,false] in A3I_test_support}
    && {server getVariable "resourcesFIA" == 0}] call _check;
[_mission] call _retireMission;

_mission = call _launchMission;
_mission set ["expiresAt",time - 1];
[{_mission get "settled"}] call _wait;
["lib_mission_rescue_expiry_fails",_mission get "outcome" == "expired"
    && {server getVariable "resourcesFIA" == 0}] call _check;
[_mission] call _retireMission;

_mission = call _launchMission;
terminate (_mission get "script");
[{_mission get "settled"}] call _wait;
["lib_mission_stopped_parent_no_rewards",_mission get "outcome" == "interrupted"
    && {A3I_test_support isEqualTo []} && {A3I_test_aggression isEqualTo []}
    && {server getVariable "resourcesFIA" == 0}] call _check;
["lib_mission_stopped_parent_cleanup",[_mission] call _retireMission && {townSkirmishes isEqualTo []}] call _check;

_mission = call _launchMission;
sidesX setVariable [_source,Invaders];
[{_mission get "settled"}] call _wait;
["lib_mission_source_loss_cancelled",_mission get "outcome" == "cancelled"
    && {A3I_test_support isEqualTo []} && {server getVariable "resourcesFIA" == 0}] call _check;
[_mission] call _retireMission;

// Interruption after child registration must retire the linked job as well.
_mission = call _launchMission; [_mission] call _recruit;
_reservation = ["reserve",["liberation:mission-pressure",1,1]] call A3I_fnc_budget;
_pressure = _reservation # 1 # 0; (A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
_mission set ["readyAt",time - 1];
[{!isNil {_mission get "majorRecord"}}] call _wait;
_horde = _mission get "majorRecord";
terminate (_mission get "script");
[{_mission get "settled"}] call _wait;
["lib_mission_stopped_parent_stops_child",_mission get "outcome" == "interrupted"
    && {_horde get "outcome" == "cancelled"} && {_horde get "queue" isEqualTo []}
    && {_horde get "creditRemaining" == 0} && {A3A_resourcesAttackOcc == 0}] call _check;
["lib_mission_linked_interruption_retires",[_mission] call _retireMission
    && {!bigAttackInProgress} && {forcedSpawn isEqualTo []} && {isNil "A3I_majorGlobalOwner"}] call _check;

// A later unrelated attack may own the shared slot during preparation.
_mission = call _launchMission; [_mission] call _recruit;
bigAttackInProgress = true; A3I_majorGlobalOwner = "fixture_foreign_attack";
_mission set ["readyAt",time - 1];
[{!isNil {_mission get "lastLaunchFailure"}}] call _wait;
["lib_mission_busy_slot_waits_without_stealing",_mission get "phase" == "prepare"
    && {_mission get "outcome" == "pending"} && {isNil {_mission get "majorRecord"}}
    && {bigAttackInProgress} && {A3I_majorGlobalOwner == "fixture_foreign_attack"}] call _check;
_mission set ["outcome","cancelled"];
[_mission] call _retireMission;
["lib_mission_cancel_preserves_foreign_attack",bigAttackInProgress
    && {A3I_majorGlobalOwner == "fixture_foreign_attack"} && {A3I_test_support isEqualTo []}] call _check;
bigAttackInProgress = false; A3I_majorGlobalOwner = nil;

// A pre-existing administration skirmish marker belongs to another caller.
private _foreignAdmin = _sources # 7;
milAdministrationsX = [_foreignAdmin]; townSkirmishes = [_foreignAdmin];
_mission = call _launchMission;
["lib_mission_shared_admin_claim_recorded",_foreignAdmin in (_mission get "claims")
    && {_foreignAdmin in townSkirmishes}] call _check;
_mission set ["outcome","cancelled"];
[_mission] call _retireMission;
["lib_mission_foreign_admin_claim_preserved",townSkirmishes isEqualTo [_foreignAdmin]
    && {count A3I_liberationSkirmishClaims == 0}] call _check;
townSkirmishes = []; milAdministrationsX = [];

deleteVehicle _rescuer; [[_rescuerGroup]] call A3I_fnc_cleanupGroups;
[{isNull _rescuerGroup && {isNil "A3I_groupCleanupHandle"}}] call _wait;
deleteVehicle garrison; [_savedCap,_savedContext] call _setLimits;
["lib_mission_all_ownership_retired",count A3I_liberations == 0 && {count A3I_liberationSkirmishClaims == 0}
    && {isNil "A3I_liberationWatchdogHandle"} && {isNil "A3I_majorWatchdogHandle"}
    && {isNil "A3I_majorGlobalOwner"} && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}
    && {townSkirmishes isEqualTo []} && {A3A_tasksData isEqualTo []}
    && {isNil "A3I_groupCleanupHandle"}] call _check;
