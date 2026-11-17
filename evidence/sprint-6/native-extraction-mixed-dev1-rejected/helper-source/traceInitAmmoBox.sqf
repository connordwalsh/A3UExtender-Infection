// Observe the original arguments and containers; preserve native calls and return.
private _crate = if (_this isEqualType []) then {_this param [0,objNull]} else {_this};
private _observe = isServer && {_crate isEqualType objNull} && {!isNull _crate};
if (_observe) then {
    diag_log format ["[INFECTION_CRATE_TRACE] %1",["before",time,typeOf _crate,netId _crate,
        (str _this) select [0,250],
        everyContainer _crate apply {[_x select 0,netId (_x select 1)]}]];
};
// Explicit experimental control only. Never loaded in normal campaign probes.
if (_observe && {getNumber (configFile >> "A3I_traceKeepCrateInventory") == 1}
    && {_this isEqualType []} && {typeOf _crate == "IG_supplyCrate_F"}
    && {(_this param [1,[]]) isEqualTo ""}) exitWith {
    diag_log format ["[INFECTION_CRATE_TRACE] %1",["skipped",time,typeOf _crate,netId _crate]];
};
private _result = _this call A3ITrace_fnc_originalInitAmmoBox;
if (_observe) then {
    diag_log format ["[INFECTION_CRATE_TRACE] %1",["after",time,typeOf _crate,netId _crate,
        everyContainer _crate apply {[_x select 0,netId (_x select 1)]}]];
};
if (isNil "_result") exitWith {};
_result
