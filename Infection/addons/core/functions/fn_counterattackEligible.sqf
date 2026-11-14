// Capture-response target, distinct from an occupied site's routine repair.
params [["_marker","",[""]], ["_cooldown",true,[true]]];
if (!isServer || {!([west] call A3I_fnc_isActive)} || {isNil "sidesX"}
    || {isNil "spawner"} || {isNil "garrison"} || {isNil "server"}
    || {missionNamespace getVariable ["areOccupantsDefeated",false]}) exitWith {[false,sideUnknown,"inactive"]};
private _targets = resourcesX + factories + outposts + seaports + milbases + airportsX + citiesX;
if (!(_marker in _targets) || {!(_marker in allMapMarkers)}) exitWith {[false,sideUnknown,"target"]};
private _owner = sidesX getVariable [_marker,sideUnknown];
if !(_owner in [teamPlayer,Invaders]) exitWith {[false,_owner,"ownership"]};
if (_cooldown && {!isNil "A3I_counterattackCooldowns"}
    && {time < A3I_counterattackCooldowns getOrDefault [_marker,0]}) exitWith {[false,_owner,"cooldown"]};
[true,_owner,""]
