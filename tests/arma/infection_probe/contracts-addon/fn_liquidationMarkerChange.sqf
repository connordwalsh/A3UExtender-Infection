// Isolated diagnostic wrapper; the production capture body remains authoritative.
private _probeMarker = _this # 1;
private _probeSnapshot = {
    [str (sidesX getVariable [_probeMarker,sideUnknown]),+markersChanging,
        [_probeMarker] call A3I_fnc_siteClearance,
        ((missionNamespace getVariable ["A3I_liquidationClaims",createHashMap])
            getOrDefault [_probeMarker,createHashMap]) getOrDefault ["outcome","missing"],
        isRemoteExecuted,remoteExecutedOwner,canSuspend]
};
if (!isNil "A3I_test_captureTrace") then {A3I_test_captureTrace pushBack ["entry",call _probeSnapshot]};
private _probeResult = _this call A3I_fnc_testNativeLiquidationMarkerChange;
if (!isNil "A3I_test_captureTrace") then {A3I_test_captureTrace pushBack ["exit",call _probeSnapshot]};
if (!isNil "_probeResult") then {_probeResult}
