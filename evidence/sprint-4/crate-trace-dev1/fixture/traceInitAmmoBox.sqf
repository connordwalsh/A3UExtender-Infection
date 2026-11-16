// Observe the original arguments and containers; preserve native calls and return.
private _crate = if (_this isEqualType []) then {_this param [0,objNull]} else {_this};
private _observe = isServer && {_crate isEqualType objNull} && {!isNull _crate};
if (_observe) then {
    diag_log format ["[INFECTION_CRATE_TRACE] %1",["before",time,typeOf _crate,netId _crate,
        (str _this) select [0,250],
        everyContainer _crate apply {[_x select 0,netId (_x select 1)]}]];
};
private _result = _this call A3ITrace_fnc_originalInitAmmoBox;
if (_observe) then {
    diag_log format ["[INFECTION_CRATE_TRACE] %1",["after",time,typeOf _crate,netId _crate,
        everyContainer _crate apply {[_x select 0,netId (_x select 1)]}]];
};
if (isNil "_result") exitWith {};
_result
