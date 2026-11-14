params [["_source","",[""]]];
if (!isServer || {!([west] call A3I_fnc_isActive)} || {isNil "sidesX"}
    || {isNil "spawner"} || {isNil "garrison"} || {isNil "server"}) exitWith {false};
if (!(_source in (outposts + airportsX + milbases)) || {!(_source in allMapMarkers)}
    || {sidesX getVariable [_source,sideUnknown] != west} || {spawner getVariable [_source,2] != 2}
    || {_source in forcedSpawn} || {count (garrison getVariable [_source,[]]) < 16}
    || {dateToNumber date < server getVariable [_source,0]}) exitWith {false};
private _position = getMarkerPos _source;
if ([west,_position,300] call A3A_fnc_getRecentDamage > 50
    || {((call A3I_fnc_spawnObservers) findIf {_x distance2D _position < 700}) != -1}) exitWith {false};
true
