// Native save/load only. The receipt is test evidence, never a garrison restore.
params ["_phase"];
private _checks=0;private _failures=[];
private _check={params ["_name","_ok",["_details",[]]];
    _checks=_checks+1;if (!_ok) then {_failures pushBack _name};
    diag_log format ["[INFECTION_CASUALTY_SAVE] %1",["check",_phase+"_"+_name,_ok,_details]];
};
private _wait={params ["_condition",["_seconds",180]];private _until=diag_tickTime+_seconds;
    waitUntil {sleep 1;call _condition || {diag_tickTime>=_until}};call _condition
};
private _finish={diag_log format ["[INFECTION_CASUALTY_SAVE] %1",["complete",_checks,_failures apply {_phase+"_"+_x}]]};
diag_log "[INFECTION_CASUALTY_SAVE] start";
private _receipt=if (_phase=="write") then {missionNamespace getVariable ["A3I_casualtyProbeResult",createHashMap]}
    else {missionProfileNamespace getVariable ["A3I_casualtySaveReceipt",createHashMap]};
private _valid=_receipt getOrDefault ["passed",false] && {count (_receipt getOrDefault ["roster",[]])==(_receipt getOrDefault ["originalCount",-1])-4};
["receipt_valid",_valid] call _check;
if (!_valid) exitWith {call _finish};
private _marker=_receipt get "marker";private _roster=_receipt get "roster";
if (_phase=="write") then {
    private _funds=server getVariable "resourcesFIA";
    private _handle=[] spawn A3A_fnc_saveLoop;
    private _saved=[{scriptDone _handle && {!(missionNamespace getVariable ["savingServer",true])}}] call _wait;
    ["native_save_completed",_saved] call _check;
    private _data=missionProfileNamespace getVariable [format ["A3A_saveData_%1",A3A_saveTarget # 1],createHashMap];
    ["campaign_identity",_data getOrDefault ["campaignID",""]==A3A_saveTarget # 1] call _check;
    private _rows=(_data getOrDefault ["garrison",[]]) select {(_x # 0)==_marker};
    ["saved_reduced_roster",count _rows==1 && {(_rows # 0) # 1 isEqualTo _roster},[_marker,count _roster]] call _check;
    // The earlier temporary price-test crate has been deleted. This later save
    // must therefore retain actual live funds without its previous reimbursement.
    ["saved_funds_exact",_data getOrDefault ["resourcesFIA",-1]==_funds && {server getVariable "resourcesFIA"==_funds},[_funds]] call _check;
    _receipt set ["gameID",A3A_saveTarget # 1];
    _receipt set ["passed",_failures isEqualTo []];
    missionProfileNamespace setVariable ["A3I_casualtySaveReceipt",_receipt];
    private _mainReceipt=missionProfileNamespace getVariable ["A3I_campaignProbeReceipt",createHashMap];
    _mainReceipt set ["expectedFunds",_funds];
    missionProfileNamespace setVariable ["A3I_campaignProbeReceipt",_mainReceipt];
    saveMissionProfileNamespace;
    ["receipt_written",(missionProfileNamespace getVariable ["A3I_casualtySaveReceipt",createHashMap]) isEqualTo _receipt] call _check;
} else {
    ["campaign_identity",A3A_saveTarget # 1==_receipt get "gameID"] call _check;
    ["native_roster_restored",garrison getVariable [_marker,[]] isEqualTo _roster] call _check;
    ["ownership_restored",sidesX getVariable [_marker,sideUnknown]==west] call _check;
    forcedSpawn pushBackUnique _marker;
    private _started=[{_marker in (missionNamespace getVariable ["A3I_sites",createHashMap])}] call _wait;
    ["native_dispatch",_started] call _check;
    if (_started) then {
        private _record=A3I_sites get _marker;
        private _ready=[{count ((_record get "units") select {alive _x})==count _roster}] call _wait;
        private _units=+(_record get "units");
        ["only_reduced_roster_spawned",_ready && {count _units==count _roster}
            && {(_record get "queue") isEqualTo []} && {_record get "fault"==""},[count _units,count _roster]] call _check;
        ["valid_infected",(_units findIf {!alive _x || {side group _x!=west} || {!(_x getVariable ["A3I_initialized",false])}})==-1] call _check;
        forcedSpawn=forcedSpawn-[_marker];
        private _retired=[{!(_marker in A3I_sites) && {spawner getVariable [_marker,0]==2} && {(_units findIf {!isNull _x})==-1}}] call _wait;
        ["native_cleanup",_retired] call _check;
        private _context="site:"+_marker;
        ["budget_released",((keys A3I_budgetRecords) findIf {(A3I_budgetRecords get _x) # 0==_context})==-1] call _check;
        ["roster_unchanged",garrison getVariable [_marker,[]] isEqualTo _roster] call _check;
    } else {forcedSpawn=forcedSpawn-[_marker]};
};
call _finish;
