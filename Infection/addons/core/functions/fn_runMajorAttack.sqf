params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _target = _record get "target";
private _source = _record get "source";
private _hq = _record get "hq";
private _nextBatch = _record get "readyAt";
private _nextCapture = 0;
private _maySpawn = {
    _record get "outcome" == "pending" && {[_source,false] call A3I_fnc_majorSourceEligible}
    && {missionNamespace getVariable ["A3I_majorGlobalOwner",""] == _record get "name"}
    && {sidesX getVariable [_target,sideUnknown] == _record get "targetOwner"}
};
if (_record get "targetOwner" == teamPlayer) then {
    private _name = if (_hq) then {"HQ"} else {[_target] call A3A_fnc_localizar};
    private _description = if (_hq) then {
        "An infected horde is approaching HQ. Protect Petros and hold off the assault."
    } else {format ["An infected horde is approaching %1. Defend the area to keep it from being overrun.",_name]};
    [true,_record get "taskId",[_description,"Defend against the infected horde",_name],
        _record get "position",false,0,true,"Defend",true] call BIS_fnc_taskCreate;
    [_record get "taskId",_record get "taskType","CREATED"] call A3A_fnc_taskUpdate;
    _record set ["taskRegistered",true];
};
while {time < _record get "endTime"} do {
    if (!([west] call A3I_fnc_isActive) || {missionNamespace getVariable ["areOccupantsDefeated",false]}
        || {!(_target in allMapMarkers)} || {!(_source in allMapMarkers)}
        || {missionNamespace getVariable ["A3I_majorGlobalOwner",""] != _record get "name"})
        exitWith {_record set ["outcome","cancelled"]};
    if (_hq) then {
        private _petros = _record get "petros";
        if (isNull _petros) exitWith {_record set ["outcome","cancelled"]};
        if (!alive _petros) exitWith {_record set ["outcome","petros_killed"]};
        if (missionNamespace getVariable ["petros",objNull] != _petros
            || {getMarkerPos "Synd_HQ" distance2D (_record get "hqPosition") > 100})
            exitWith {_record set ["outcome","hq_moved"]};
    } else {
        if (sidesX getVariable [_target,sideUnknown] == west) then {_record set ["outcome","captured"]};
    };
    if (_record get "outcome" != "pending") exitWith {};
    if (sidesX getVariable [_target,sideUnknown] != _record get "targetOwner"
        || {sidesX getVariable [_source,sideUnknown] != west}) exitWith {_record set ["outcome","cancelled"]};
    private _queue = _record get "queue";
    if (_record get "paidActors" == 0 && {time >= _record get "emptyDeadline"})
        exitWith {_record set ["outcome","no_force"]};
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
    if (_record get "outcome" != "pending") exitWith {};
    private _living = (_record get "units") select {alive _x};
    private _fighting = {!fleeing _x && {_x call A3A_fnc_canFight}} count _living;
    // Waiting attackers are still part of this single horde. A shared active
    // limit must not make a large planned force instantly cross the retreat ratio.
    if (_record get "paidActors" > 0 && {_fighting + count _queue <
        (_record get "planned") * ([0.25,0.33] select _hq)})
        exitWith {_record set ["outcome","defeated"]};
    if ((_living findIf {_x distance2D (_record get "position") <= 200}) != -1) then {
        _record set ["arrived",true];
        if (!_hq && {time >= _nextCapture} && {spawner getVariable [_target,2] == 0}
            && {{alive _x && {_x getVariable ["markerX",""] == _target}}
                count units (_record get "targetOwner") >= count (garrison getVariable [_target,[]])}) then {
            [_target,_record get "targetOwner"] spawn A3A_fnc_zoneCheck;
            _nextCapture = time + 10;
        };
    };
    sleep 1;
};
if (_record get "outcome" == "pending") then {
    _record set ["outcome",if (_record get "paidActors" == 0) then {"no_force"} else {
        if (_record get "arrived") then {"timeout"} else {"unreached"}
    }];
};
_record set ["queue",[]]; _record set ["creditRemaining",0];
// Native capture starts town populations. Persistent sites can accept only
// paid survivors that have physically arrived, within their own remaining cap.
private _handoffEnd = time + 60;
while {_record get "outcome" == "captured" && {time < _handoffEnd}
    && {sidesX getVariable [_target,sideUnknown] == west}} do {
    if (spawner getVariable [_target,2] == 0) then {
        private _kind = switch (true) do {
            case (_target in citiesX): {"City"}; case (_target in airportsX): {"Airport"};
            case (_target in milbases): {"Milbase"};
            case (_target in (outposts + seaports)): {"Outpost"}; default {"Resource"};
        };
        [_target,_kind,false] call A3I_fnc_startSite;
    };
    if (_target in citiesX) exitWith {};
    private _waiting = [];
    {
        if (isNull _x || {{alive _x} count units _x == 0}) then {continue};
        private _result = [_x,_target,true] call A3I_fnc_adoptReinforcement;
        _record set ["lastHandoff",_result];
        if !(_result # 0) then {_waiting pushBack _x};
    } forEach (_record get "groups");
    _record set ["groups",_waiting];
    if (_waiting isEqualTo []) exitWith {};
    sleep 1;
};
