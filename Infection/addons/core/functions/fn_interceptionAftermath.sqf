// Called by the independent lifecycle supervisor after first-entry task failure.
// Keep the original physical horde until it reinforces, fights or safely retires.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_interceptionAftermath,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap])
    getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {!(_record getOrDefault ["settled",false])}
    || {_record getOrDefault ["outcome",""] != "arrived"}
    || {_record getOrDefault ["phase",""] != "arrived"}
    || {_record getOrDefault ["retired",true]}
    || {_record getOrDefault ["aftermathComplete",false]}) exitWith {false};
if (time < _record getOrDefault ["nextAftermathAt",0]) exitWith {false};
_record set ["nextAftermathAt",time + 1];
private _finish = {
    params ["_reason"];
    _record set ["aftermathReason",_reason];
    _record set ["aftermathComplete",true];
    true
};
private _target = _record get "target";
if (!([west] call A3I_fnc_isActive) || {!(_target in allMapMarkers)}
    || {isNil "sidesX"} || {isNil "spawner"} || {isNil "garrison"})
    exitWith {["destination_unavailable"] call _finish};
if (isNil {_record get "aftermathDeadline"}) then {
    // Ultimate gives convoys an hour. Give the surviving force that same window
    // after arrival; an expired force still waits for observers before cleanup.
    _record set ["aftermathDeadline",time + 3600];
    _record set ["nextCaptureAt",time + 10];
};
// Task preparation/marching workers may stop after settlement. Their lifecycle
// owner, not a dead worker, now keeps native movement recovery alive.
if (_record getOrDefault ["marchHandle",-1] < 0) then {
    _record set ["marchHandle",[A3I_fnc_interceptionMarchTick,1,
        [_name,_record get "serial"]] call CBA_fnc_addPerFrameHandler];
};
private _living = (_record get "units") select {alive _x};
if (_living isEqualTo []) exitWith {["resolved"] call _finish};
private _owner = sidesX getVariable [_target,sideUnknown];
private _previousOwner = _record getOrDefault ["arrivalOwner",_owner];
_record set ["arrivalOwner",_owner];
private _administration = _target in (missionNamespace getVariable ["milAdministrationsX",[]]);
if (_owner == west) then {
    // The distance loop does not recreate an already active site's controller
    // after native capture. Its old creator retains ownership of scene assets.
    if (_previousOwner != west && {!_administration}
        && {spawner getVariable [_target,2] == 0}) then {
        [_target,[_target] call A3I_fnc_liquidationTargetKind,false] call A3I_fnc_startSite;
    };
    // Each transaction rechecks destination/visit, ticket, whole-group arrival
    // and observer state. Busy garrisons and distance-loop transitions defer.
    {
        if (isNull _x || {{alive _x} count units _x == 0}) then {continue};
        private _result = if (spawner getVariable [_target,2] == 0) then {
            [_record,_x] call A3I_fnc_adoptInterceptionArrivals
        } else {
            [_record,_x] call A3I_fnc_storeInterceptionArrivals
        };
        _record set ["lastArrivalHandoff",_result];
    } forEach +(_record get "groups");
} else {
    // Existing spawner=true actors activate opposing garrisons through Ultimate's
    // distance loop. Never flip an unspawned defence or simulate away live actors.
    // Cleared administrations remain permanently cleared; the horde still fights
    // nearby humans through its unchanged native AI and destination orders.
    if (!_administration && {_owner in [teamPlayer,east]}
        && {_target in (call A3I_fnc_interceptionLocations)}
        && {spawner getVariable [_target,2] == 0}
        && {time >= _record get "nextCaptureAt"}
        && {!(_target in (missionNamespace getVariable ["markersChanging",[]]))}
        && {(_living findIf {[_x,_target] call A3I_fnc_interceptionContains}) >= 0}
        && {{alive _x && {_x getVariable ["markerX",""] == _target}}
            count units _owner >= count (garrison getVariable [_target,[]])}) then {
        [_target,_owner] spawn A3A_fnc_zoneCheck;
        _record set ["nextCaptureAt",time + 10];
    };
};
if (((_record get "units") findIf {alive _x}) == -1) exitWith {["resolved"] call _finish};
if (time >= _record get "aftermathDeadline") exitWith {["timeout"] call _finish};
false
