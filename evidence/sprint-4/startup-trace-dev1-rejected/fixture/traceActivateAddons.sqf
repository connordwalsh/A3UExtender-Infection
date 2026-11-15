diag_log format ["[INFECTION_TRACE] %1",["activateAddons",time,_this]];
private _result = _this call A3ITrace_fnc_originalActivateAddons;
diag_log format ["[INFECTION_TRACE] %1",["activateAddonsResult",time,count _result]];
_result
