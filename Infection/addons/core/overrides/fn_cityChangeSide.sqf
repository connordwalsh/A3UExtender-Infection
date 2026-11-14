// Support-driven ownership changes bypass markerChange. Preserve the installed
// transaction, then fill a newly infected active town without touching its assets.
private _marker = _this param [0,"",[""]];
if ([west] call A3I_fnc_isActive && {_this param [1,false]}
    && {count ([_marker] call A3I_fnc_liquidationClaim) > 0})
    exitWith {_this call A3I_fnc_liquidationCityCapture};
private _result = _this call A3I_fnc_originalCityChangeSide;
if (_marker in (missionNamespace getVariable ["citiesX",[]])) then {
    [_marker,"City",false] call A3I_fnc_startSite;
};
if (!isNil "_result") then {_result}
