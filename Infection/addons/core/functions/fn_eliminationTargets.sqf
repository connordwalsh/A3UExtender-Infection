// Preserve native AS distance/inactive-site selection, using the approved kinds.
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "sidesX"} || {isNil "spawner"} || {isNil "petros"}
    || {isNull petros} || {!alive petros} || {isNil "distanceMission"}) exitWith {[]};
private _candidates = (call A3I_fnc_interceptionLocations) select {
    sidesX getVariable [_x,sideUnknown] == west && {spawner getVariable [_x,2] != 0}
};
[_candidates,petros,true] call A3A_fnc_findIfNearAndHostile
