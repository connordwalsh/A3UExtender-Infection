// Real paid infected births and native recruitment. Arrival and clock boundaries
// are injected; this is not a Redux travel, full mission or pacing playtest.
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
citiesX = [_source,_town]; sidesX setVariable [_source,west]; spawner setVariable [_source,2];
tierWar = 1; plusGarrison = true; A3A_balanceVehicleCost = 100; A3A_balancePlayerScale = 1;
A3A_supportStrikes = []; A3A_supportSpends = [];
A3A_tasksData = []; A3A_activeTasks = []; A3A_taskCount = 0;
A3I_test_zones = []; A3I_liberations = createHashMap;
A3A_resourcesDefenceOcc = 100; A3A_resourcesAttackOcc = 0;
private _rescuerGroup = createGroup [teamPlayer,true];
private _rescuer = _rescuerGroup createUnit ["I_G_Soldier_F",getMarkerPos _town,[],0,"NONE"];
_rescuer enableSimulationGlobal false;
private _pressure = "";
private _newParent = {
    A3I_majorSourceCooldowns = createHashMap; A3A_recentDamageOcc = [];
    sidesX setVariable [_source,west]; sidesX setVariable [_town,west];
    A3A_resourcesAttackOcc = 0;
    private _parent = call _newSurvivor;
    [_parent] call A3I_fnc_createLiberationSurvivor;
    private _vip = _parent get "vip";
    [_vip,_rescuer] call A3A_fnc_liberateVIP;
    _vip enableSimulationGlobal false;
    _parent set ["source",_source]; _parent set ["phase","horde"];
    _parent set ["population",100]; _parent set ["outcome","pending"];
    _parent set ["expiresAt",time + 2400]; _parent set ["settled",false];
    A3I_liberations set [_parent get "name",_parent];
    _parent
};
private _launchHorde = {
    params ["_parent"];
    [_town,_source,1,0,false,_parent get "name","liberation"] call A3I_fnc_startMajorAttack
};
private _retireHorde = {
    params ["_parent"];
    _parent set ["outcome","cancelled"];
    private _horde = _parent getOrDefault ["majorRecord",createHashMap];
    private _retired = true;
    if (count _horde > 0) then {
        _retired = [{_horde get "settled"}] call _wait;
        _horde set ["releaseAt",time - 1];
        _retired = _retired && {[{!((_horde get "name") in A3I_majorAttacks)}] call _wait};
    };
    A3I_liberations deleteAt (_parent get "name");
    _retired = ([_parent] call _waitSurvivorCleanup) && {_retired};
    _retired
};
[1,1] call _setLimits;
private _parent = call _newParent;
private _result = [_town,_source,1,0,false,"unowned","liberation"] call A3I_fnc_startMajorAttack;
["lib_horde_requires_owned_parent",!(_result # 0) && {_result # 2 == "liberation_parent"}
    && {!bigAttackInProgress}] call _check;
_parent set ["phase","rescue"];
["lib_horde_refuses_early_launch",!(([_parent] call _launchHorde) # 0)] call _check;
_parent set ["phase","horde"];
[_town,_source,1,0,false,_parent get "name","liberation"] remoteExec ["A3I_fnc_startMajorAttack",2];
sleep 0.3;
["lib_horde_remote_parent_refused",isNil {_parent get "majorRecord"} && {!bigAttackInProgress}] call _check;
private _reservation = ["reserve",["liberation:pressure",1,1]] call A3I_fnc_budget;
_pressure = _reservation # 1 # 0;
(A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
_result = [_parent] call _launchHorde;
private _horde = _parent getOrDefault ["majorRecord",createHashMap];
["lib_horde_registered_atomically",_result # 0 && {_horde get "purpose" == "liberation"}
    && {_horde get "mission" == _parent get "name"} && {_horde get "targetOwner" == west}
    && {_horde get "planned" in [30,40]} && {_horde get "fixedCost" == 0},_result] call _check;
sleep 1.3;
["lib_horde_capacity_wait_not_victory",_horde get "paidActors" == 0 && {A3A_resourcesAttackOcc == 0}
    && {!(_horde get "arrived")} && {isNil {_horde get "arrivedAt"}}
    && {[_parent] call A3I_fnc_liberationOutcome == "pending"}] call _check;
["lib_horde_no_capture_or_second_task",A3A_tasksData isEqualTo [] && {A3I_test_zones isEqualTo []}
    && {sidesX getVariable _town == west}] call _check;
["lib_horde_duplicate_launch_refused",!(([_parent] call _launchHorde) # 0)] call _check;
["close",[_pressure]] call A3I_fnc_budget; _pressure = "";
private _born = [{count (_horde get "units") == 1},10] call _wait;
private _infected = (_horde get "units") param [0,objNull];
_infected enableSimulationGlobal false;
["lib_horde_paid_birth_uses_shared_cap",_born && {_horde get "paidActors" == 1}
    && {A3A_resourcesAttackOcc == -10} && {_horde get "creditRemaining" == (_horde get "planned") - 1}
    && {count (_horde get "queue") == (_horde get "planned") - 1}
    && {side group _infected == west} && {{[_x] call A3I_fnc_isManagedUnit} count units west == 1},
    [_born,_horde get "paidActors",A3A_resourcesAttackOcc,_horde get "creditRemaining",
        _horde get "planned",count (_horde get "queue"),str side group _infected,
        (units west) apply {typeOf _x}]] call _check;
["lib_horde_marching_does_not_start_clock",!(_horde get "arrived")
    && {isNil {_horde get "arrivedAt"}} && {[_parent] call A3I_fnc_liberationOutcome == "pending"}] call _check;
deleteVehicle _infected;
sleep 1.2;
["lib_horde_waiting_attackers_not_defeated",[_parent] call A3I_fnc_liberationOutcome == "pending"
    && {_horde get "outcome" == "pending"}] call _check;
_born = [{count (_horde get "units") == 2},20] call _wait;
_infected = (_horde get "units") param [1,objNull];
_infected enableSimulationGlobal false;
["lib_horde_later_birth_paid_once",_born && {_horde get "paidActors" == 2}
    && {A3A_resourcesAttackOcc == -10} && {{[_x] call A3I_fnc_isManagedUnit} count units west == 1},
    [_born,_horde get "paidActors",A3A_resourcesAttackOcc,(units west) apply {typeOf _x}]] call _check;
_infected setPosATL (getMarkerPos _town vectorAdd [190,0,0]);
private _arrived = [{_horde get "arrived"}] call _wait;
private _arrival = _horde getOrDefault ["arrivedAt",-1];
["lib_horde_actual_arrival_starts_clock",_arrived && {_arrival >= 0}
    && {time - _arrival < 5} && {[_parent] call A3I_fnc_liberationOutcome == "pending"}] call _check;
_infected setPosATL getMarkerPos _source; sleep 1.3;
["lib_horde_arrival_clock_does_not_reset",_horde get "arrivedAt" == _arrival] call _check;
// Evaluate immediately before/after expiry atomically, before the worker sees
// time change. Keep the entire unspawned queue to prove this is the timer route.
private _clockResults = [];
isNil {
    _horde set ["arrivedAt",time - 599];
    _clockResults pushBack ([_parent] call A3I_fnc_liberationOutcome);
    _horde set ["arrivedAt",time - 601];
    _clockResults pushBack ([_parent] call A3I_fnc_liberationOutcome);
    private _vip = _parent get "vip";
    _vip setVariable ["incapacitated",true];
    _clockResults pushBack ([_parent] call A3I_fnc_liberationOutcome);
    _vip setVariable ["incapacitated",false];
    private _savedPosition = getPosATL _vip;
    _vip setPosATL (getMarkerPos _town vectorAdd [250,0,0]);
    _clockResults pushBack ([_parent] call A3I_fnc_liberationOutcome);
    _vip setPosATL _savedPosition;
    _parent set ["expiresAt",time];
    _clockResults pushBack ([_parent] call A3I_fnc_liberationOutcome);
    _parent set ["expiresAt",time + 2400]; _horde set ["arrivedAt",_arrival];
};
["lib_horde_full_600_second_clock",_clockResults select [0,2] isEqualTo ["pending","won"],_clockResults] call _check;
["lib_horde_survivor_failure_precedes_timer",_clockResults select [2,2] isEqualTo ["survivor_lost","survivor_lost"]] call _check;
["lib_horde_overall_deadline_preserved",_clockResults # 4 == "expired"] call _check;
sidesX setVariable [_source,Invaders];
["lib_horde_source_loss_cancels",[_parent] call A3I_fnc_liberationOutcome == "cancelled"] call _check;
["lib_horde_source_loss_cleanup",[_parent] call _retireHorde
    && {!bigAttackInProgress} && {forcedSpawn isEqualTo []} && {A3A_resourcesAttackOcc == 0},
    [bigAttackInProgress,forcedSpawn,A3A_resourcesAttackOcc]] call _check;

// Capacity starvation cannot buy a victory or spend the faction's resources.
_parent = call _newParent;
_reservation = ["reserve",["liberation:pressure",1,1]] call A3I_fnc_budget;
_pressure = _reservation # 1 # 0; (A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
[_parent] call _launchHorde; _horde = _parent get "majorRecord";
_horde set ["emptyDeadline",time - 1];
[{_horde get "settled"}] call _wait;
["lib_horde_no_force_cancels_without_charge",_horde get "outcome" == "no_force"
    && {[_parent] call A3I_fnc_liberationOutcome == "cancelled"} && {A3A_resourcesAttackOcc == 0}] call _check;
[_parent] call _retireHorde;
["close",[_pressure]] call A3I_fnc_budget; _pressure = "";

_parent = call _newParent;
_reservation = ["reserve",["liberation:pressure",1,1]] call A3I_fnc_budget;
_pressure = _reservation # 1 # 0; (A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
[_parent] call _launchHorde; _horde = _parent get "majorRecord";
terminate (_horde get "script");
[{_horde get "settled"}] call _wait;
["lib_horde_stopped_worker_cancels",_horde get "outcome" == "interrupted"
    && {[_parent] call A3I_fnc_liberationOutcome == "cancelled"} && {A3A_resourcesAttackOcc == 0}] call _check;
[_parent] call _retireHorde;
["close",[_pressure]] call A3I_fnc_budget; _pressure = "";

_parent = call _newParent;
_reservation = ["reserve",["liberation:pressure",1,1]] call A3I_fnc_budget;
_pressure = _reservation # 1 # 0; (A3I_budgetRecords get _pressure) set [3,diag_tickTime + 600];
[_parent] call _launchHorde; _horde = _parent get "majorRecord";
A3I_liberations deleteAt (_parent get "name");
[{_horde get "settled"}] call _wait;
["lib_horde_orphan_worker_cancels",_horde get "outcome" == "cancelled" && {A3A_resourcesAttackOcc == 0}] call _check;
[_parent] call _retireHorde;
["close",[_pressure]] call A3I_fnc_budget;
deleteVehicle _rescuer; [[_rescuerGroup]] call A3I_fnc_cleanupGroups;
[{isNull _rescuerGroup && {isNil "A3I_groupCleanupHandle"}}] call _wait;
[_savedCap,_savedContext] call _setLimits;
["lib_horde_all_state_retired",count A3I_liberations == 0 && {count A3I_majorAttacks == 0}
    && {isNil "A3I_majorGlobalOwner"} && {isNil "A3I_majorWatchdogHandle"}
    && {isNil "A3I_groupCleanupHandle"} && {!bigAttackInProgress} && {forcedSpawn isEqualTo []}
    && {(["stats"] call A3I_fnc_budget) # 1 # 1 == 0} && {A3A_tasksData isEqualTo []}] call _check;
