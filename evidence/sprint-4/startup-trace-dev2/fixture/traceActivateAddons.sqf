// Keep records bounded; a complete CfgPatches list exceeds the RPT line limit.
diag_log format ["[INFECTION_TRACE] %1",["activateAddons",time,count _this,_this select [0,3],count activatedAddons]];
private _result = _this call A3ITrace_fnc_originalActivateAddons;
diag_log format ["[INFECTION_TRACE] %1",["activateAddonsResult",time,count _result]];
_result
