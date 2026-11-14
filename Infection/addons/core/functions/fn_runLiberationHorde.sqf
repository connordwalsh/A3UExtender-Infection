// A liberation force attacks a survivor in its own faction's town. It must not
// run the capture worker, create a second task, capture the town or hand off units.
params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted}) exitWith {};
private _target = _record get "target";
private _source = _record get "source";
private _mission = _record get "mission";
private _parent = (missionNamespace getVariable ["A3I_liberations",createHashMap])
    getOrDefault [_mission,createHashMap];
private _nextBatch = _record get "readyAt";
private _maySpawn = {
    _record get "outcome" == "pending"
    && {missionNamespace getVariable ["A3I_majorGlobalOwner",""] == _record get "name"}
    && {_mission in (missionNamespace getVariable ["A3I_liberations",createHashMap])}
    && {[_parent] call A3I_fnc_liberationOutcome == "pending"}
    && {[_source,false] call A3I_fnc_majorSourceEligible}
};
while {_record get "outcome" == "pending" && {time < _record get "endTime"}} do {
    if (!(_mission in (missionNamespace getVariable ["A3I_liberations",createHashMap]))
        || {missionNamespace getVariable ["A3I_majorGlobalOwner",""] != _record get "name"})
        exitWith {_record set ["outcome","cancelled"]};
    private _parentOutcome = [_parent] call A3I_fnc_liberationOutcome;
    if (_parentOutcome != "pending") exitWith {
        _record set ["outcome",if (_parentOutcome == "won") then {"defended"} else {
            if (_parentOutcome in ["survivor_lost","expired"]) then {_parentOutcome} else {"cancelled"}
        }];
    };
    if (_record get "paidActors" == 0 && {time >= _record get "emptyDeadline"})
        exitWith {_record set ["outcome","no_force"]};
    private _queue = _record get "queue";
    if (_queue isNotEqualTo [] && {time >= _nextBatch} && {call _maySpawn}) then {
        private _result = [_record get "context",_queue select [0,4],getMarkerPos _source,0,200,
            "","attack",24,false,_maySpawn,true,_record get "name"] call A3I_fnc_spawnGroup;
        private _created = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            _created = count _units;
            (_record get "units") append _units; (_record get "groups") pushBack _group;
            _queue deleteRange [0,_created];
            {_x setVariable ["spawner",true,true]} forEach _units;
            private _waypoint = _group addWaypoint [_record get "position",0];
            _waypoint setWaypointType "MOVE"; _waypoint setWaypointCompletionRadius 20;
            _group setCurrentWaypoint _waypoint;
        };
        if (_result # 2 in ["unregistered_role","invalid_request","credit"])
            exitWith {_record set ["outcome","cancelled"]};
        _nextBatch = time + (if (_created > 0) then {15} else {5});
    };
    // First physical arrival starts the owner's full ten-minute defense clock.
    // Later batches and temporary departures cannot restart or shorten it.
    if (!(_record get "arrived") && {((_record get "units") findIf {
        _x call A3A_fnc_canFight && {_x inArea _target}
    }) != -1}) then {
        _record set ["arrived",true]; _record set ["arrivedAt",time];
    };
    sleep 1;
};
if (_record get "outcome" == "pending") then {
    _record set ["outcome",if (_record get "paidActors" == 0) then {"no_force"} else {"unreached"}];
};
_record set ["queue",[]]; _record set ["creditRemaining",0];
