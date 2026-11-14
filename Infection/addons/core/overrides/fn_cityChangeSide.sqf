// Support-driven ownership changes bypass markerChange. Preserve the installed
// transaction, then fill a newly infected active town without touching its assets.
private _marker = _this param [0,"",[""]];
private _result = _this call A3I_fnc_originalCityChangeSide;
if (_marker in (missionNamespace getVariable ["citiesX",[]])) then {
    [_marker,"City",false] call A3I_fnc_startSite;
};
if (!isNil "_result") then {_result}
