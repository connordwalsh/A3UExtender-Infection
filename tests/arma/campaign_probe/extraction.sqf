// Public mission request in the actual Redux campaign. No endpoint stubs.
private _successMode=call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\extraction-success-mode.sqf";
private _checks=0;private _failures=[];
private _check={params ["_name","_ok",["_details",[]]];
    _checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_CAMPAIGN_EXTRACTION] %1",["check",_name,_ok,_details]];
};
private _wait={params ["_condition",["_seconds",180]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};call _condition
};
private _finish={diag_log format ["[INFECTION_CAMPAIGN_EXTRACTION] %1",["complete",_checks,_failures]]};
diag_log "[INFECTION_CAMPAIGN_EXTRACTION] start";
private _targets=call A3I_fnc_extractionTargets;
["eligible_targets",_targets isNotEqualTo [],[_targets]] call _check;
if (_targets isEqualTo []) exitWith {call _finish};
private _serial=missionNamespace getVariable ["A3I_extractionTaskSerial",0];
private _request=["RES",2,true] spawn A3A_fnc_missionRequest;
private _dispatched=[{(missionNamespace getVariable ["A3I_extractionTaskSerial",0])>_serial}] call _wait;
["public_dispatch",_dispatched] call _check;
if (!_dispatched) exitWith {call _finish};
private _name="A3I_EXTRACTION_"+str (missionNamespace getVariable ["A3I_extractionTaskSerial",0]);
private _record=(missionNamespace getVariable ["A3I_extractionTasks",createHashMap]) getOrDefault [_name,createHashMap];
private _registered=[{_record getOrDefault ["taskRegistered",false] || {_record getOrDefault ["settled",false]}}] call _wait;
["task_registered",_registered && {_record getOrDefault ["taskRegistered",false]}
    && {_record getOrDefault ["fault",""]==""},[_record getOrDefault ["source",""],_record getOrDefault ["fault",""]]] call _check;
if !(_record getOrDefault ["taskRegistered",false]) exitWith {call _finish};
["source_eligible",(_record get "source") in _targets && {sidesX getVariable [_record get "source",sideUnknown]==west}] call _check;
private _survivors=+(_record get "units");private _guards=+(_record get "guards");private _groups=+(_record get "groups");
["survivor_contract",count _survivors>=2 && {count _survivors<=6}
    && {(_survivors findIf {!alive _x || {side group _x!=teamPlayer} || {_x getVariable ["WBK_AI_ISZombie",false]}})==-1},[count _survivors]] call _check;
["guard_contract",count _guards==4 && {(_guards findIf {!alive _x || {side group _x!=west}
    || {!(_x getVariable ["A3I_initialized",false])}})==-1},[count _guards]] call _check;
["native_task_created",(A3A_tasksData findIf {_x # 0==_name && {_x # 1=="RES"} && {_x # 2=="CREATED"}})>=0
    && {[_name] call BIS_fnc_taskState=="CREATED"}] call _check;
// Real deaths exercise the mission ledger/tick; do not force task state or timers.
if (_successMode) exitWith {
    [_record,_survivors,_guards,_groups,_check,_wait] call compile preprocessFileLineNumbers "\x\a3i\tests\campaign\extractionSuccess.sqf";
    call _finish;
};
{_x setDamage 1} forEach _survivors;
private _settled=[{_record get "settled"},30] call _wait;
["all_dead_failed",_settled && {_record get "outcome"=="failed"}] call _check;
["native_task_failed",(A3A_tasksData findIf {_x # 0==_name && {_x # 1=="RES"} && {_x # 2=="FAILED"}})>=0
    && {[_name] call BIS_fnc_taskState=="FAILED"}] call _check;
["no_rescue_credit",_record get "hrCredited"==0 && {(_record get "ledger") get "rescued"==0}] call _check;
private _clean=[{_record get "assetRetired" && {((_survivors+_guards) findIf {!isNull _x})==-1}
    && {(_groups findIf {!isNull _x})==-1}},150] call _wait;
["native_delayed_asset_cleanup",_clean] call _check;
private _context="extraction:"+_name;
["budget_released",((keys A3I_budgetRecords) findIf {(A3I_budgetRecords get _x) # 0==_context})==-1] call _check;
["hq_intact",alive petros && {!isNull boxX} && {!isNull flagX}] call _check;
call _finish;
