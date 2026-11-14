// Atomic final validation and complete formation release. No task settlement.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_releaseInterceptionFormation,_this] call CBA_fnc_directCall};
if (!([_record] call A3I_fnc_interceptionPreparing) || {!(_record getOrDefault ["prepared",false])}
    || {_record get "created" != _record get "size"}) exitWith {false};
private _units = _record get "units";
private _groups = _record get "groups";
if (count _units != _record get "size" || {_groups isEqualTo []}
    || {(_units findIf {!alive _x || {!local _x} || {!isObjectHidden _x} || {simulationEnabled _x}
        || {!(group _x in _groups)} || {side group _x != west} || {_x inArea (_record get "target")}}) != -1}
    || {(_groups findIf {isNull _x || {!local _x} || {units _x - _units isNotEqualTo []}
        || {_x getVariable ["A3I_context",""] != _record get "context"}}) != -1}) exitWith {false};
{
    while {waypoints _x isNotEqualTo []} do {deleteWaypoint [_x,0]};
    private _waypoint = _x addWaypoint [_record get "destinationPosition",0];
    _waypoint setWaypointType "MOVE";
    _waypoint setWaypointCompletionRadius 10;
    _x setCurrentWaypoint _waypoint;
} forEach _groups;
_record set ["phase","marching"];
_record set ["departedAt",time];
{
    _x setVariable ["spawner",true,true];
    _x hideObjectGlobal false;
    _x enableSimulationGlobal true;
    // Clear the prepared class's individual doMove-to-self order. Group
    // waypoints alone need not supersede it. Native target pursuit stays intact.
    _x doMove (_record get "destinationPosition");
} forEach _units;
true
