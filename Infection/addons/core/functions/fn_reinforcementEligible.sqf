// Routine repair policy, separate from a site's original queued defenders.
// [marker, checkCooldown=true] -> [eligible, deficit, reason].
params [["_marker","",[""]], ["_cooldown",true,[true]]];
if (!isServer || {!([west] call A3I_fnc_isActive)} || {isNil "sidesX"}
    || {isNil "spawner"} || {isNil "garrison"}) exitWith {[false,0,"inactive"]};
private _sites = [];
{_sites append (missionNamespace getVariable [_x,[]])} forEach ["resourcesX","factories","outposts","seaports","milbases","airportsX"];
if (!(_marker in _sites) || {!(_marker in allMapMarkers)}
    || {sidesX getVariable [_marker,sideUnknown] != west}) exitWith {[false,0,"ownership"]};
if (_marker in forcedSpawn) exitWith {[false,0,"forced_spawn"]};
// Native routine reinforcements defer significant recent fighting to QRFs.
if ([west,getMarkerPos _marker,300] call A3A_fnc_getRecentDamage > 50)
    exitWith {[false,0,"combat"]};
if (_cooldown && {!isNil "A3I_reinforcementCooldowns"}
    && {time < A3I_reinforcementCooldowns getOrDefault [_marker,0]})
    exitWith {[false,0,"cooldown"]};
if (spawner getVariable [_marker,2] != 2) then {
    private _record = if (isNil "A3I_sites") then {createHashMap} else {A3I_sites getOrDefault [_marker,createHashMap]};
    if (count _record == 0 || {_record get "cleaned"} || {scriptDone (_record get "script")}
        || {_record get "fault" != ""} || {_record get "queue" isNotEqualTo []})
        exitWith {_sites = []};
};
if (_sites isEqualTo []) exitWith {[false,0,"original_queue"]};
private _deficit = ([_marker] call A3A_fnc_garrisonSize) - count (garrison getVariable [_marker,[]]);
if (_deficit <= 0) exitWith {[false,0,"full"]};
[true,_deficit,""]
