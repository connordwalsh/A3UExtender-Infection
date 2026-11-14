// Preserve native state and Invader support definitions, then narrow Infection.
private _result = _this call A3I_fnc_originalInitSupports;
if ([west] call A3I_fnc_isActive) then {
    private _land = A3A_supportTypesOcc getOrDefault ["QRFLAND",[]];
    A3A_supportTypesOcc = createHashMap;
    if (_land isNotEqualTo []) then {A3A_supportTypesOcc set ["QRFLAND",+_land]};
};
if (!isNil "_result") then {_result}
