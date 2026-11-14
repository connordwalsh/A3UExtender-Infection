// [ground position] -> [[source, road distance, safe outdoor destination], ...].
// Unlike capture responses, supports may defend owned sites or arbitrary ground.
params [["_position",[]],["_candidates",[],[[]]],
    ["_sourceCheck",{_this call A3I_fnc_counterattackSourceEligible},[{}]]];
if (!isServer || {!canSuspend} || {!([west] call A3I_fnc_isActive)}
    || {isNil "NavGrid"} || {isNil "A3A_navCellHM"}) exitWith {[]};
if !(_position isEqualType [] && {count _position in [2,3]}
    && {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}) exitWith {[]};
if ((_candidates findIf {!(_x isEqualType "")}) != -1) exitWith {[]};
if (_candidates isEqualTo []) then {_candidates = outposts + airportsX + milbases};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _ground = +_position; _ground set [2,0];
// Accurate calls can point at the enemy itself or an occupied doorway. Search
// bounded nearby outdoor ground; an occupied first result is not a route failure.
private _destination = [];
for "_attempt" from 1 to 16 do {
    private _candidate = if (_attempt == 1) then {
        _ground findEmptyPosition [4,50,"Zombie_B_Walker_Civ"]
    } else {
        private _point = _ground getPos [4 + random 46,random 360];
        _point set [2,0];
        _point findEmptyPosition [0,0,"Zombie_B_Walker_Civ"]
    };
    if (_candidate isEqualTo [] || {_candidate distance2D _ground > 50}) then {continue};
    if (([_candidate,"Zombie_B_Walker_Civ",[],getMarkerPos _hq,150,false]
        call A3I_fnc_positionSafety) # 0) exitWith {_destination = _candidate};
};
if (_destination isEqualTo []) exitWith {[]};
private _endIndex = [_destination] call A3A_fnc_getNearestNavPoint;
if (_endIndex < 0) exitWith {[]};
private _maximum = distanceForLandAttack min 2000;
private _sources = [];
{
    if !([_x] call _sourceCheck) then {continue};
    private _origin = getMarkerPos _x;
    if (_origin distance2D _destination > _maximum) then {continue};
    private _index = [_origin] call A3A_fnc_getNearestNavPoint;
    if (_index < 0) then {continue};
    private _distance = if (_index == _endIndex) then {_origin distance2D _destination} else {
        [_index,_endIndex,_maximum + 500] call A3A_fnc_findNavDistance
    };
    if (_distance < 0 || {_distance > _maximum + 500}) then {continue};
    _sources pushBack [_x,_distance,_destination];
} forEach _candidates;
_sources
