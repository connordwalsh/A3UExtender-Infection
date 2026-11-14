// [optional destination, optional source] -> [[destination, source,
// safe destination point, safe source point, road distance], ...].
// Planning only: no task, reservation, resource charge or ownership mutation.
params [["_destinationFilter","",[""]],["_sourceFilter","",[""]]];
if (!isServer || {!canSuspend} || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "sidesX"} || {isNil "spawner"} || {isNil "server"}
    || {isNil "NavGrid"} || {isNil "A3A_navCellHM"}) exitWith {[]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
private _range = missionNamespace getVariable ["distanceMission",0];
private _maximum = missionNamespace getVariable ["distanceForLandAttack",0];
if (!(_hq in allMapMarkers) || {!(_range isEqualType 0 && {finite _range} && {_range > 0})}
    || {!(_maximum isEqualType 0 && {finite _maximum} && {_maximum > 0})}) exitWith {[]};
_maximum = _maximum min 2000;
private _locations = call A3I_fnc_interceptionLocations;
private _sources = _locations select {
    (_sourceFilter == "" || {_x == _sourceFilter}) && {[_x] call A3I_fnc_majorSourceEligible}
};
private _destinations = _locations select {
    (_destinationFilter == "" || {_x == _destinationFilter})
    && {sidesX getVariable [_x,sideUnknown] in [west,teamPlayer]}
    && {getMarkerPos _x distance2D getMarkerPos _hq <= _range}
};
private _pairs = [];
{
    private _destination = _x;
    private _position = getMarkerPos _destination;
    private _edge = [_destination] call A3A_fnc_sizeMarker;
    {
        private _distance = getMarkerPos _x distance2D _position;
        // Source search stays within 25 m and actor births within 100 m of that
        // point. Bounding radius also covers rotated rectangular destinations.
        if (_x != _destination && {_distance > _edge + 150} && {_distance <= _maximum}) then {
            _pairs pushBack [_position distance2D getMarkerPos _hq,_distance,_destination,_x];
        };
    } forEach _sources;
} forEach _destinations;
_pairs sort true;
private _routes = [];
private _safePoint = {
    params ["_marker","_spawning"];
    private _center = getMarkerPos _marker;
    private _result = [];
    for "_attempt" from 0 to 15 do {
        private _point = if (_attempt == 0) then {_center} else {_center getPos [random 25,random 360]};
        _point set [2,0];
        _point = _point findEmptyPosition [0,0,"Zombie_B_Walker_Civ"];
        if (_point isEqualTo [] || {_point distance2D _center > 25}) then {continue};
        if (!_spawning && {!(_point inArea _marker)}) then {continue};
        if (([_point,"Zombie_B_Walker_Civ",[],getMarkerPos _hq,150,_spawning]
            call A3I_fnc_positionSafety) # 0) exitWith {_result = _point};
    };
    _result
};
// Bound expensive path searches; nearest-to-HQ pairs are considered first.
{
    _x params ["_hqDistance","_straight","_destination","_source"];
    private _start = [_source,true] call _safePoint;
    private _end = [_destination,false] call _safePoint;
    if (_start isEqualTo [] || {_end isEqualTo []} || {_start inArea _destination}) then {continue};
    private _startIndex = [_start] call A3A_fnc_getNearestNavPoint;
    private _endIndex = [_end] call A3A_fnc_getNearestNavPoint;
    if (_startIndex < 0 || {_endIndex < 0}) then {continue};
    private _distance = if (_startIndex == _endIndex) then {_start distance2D _end} else {
        [_startIndex,_endIndex,_maximum + 500] call A3A_fnc_findNavDistance
    };
    if (_distance < 0 || {_distance > _maximum + 500}) then {continue};
    // Searches can yield. Discard ownership/eligibility that changed meanwhile.
    if (!([_source] call A3I_fnc_majorSourceEligible)
        || {!(sidesX getVariable [_destination,sideUnknown] in [west,teamPlayer])}) then {continue};
    _routes pushBack [_destination,_source,_end,_start,_distance];
} forEach (_pairs select [0,64]);
_routes
