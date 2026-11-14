params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _source = _record get "source";
private _position = _record get "position";
private _nextBatch = _record get "readyAt";
private _nextCapture = 0;
private _nearMarker = "";
private _sites = resourcesX + factories + outposts + seaports + milbases + airportsX;
if (_sites isNotEqualTo []) then {
    private _nearest = [_sites,_position] call BIS_fnc_nearestPosition;
    if (getMarkerPos _nearest distance2D _position < 500) then {_nearMarker = _nearest};
};
private _maySpawn = {[_source,false] call A3I_fnc_counterattackSourceEligible};
while {time < _record get "endTime"} do {
    if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]}
        || {!(_source in allMapMarkers)} || {sidesX getVariable [_source,sideUnknown] != west})
        exitWith {_record set ["outcome","cancelled"]};
    if (time >= _record get "spawnDeadline") then {_record set ["queue",[]]};
    private _queue = _record get "queue";
    if (_queue isNotEqualTo [] && {time >= _nextBatch} && {call _maySpawn}) then {
        private _result = [_record get "context",_queue select [0,4],getMarkerPos _source,0,200,
            "",_record get "pool",24,false,_maySpawn,true] call A3I_fnc_spawnGroup;
        private _created = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            _created = count _units;
            (_record get "units") append _units;
            (_record get "groups") pushBack _group;
            _record set ["created",(_record get "created") + _created];
            _queue deleteRange [0,_created];
            {_x setVariable ["spawner",true,true]} forEach _units;
            private _waypoint = _group addWaypoint [_position,0];
            _waypoint setWaypointType "MOVE";
            _waypoint setWaypointCompletionRadius 20;
            _group setCurrentWaypoint _waypoint;
            if !(_record get "announced") then {
                _record set ["announced",true];
                [(_record get "reveal") min 0.79,west,"QRFLAND",_position,0] call A3A_fnc_showInterceptedSetupCall;
            };
        };
        if (_result # 2 in ["unregistered_role","invalid_request"]) then {_record set ["queue",[]]};
        _nextBatch = time + (if (_created > 0) then {15} else {5});
    };
    private _living = (_record get "units") select {alive _x};
    private _fighting = {!fleeing _x && {_x call A3A_fnc_canFight}} count _living;
    if (_record get "queue" isEqualTo [] && {_living isEqualTo [] || {_fighting <= 0.25 * (_record get "created")}})
        exitWith {_record set ["outcome",if (_record get "created" == 0) then {"no_force"} else {"defeated"}]};
    private _groups = (_record get "groups") select {!isNull _x && {alive leader _x}};
    if (_record get "searchDeadline" < 0 && {(_groups findIf {leader _x distance2D _position < 300}) != -1}) then {
        _record set ["searchDeadline",time + 600];
    };
    if (_record get "searchDeadline" >= 0 && {time > _record get "searchDeadline"}
        && {(_groups findIf {(leader _x findNearestEnemy _position) distance2D _position < 500}) == -1})
        exitWith {_record set ["outcome","searched"]};
    if (time >= _nextCapture && {_nearMarker in allMapMarkers}
        && {spawner getVariable [_nearMarker,2] == 0}
        && {(_living findIf {_x distance2D getMarkerPos _nearMarker <= 200}) != -1}) then {
        private _owner = sidesX getVariable [_nearMarker,sideUnknown];
        if (_owner in [west,Invaders,teamPlayer] && {
            {alive _x && {_x getVariable ["markerX",""] == _nearMarker}} count units _owner
                >= count (garrison getVariable [_nearMarker,[]])
        }) then {[_nearMarker,_owner] spawn A3A_fnc_zoneCheck};
        _nextCapture = time + 10;
    };
    sleep 1;
};
if (_record get "outcome" == "pending") then {_record set ["outcome","timeout"]};
_record set ["queue",[]];
// Preserve the native post-search garrison opportunity, without transferring
// actors early or bypassing physical arrival and site capacity.
private _handoffDeadline = time + 60;
while {_nearMarker in allMapMarkers && {sidesX getVariable [_nearMarker,sideUnknown] == west}
    && {time < _handoffDeadline} && {!(_record get "outcome" in ["cancelled","no_force"])}} do {
    if (spawner getVariable [_nearMarker,2] == 0) then {
        private _kind = switch (true) do {
            case (_nearMarker in airportsX): {"Airport"};
            case (_nearMarker in milbases): {"Milbase"};
            case (_nearMarker in (outposts + seaports)): {"Outpost"};
            default {"Resource"};
        };
        [_nearMarker,_kind,false] call A3I_fnc_startSite;
    };
    private _waiting = [];
    {
        if (isNull _x || {{alive _x} count units _x == 0}) then {continue};
        private _result = [_x,_nearMarker,true] call A3I_fnc_adoptReinforcement;
        _record set ["lastHandoff",_result];
        if !(_result # 0) then {_waiting pushBack _x};
    } forEach (_record get "groups");
    _record set ["groups",_waiting];
    if (_waiting isEqualTo []) exitWith {};
    sleep 1;
};
