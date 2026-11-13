/* Bounded outdoor town route for a new local infected group.
   Patrol targets may be visible; spawning still uses the full observer checks.
   Never fall back to an unchecked center when all terrain candidates fail. */
params ["_group","_marker"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {isNull _group} || {!local _group} || {!(_marker in allMapMarkers)}
    || {!([leader _group] call A3I_fnc_isManagedUnit)}) exitWith {[]};
private _existing = _group getVariable ["A3I_patrolPoints",[]];
if (_existing isNotEqualTo []) exitWith {+_existing};
// Each unsuccessful search owns its retry deadline, including initial setup.
if (diag_tickTime < _group getVariable ["A3I_routeRetry",0]) exitWith {[]};
_group setVariable ["A3I_routeRetry",diag_tickTime + 30];
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _center = getMarkerPos _marker;
private _radius = (([_marker] call A3A_fnc_sizeMarker) max 25) min 150;
private _roads = _center nearRoads _radius;
private _class = typeOf leader _group;
private _points = [];
for "_attempt" from 1 to 24 do {
    if (count _points >= 4) exitWith {};
    private _candidate = if (_roads isNotEqualTo [] && {_attempt <= 16}) then {
        getPosATL (selectRandom _roads)
    } else {[_center,random _radius,random 360] call BIS_fnc_relPos};
    private _point = _candidate findEmptyPosition [0,10,_class];
    if (_point isEqualTo [] || {!(_point inArea _marker)} || {_point distance2D _center > _radius}
        || {(_points findIf {_point distance2D _x < 15}) != -1}) then {continue};
    private _safe = [_point,_class,[],getMarkerPos _hq] call A3I_fnc_positionSafety;
    if (_safe # 0) then {_points pushBack _point};
};
if (_points isEqualTo []) exitWith {[]};
private _first = [];
{
    private _wp = _group addWaypoint [_x,0];
    _wp setWaypointType "MOVE";
    _wp setWaypointCompletionRadius 10;
    if (_first isEqualTo []) then {_first = _wp};
} forEach _points;
if (count _points > 1) then {
    // CYCLE chooses the nearest other waypoint. Position it on the first route
    // point so it cannot select the automatic waypoint at the spawn position.
    private _cycle = _group addWaypoint [_points # 0,0];
    _cycle setWaypointType "CYCLE";
};
_group setCurrentWaypoint _first;
_group setVariable ["A3I_patrolPoints",+_points];
_points
