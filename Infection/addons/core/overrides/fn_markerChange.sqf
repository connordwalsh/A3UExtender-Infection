private _marker = _this param [1,"",[""]];
if ([_marker] call A3I_fnc_siteCaptureBlocked) exitWith {};
private _result = _this call A3I_fnc_originalMarkerChange;
// A spawned town is not re-created by the distance loop after a side change.
// The native transaction remains authoritative; startSite rechecks its result.
if (_marker in (missionNamespace getVariable ["citiesX",[]])) then {
    [_marker,"City",false] call A3I_fnc_startSite;
};
if (!isNil "_result") then {_result}
