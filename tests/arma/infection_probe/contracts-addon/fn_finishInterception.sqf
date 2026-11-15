private _traceRecord = _this # 0;
private _traceOn = missionNamespace getVariable ["A3I_test_interceptionTrace",false];
if (_traceOn) then {
    diag_log format ["[INTERCEPTION_TASK_TRACE] finishInterception entry t=%1 suspended=%2 data=%3",time,canSuspend,
        ["name","phase","outcome","settled","deadline","eliminatedAt","remaining","killed","fault"] apply {[_x,str (_traceRecord getOrDefault [_x,"UNSET"])]}];
};
private _traceResult = _this call A3I_fnc_testNativeFinishInterception;
if (_traceOn) then {
    diag_log format ["[INTERCEPTION_TASK_TRACE] finishInterception exit t=%1 result=%2 data=%3",time,(if (isNil "_traceResult") then {"UNSET"} else {str _traceResult}),
        ["name","phase","outcome","settled","deadline","eliminatedAt","remaining","killed","fault"] apply {[_x,str (_traceRecord getOrDefault [_x,"UNSET"])]}];
};
if (isNil "_traceResult") exitWith {};
_traceResult
