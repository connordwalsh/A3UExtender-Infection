private _result = A3I_test_originals pushBack ["originalMarkerChange",+_this];
if (missionNamespace getVariable ["A3I_test_nativeMarkerChange",false]) exitWith {
    _this call A3I_fnc_testNativeMarkerChange
};
if (missionNamespace getVariable ["A3I_test_applyMarkerChange",false]) then {
    sidesX setVariable [_this # 1,_this # 0];
};
_result
