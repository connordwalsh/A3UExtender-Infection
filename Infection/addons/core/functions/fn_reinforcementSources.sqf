// Reachable, unobserved land bases. No carrier, aircraft or vehicle-place query.
// [target] -> [[source, road distance], ...]. Terrain walking still needs acceptance.
params [["_target","",[""]]];
if (!isServer || {!([west] call A3I_fnc_isActive)} || {!(_target in allMapMarkers)}
    || {isNil "NavGrid"} || {isNil "A3A_navCellHM"}) exitWith {[]};
private _sources = [];
private _observers = call A3I_fnc_spawnObservers;
private _maximum = distanceForLandAttack + 2000;
if (isNil "A3I_reinforcementRoutes") then {A3I_reinforcementRoutes = createHashMap};
{
    private _source = _x;
    if (!(_source in allMapMarkers) || {sidesX getVariable [_source,sideUnknown] != west}
        || {spawner getVariable [_source,2] != 2} || {_source in forcedSpawn}
        || {dateToNumber date < server getVariable [_source,0]}
        || {count (garrison getVariable [_source,[]]) < 16}) then {continue};
    private _position = getMarkerPos _source;
    if (_position distance2D getMarkerPos _target > _maximum
        || {(_observers findIf {_x distance2D _position < 700}) != -1}
        || {[west,_position,300] call A3A_fnc_getRecentDamage > 50}) then {continue};
    private _distance = if (_source == _target) then {0} else {
        private _key = str [_source,_target,_maximum];
        private _cached = A3I_reinforcementRoutes getOrDefault [_key,-2];
        // Road geometry is static. Search only in scheduled planning, never in
        // the atomic resource/ownership commit; cold unscheduled calls fail closed.
        if (_cached == -2 && {canSuspend}) then {
            _cached = [_source,_target,_maximum + 500] call A3A_fnc_findNavDistance;
            A3I_reinforcementRoutes set [_key,_cached];
        };
        _cached
    };
    if (_distance >= 0 && {_distance <= _maximum + 500}) then {_sources pushBack [_source,_distance]};
} forEach (outposts + milbases + airportsX);
_sources
