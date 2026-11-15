if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "petros"} || {isNull petros} || {!alive petros}
    || {isNil "distanceMission"}) exitWith {[]};
private _candidates = (call A3I_fnc_interceptionLocations) select {
    [_x] call A3I_fnc_supplySiteKinds isNotEqualTo []
};
[_candidates,petros,true] call A3A_fnc_findIfNearAndHostile
