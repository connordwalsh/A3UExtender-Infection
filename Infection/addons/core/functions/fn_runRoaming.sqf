params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _base = _record get "source";
private _route = _record get "route";
private _nextBatch = 0;
private _maySpawn = {[_base,false] call A3I_fnc_roamingEligible};
while {time < _record get "endTime"} do {
    if (!([west] call A3I_fnc_isActive) || {(_route findIf {
        !((_x # 0) in allMapMarkers) || {sidesX getVariable [_x # 0,sideUnknown] != west}
    }) != -1}) exitWith {};
    if (time >= _record get "spawnDeadline") then {_record set ["queue",[]]};
    private _queue = _record get "queue";
    if (_queue isNotEqualTo [] && {time >= _nextBatch} && {call _maySpawn}) then {
        // Preserve native patrol legacy accounting: deaths cost resources;
        // healthy despawns do not refund money that was never spent.
        private _result = [_record get "context",_queue,getMarkerPos _base,0,200,
            "","legacy",4,false,_maySpawn] call A3I_fnc_spawnGroup;
        private _created = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            _created = count _units;
            (_record get "units") append _units;
            (_record get "groups") pushBack _group;
            _queue deleteRange [0,_created];
            private _first = [];
            {
                private _waypoint = _group addWaypoint [_x # 1,0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointCompletionRadius 20;
                if (_first isEqualTo []) then {_first = _waypoint};
            } forEach _route;
            private _cycle = _group addWaypoint [_route # 0 # 1,0];
            _cycle setWaypointType "CYCLE";
            _group setCurrentWaypoint _first;
        };
        if (_result # 2 in ["unregistered_role","invalid_request"]) then {_record set ["queue",[]]};
        _nextBatch = time + (if (_created > 0) then {15} else {5});
    };
    private _units = (_record get "units") select {alive _x};
    if (_queue isEqualTo [] && {_units isEqualTo []}) exitWith {};
    private _observers = call A3I_fnc_spawnObservers;
    if ((_observers findIf {
        private _observer = _x;
        _observer distance2D getMarkerPos _base < 2000
        || {(_units findIf {_observer distance2D _x < 2000}) != -1}
    }) != -1) then {_record set ["lastObserved",time]};
    // A short grace interval avoids churn as observers leave/reenter the area.
    if (time > (_record get "lastObserved") + 60) exitWith {};
    sleep 1;
};
_record set ["queue",[]];
