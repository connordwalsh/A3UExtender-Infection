// Major hordes may originate at towns and all permanent infected sites, per the
// owner's policy. These paid forces do not consume a site's saved garrison.
params [["_source","",[""]],["_checkIdle",true,[true]]];
if (!isServer || {!([west] call A3I_fnc_isActive)} || {isNil "sidesX"}
    || {isNil "spawner"} || {isNil "server"}) exitWith {false};
private _military = airportsX + outposts + milbases;
private _permanent = _military + resourcesX + factories + seaports + citiesX
    + (missionNamespace getVariable ["milAdministrationsX",[]]);
if (!(_source in _permanent) || {!(_source in allMapMarkers)}
    || {sidesX getVariable [_source,sideUnknown] != west}
    || {spawner getVariable [_source,2] != 2} || {_source in forcedSpawn}) exitWith {false};
private _cooldowns = missionNamespace getVariable ["A3I_majorSourceCooldowns",createHashMap];
if (_checkIdle && {time < _cooldowns getOrDefault [_source,0]}) exitWith {false};
// Native military idle timestamps share the server namespace with town data.
// Never read a town's population array as a timestamp or overwrite it on launch.
private _nativeIdle = if (_source in _military) then {server getVariable [_source,0]} else {0};
if (_checkIdle && {!(_nativeIdle isEqualType 0 && {finite _nativeIdle})
    || {dateToNumber date < _nativeIdle}}) exitWith {false};
private _position = getMarkerPos _source;
if ([west,_position,300] call A3A_fnc_getRecentDamage > 50
    || {((call A3I_fnc_spawnObservers) findIf {_x distance2D _position < 700}) != -1}) exitWith {false};
true
