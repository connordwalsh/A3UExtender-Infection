params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _target = _record get "target";
private _source = _record get "source";
private _nextBatch = 0;
private _maySpawn = {
    [west] call A3I_fnc_isActive && {sidesX getVariable [_source,sideUnknown] == west}
    && {spawner getVariable [_source,2] == 2} && {spawner getVariable [_target,2] == 0}
    && {([_target,false] call A3I_fnc_reinforcementEligible) # 0}
};
while {time < _record get "travelDeadline"} do {
    if (!([west] call A3I_fnc_isActive) || {sidesX getVariable [_target,sideUnknown] != west}
        || {sidesX getVariable [_source,sideUnknown] != west} || {spawner getVariable [_target,2] == 2}) exitWith {};
    if (time >= _record get "spawnDeadline") then {_record set ["queue",[]]};
    private _queue = _record get "queue";
    if (_queue isNotEqualTo [] && {time >= _nextBatch} && {call _maySpawn}) then {
        private _result = [_record get "context",_queue select [0,4],getMarkerPos _source,0,200,
            "","defence",8,false,_maySpawn,true] call A3I_fnc_spawnGroup;
        private _created = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            _created = count _units;
            (_record get "units") append _units;
            (_record get "groups") pushBack _group;
            _queue deleteRange [0,_created];
            private _waypoint = _group addWaypoint [getMarkerPos _target,0];
            _waypoint setWaypointType "MOVE";
            _waypoint setWaypointCompletionRadius 20;
            _group setCurrentWaypoint _waypoint;
        };
        if (_result # 2 in ["unregistered_role","invalid_request"]) then {_record set ["queue",[]]};
        _nextBatch = time + (if (_created > 0) then {15} else {5});
    };
    private _waiting = [];
    {
        if (isNull _x || {{alive _x} count units _x == 0}) then {continue};
        private _adopted = [_x,_target] call A3I_fnc_adoptReinforcement;
        _record set ["lastHandoff",_adopted];
        if (_adopted # 0) then {
            _record set ["units",(_record get "units") - units _x];
        } else {_waiting pushBack _x};
    } forEach (_record get "groups");
    _record set ["groups",_waiting];
    if (_record get "queue" isEqualTo [] && {_waiting isEqualTo []}) exitWith {};
    sleep 1;
};
_record set ["queue",[]];
_record set ["stage","cleanup"];
