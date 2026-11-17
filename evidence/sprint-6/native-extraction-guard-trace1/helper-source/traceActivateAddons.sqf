// Keep records bounded; a complete CfgPatches list exceeds the RPT line limit.
private _active=activatedAddons;
private _rawMissing=_this - _active;
private _missing=(_this apply {toLower _x}) - (_active apply {toLower _x});
diag_log format ["[INFECTION_TRACE] %1",["activateAddons",time,count _this,_this select [0,3],count _active,count _rawMissing,count _missing,_missing select [0,3],_active select [0,3]]];
private _result = _this call A3ITrace_fnc_originalActivateAddons;
diag_log format ["[INFECTION_TRACE] %1",["activateAddonsResult",time,count _result]];
_result
