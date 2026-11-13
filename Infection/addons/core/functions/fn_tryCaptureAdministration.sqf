// Captives do not participate in the clearing predicate. Real defender deaths
// are counted independently of transient object references and body cleanup.
params [["_marker","",[""]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}} || {isNil "A3I_sites"}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_tryCaptureAdministration,_this] call CBA_fnc_directCall};
private _record = A3I_sites getOrDefault [_marker,createHashMap];
if (_record getOrDefault ["kind",""] != "MilAdmin" || {_record get "cleaned"}
    || {_record get "captured" != sideUnknown} || {_record get "fault" != ""}
    || {!(_record get "spawnedAny")} || {_record get "remainingDefenders" != 0}
    || {((_record get "units") findIf {alive _x}) != -1}
    || {_record get "queue" isNotEqualTo []} || {spawner getVariable [_marker,2] != 0}
    || {sidesX getVariable [_marker,sideUnknown] != west} || {!([west] call A3I_fnc_isActive)}) exitWith {false};
private _building = _record get "building";
if (isNull _building) exitWith {_record set ["fault","missing_building"]; false};
// Preserve the native completed-building registry, ownership and capture reward.
// The destroyed-building reaction is guarded separately; never run its vehicles.
[_building,"CAPTURE"] call A3I_fnc_originalRemoveMilAdmin;
if (sidesX getVariable [_marker,sideUnknown] != teamPlayer) exitWith {
    _record set ["fault","capture_failed"]; false
};
_record set ["captured",teamPlayer];
[_marker] call A3A_fnc_mrkUpdate;
true
