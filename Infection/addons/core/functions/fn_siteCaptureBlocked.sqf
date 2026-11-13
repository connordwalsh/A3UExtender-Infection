// Prevent an unspawned portion of an active garrison being counted as cleared.
// Once all queued entries have appeared, Ultimate's normal capture rules apply.
params [["_marker","",[""]]];
if (isNil "sidesX" || {isNil "spawner"} || {isNil "garrison"}) exitWith {false};
if !([sidesX getVariable [_marker,sideUnknown]] call A3I_fnc_isActive) exitWith {false};
private _locations = [];
{_locations append (missionNamespace getVariable [_x,[]])} forEach ["resourcesX","factories","outposts","seaports","milbases","airportsX"];
if !(_marker in _locations) exitWith {false};
if (spawner getVariable [_marker,2] == 2) exitWith {false};
// Fail closed during the brief activation-to-controller handoff. The pending
// count is transient spawner state, not a second saved copy of the garrison.
private _pending = spawner getVariable [_marker + "_A3I_pending",count (garrison getVariable [_marker,[]])];
if (isServer && {!isNil "A3I_sites"} && {_marker in A3I_sites}) then {
    _pending = count ((A3I_sites get _marker) get "queue");
};
_pending > 0
