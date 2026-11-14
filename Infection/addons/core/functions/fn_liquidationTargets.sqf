// Keep native HQ-distance selection while replacing enemy/race selection with
// infected-only town and site clearance. No attack origin is needed.
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {[]};
if (isNil "sidesX" || {isNil "petros"} || {isNull petros} || {!alive petros}
    || {isNil "tierWar"} || {isNil "distanceMission"}) exitWith {[]};
private _candidates = [];
private _military = (missionNamespace getVariable ["airportsX",[]])
    + (missionNamespace getVariable ["milbases",[]]);
{_candidates append (missionNamespace getVariable [_x,[]])}
    forEach ["citiesX","milAdministrationsX","outposts","seaports","factories","resourcesX","controlsX"];
if (tierWar >= 3) then {
    _candidates append _military;
};
_candidates = (_candidates arrayIntersect _candidates) select {
    _x in allMapMarkers && {sidesX getVariable [_x,sideUnknown] == west}
        && {tierWar >= 3 || {!(_x in _military)}}
        && {[_x] call A3I_fnc_liquidationTargetKind != ""}
};
[_candidates,petros,true] call A3A_fnc_findIfNearAndHostile
