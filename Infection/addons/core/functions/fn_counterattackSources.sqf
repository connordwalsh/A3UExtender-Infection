// Scheduled planning only. [target] -> [[source, road distance, destination], ...].
// Use actual ground points, not vehicle/carrier spawn places or marker redirects.
params [["_target","",[""]]];
if (!isServer || {!canSuspend} || {!(([_target] call A3I_fnc_counterattackEligible) # 0)}
    || {isNil "NavGrid"} || {isNil "A3A_navCellHM"}) exitWith {[]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[]};
private _destination = getMarkerPos _target findEmptyPosition [0,50,"Zombie_B_Walker_Civ"];
if (_destination isEqualTo []) exitWith {[]};
// Approaching a captured site near HQ is allowed; actual births still exclude HQ.
if !(([_destination,"Zombie_B_Walker_Civ",[],getMarkerPos _hq,150,false] call A3I_fnc_positionSafety) # 0)
    exitWith {[]};
private _endIndex = [_destination] call A3A_fnc_getNearestNavPoint;
if (_endIndex < 0) exitWith {[]};
private _maximum = distanceForLandAttack min 2000;
private _sources = [];
{
    if !([_x] call A3I_fnc_counterattackSourceEligible) then {continue};
    private _position = getMarkerPos _x;
    if (_position distance2D _destination > _maximum) then {continue};
    private _index = [_position] call A3A_fnc_getNearestNavPoint;
    if (_index < 0) then {continue};
    private _distance = if (_index == _endIndex) then {_position distance2D _destination} else {
        [_index,_endIndex,_maximum + 500] call A3A_fnc_findNavDistance
    };
    if (_distance < 0 || {_distance > _maximum + 500}) then {continue};
    _sources pushBack [_x,_distance,_destination];
} forEach (outposts + airportsX + milbases);
_sources
