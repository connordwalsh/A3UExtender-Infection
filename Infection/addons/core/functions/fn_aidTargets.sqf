// Native SUPP distance/support weighting, restricted to infected-held towns.
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "A3A_townData"} || {isNil "sidesX"} || {isNil "distanceMission"}
    || {!finite distanceMission} || {distanceMission <= 0}
    || {isNil "petros"} || {isNull petros} || {!alive petros}) exitWith {[]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _valid = call A3I_fnc_interceptionLocations;
private _weighted = [];
{
    if (!(_x in _valid) || {!([_x] call A3I_fnc_aidTargetEligible)}) then {continue};
    private _support = (A3A_townData get _x) # 3;
    private _distance = getMarkerPos _x distance2D getMarkerPos _hq;
    if (_distance < distanceMission) then {
        _weighted append [_x,(100-_support)*((distanceMission-_distance)^2)];
    };
} forEach ((missionNamespace getVariable ["citiesX",[]]) - (missionNamespace getVariable ["destroyedSites",[]]));
_weighted
