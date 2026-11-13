// Internal source predicate. A roaming patrol does not consume saved defenders.
params [["_base","",[""]], ["_cooldown",true,[true]]];
if (!isServer || {!([west] call A3I_fnc_isActive)} || {isNil "sidesX"}
    || {isNil "spawner"} || {isNil "garrison"} || {isNil "server"}) exitWith {false};
if (!(_base in (outposts + milbases + airportsX + seaports)) || {!(_base in allMapMarkers)}
    || {sidesX getVariable [_base,sideUnknown] != west} || {spawner getVariable [_base,2] != 2}
    || {_base in forcedSpawn} || {garrison getVariable [_base,[]] isEqualTo []}
    || {dateToNumber date < server getVariable [_base,0]}
    || {[west,getMarkerPos _base,300] call A3A_fnc_getRecentDamage > 50}) exitWith {false};
if (_cooldown && {!isNil "A3I_roamingCooldowns"}
    && {time < A3I_roamingCooldowns getOrDefault [_base,0]}) exitWith {false};
true
