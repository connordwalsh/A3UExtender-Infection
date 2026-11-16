// Native scheduled CON endpoint, full roster clearance and campaign capture.
private _checks=0;private _failures=[];
private _check={params ["_name","_ok",["_details",[]]];_checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_CAMPAIGN_LIQUIDATION] %1",["check",_name,_ok,_details]]};
private _wait={params ["_condition",["_seconds",180]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};call _condition};
private _finish={diag_log format ["[INFECTION_CAMPAIGN_LIQUIDATION] %1",["complete",_checks,_failures]]};
diag_log "[INFECTION_CAMPAIGN_LIQUIDATION] start";
private _targets=call A3I_fnc_liquidationTargets;
private _limit=(floor A3I_contextLimit) min (floor A3I_activeLimit) min 24;
private _candidates=_targets select {([_x] call A3I_fnc_liquidationTargetKind) in ["Resource","Outpost"]
    && {count (garrison getVariable [_x,[]])>_limit} && {spawner getVariable [_x,2]==2}};
["eligible_queued_site",_candidates isNotEqualTo [],[_candidates,_limit]] call _check;
if (_candidates isEqualTo []) exitWith {call _finish};
private _target=_candidates # 0;private _original=count (garrison getVariable [_target,[]]);
[[_target],"A3A_fnc_CON_Outpost"] call A3A_fnc_scheduler;
private _dispatched=[{count ([_target] call A3I_fnc_liquidationClaim)>0}] call _wait;
["native_scheduler_dispatch",_dispatched,[_target,_original]] call _check;
if (!_dispatched) exitWith {call _finish};
private _record=[_target] call A3I_fnc_liquidationClaim;private _name=_record get "name";
private _registered=[{_record get "taskRegistered"},30] call _wait;
["native_task_created",_registered && {[_name] call BIS_fnc_taskState=="CREATED"}] call _check;
sleep 3;
["inactive_site_not_cleared",!(([_target] call A3I_fnc_siteClearance) # 0)
    && {_record get "outcome"=="pending"} && {sidesX getVariable _target==west}] call _check;
forcedSpawn pushBackUnique _target;
private _active=[{_target in (missionNamespace getVariable ["A3I_sites",createHashMap])}] call _wait;
["native_site_activation",_active] call _check;
if (!_active) exitWith {forcedSpawn=forcedSpawn-[_target];call _finish};
private _site=A3I_sites get _target;
private _ready=[{count ((_site get "units") select {alive _x})>=_limit}] call _wait;
["queued_roster_retained",_ready && {count (_site get "queue")>0}
    && {count ((_site get "units") select {alive _x})+count (_site get "queue")==_original},
    [count (_site get "units"),count (_site get "queue"),_original]] call _check;
private _funds=server getVariable "resourcesFIA";
private _killed=[];
isNil {
    {if (alive _x) then {
        diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] before_death %1",[_x getVariable ["unitType",""],_x getVariable ["markerX",""],_x getVariable ["originalSide",sideUnknown],diag_frameNo]];
        _killed pushBackUnique _x;_x setDamage 1
    }} forEach (_site get "units");
    ["queue_blocks_capture",!(([_target] call A3I_fnc_siteClearance) # 0)
        && {_record get "outcome"=="pending"} && {sidesX getVariable _target==west}] call _check;
};
private _lastDiagnostic=[];
private _until=diag_tickTime+240;
waitUntil {
    sleep 1;
    // Real defender deaths, without changing roster, ledger or capture endpoints.
    {if (alive _x) then {
        diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] before_death %1",[_x getVariable ["unitType",""],_x getVariable ["markerX",""],_x getVariable ["originalSide",sideUnknown],diag_frameNo]];
        _killed pushBackUnique _x;_x setDamage 1
    }} forEach (_site get "units");
    private _snapshot=[[_target] call A3I_fnc_siteClearance,
        count (garrison getVariable [_target,[]]),count (_site get "queue"),
        {alive _x} count (_site get "units"),_site get "clearanceRemaining",_site get "clearanceMissing",
        _record get "outcome",scriptDone (_record get "script"),
        scriptDone (_record getOrDefault ["captureScript",scriptNull]),_target in markersChanging];
    if (_snapshot isNotEqualTo _lastDiagnostic) then {
        diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] state %1",_snapshot];
        {diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] actor %1",[typeOf _x,alive _x,
            _x getVariable ["A3I_clearanceTracked",false],_x getVariable ["A3I_clearanceResolved",false],
            _x getVariable ["A3I_clearanceSiteId",-1],_site get "id",
            _x getVariable ["A3I_finalized",false],_x getVariable ["unitType",""]]]} forEach _killed;
        diag_log format ["[INFECTION_LIQ_DIAGNOSTIC] roster %1",garrison getVariable [_target,[]]];
        _lastDiagnostic=_snapshot;
    };
    _record get "settled" || {diag_tickTime>=_until}
};
["all_defenders_appeared",count _killed==_original,[count _killed,_original]] call _check;
["native_capture_won",_record get "settled" && {_record get "outcome"=="won"}
    && {sidesX getVariable _target==teamPlayer}] call _check;
private _state=[{[_name] call BIS_fnc_taskState=="SUCCEEDED"
    && {(A3A_tasksData findIf {_x # 0==_name && {_x # 1=="CON"} && {_x # 2=="SUCCEEDED"}})>=0}},15] call _wait;
["native_task_succeeded",_state] call _check;
private _reward=[600,800] select (_record get "difficult");
private _paid=[{server getVariable "resourcesFIA"==_funds+_reward},30] call _wait;
["native_reward_exact",_paid,[_funds,_reward,server getVariable "resourcesFIA"]] call _check;
private _unlocked=[{!(_target in markersChanging) && {scriptDone (_record getOrDefault ["captureScript",scriptNull])}},30] call _wait;
["capture_worker_unlocked",_unlocked] call _check;
["captured_site_ineligible",!(_target in (call A3I_fnc_liquidationTargets))] call _check;
forcedSpawn=forcedSpawn-[_target];
private _clean=[{!(_target in A3I_sites)},180] call _wait;
["native_site_cleanup",_clean] call _check;
private _context="site:"+_target;
["budget_released",((keys A3I_budgetRecords) findIf {(A3I_budgetRecords get _x) # 0==_context})==-1] call _check;
sleep 5;
["reward_stable",server getVariable "resourcesFIA"==_funds+_reward] call _check;
["hq_intact",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
call _finish;
