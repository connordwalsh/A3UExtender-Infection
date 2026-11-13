/* Scheduled, bounded land route between the source and one nearby owned site.
   Returns [[destination, outdoor point], [source, outdoor point]], or [].
   Road connectivity and endpoints are checked, not the entire terrain journey. */
params [["_base","",[""]]];
if (!isServer || {!canSuspend} || {!([west] call A3I_fnc_isActive)}
    || {!(_base in allMapMarkers)} || {isNil "NavGrid"} || {isNil "A3A_navCellHM"}) exitWith {[]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _origin = getMarkerPos _base;
private _maximum = distanceForLandAttack min 2000;
if (_maximum <= 0) exitWith {[]};
private _outdoor = {
    params ["_marker"];
    private _point = getMarkerPos _marker findEmptyPosition [0,25,"Zombie_B_Walker_Civ"];
    if (_point isEqualTo []) exitWith {[]};
    private _safe = [_point,"Zombie_B_Walker_Civ",[],getMarkerPos _hq] call A3I_fnc_positionSafety;
    if (_safe # 0) then {_point} else {[]}
};
private _home = [_base] call _outdoor;
if (_home isEqualTo []) exitWith {[]};
// Native marker navigation can redirect to a vehicle spawn marker. Foot routes
// must use the outdoor points they actually visit instead.
private _startIndex = [_home] call A3A_fnc_getNearestNavPoint;
if (_startIndex < 0) exitWith {[]};
private _candidates = [];
{
    if (_x == _base || {_x in controlsX} || {!(_x in allMapMarkers)}
        || {sidesX getVariable [_x,sideUnknown] != west}) then {continue};
    private _distance = _origin distance2D getMarkerPos _x;
    if (_distance >= 100 && {_distance <= _maximum}) then {_candidates pushBack [_distance,_x]};
} forEach markersX;
_candidates sort true;
// At most twelve road searches, with no unscheduled or unbounded retry loop.
_candidates = (_candidates select [0,12]) call BIS_fnc_arrayShuffle;
private _route = [];
{
    private _marker = _x # 1;
    private _point = [_marker] call _outdoor;
    if (_point isEqualTo [] || {_point distance2D _home > _maximum}) then {continue};
    private _endIndex = [_point] call A3A_fnc_getNearestNavPoint;
    if (_endIndex < 0) then {continue};
    private _distance = if (_startIndex == _endIndex) then {_x # 0} else {
        [_startIndex,_endIndex,_maximum + 500] call A3A_fnc_findNavDistance
    };
    if (_distance < 0 || {_distance > _maximum + 500}) then {continue};
    _route = [[_marker,_point],[_base,_home]];
    break;
} forEach _candidates;
_route
