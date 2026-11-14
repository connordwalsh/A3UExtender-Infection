// [ground position] -> [[source, road distance, safe outdoor destination], ...].
// Unlike capture responses, supports may defend owned sites or arbitrary ground.
params [["_position",[]]];
if (!isServer || {!canSuspend} || {!([west] call A3I_fnc_isActive)}
    || {isNil "NavGrid"} || {isNil "A3A_navCellHM"}) exitWith {[]};
if !(_position isEqualType [] && {count _position in [2,3]}
    && {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}) exitWith {[]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _ground = +_position; _ground set [2,0];
private _destination = _ground findEmptyPosition [0,50,"Zombie_B_Walker_Civ"];
if (_destination isEqualTo [] || {!(([_destination,"Zombie_B_Walker_Civ",[],getMarkerPos _hq,150,false]
    call A3I_fnc_positionSafety) # 0)}) exitWith {[]};
private _endIndex = [_destination] call A3A_fnc_getNearestNavPoint;
if (_endIndex < 0) exitWith {[]};
private _maximum = distanceForLandAttack min 2000;
private _sources = [];
{
    if !([_x] call A3I_fnc_counterattackSourceEligible) then {continue};
    private _origin = getMarkerPos _x;
    if (_origin distance2D _destination > _maximum) then {continue};
    private _index = [_origin] call A3A_fnc_getNearestNavPoint;
    if (_index < 0) then {continue};
    private _distance = if (_index == _endIndex) then {_origin distance2D _destination} else {
        [_index,_endIndex,_maximum + 500] call A3A_fnc_findNavDistance
    };
    if (_distance < 0 || {_distance > _maximum + 500}) then {continue};
    _sources pushBack [_x,_distance,_destination];
} forEach (outposts + airportsX + milbases);
_sources
