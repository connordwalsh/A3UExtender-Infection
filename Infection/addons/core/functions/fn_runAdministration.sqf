#include "\x\a3a\addons\core\script_component.hpp"
params ["_marker","_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _center = getMarkerPos _marker;
[_marker,_record] call A3I_fnc_administrationAssets;
_record set ["announced",true];
[CBA_EVENT_SERVER_SPAWN_LOCATION,[_marker,"MilAdmin",true]] call A3A_fnc_triggerLocalEvent;
private _nextBatch = 0;
private _previousSimulation = -1;
while {spawner getVariable [_marker,2] != 2} do {
    private _state = spawner getVariable [_marker,2];
    private _owned = sidesX getVariable [_marker,sideUnknown] == west;
    if (!_owned) then {
        _record set ["queue",[]];
        spawner setVariable [_marker + "_A3I_pending",0,true];
    };
    if (_state != _previousSimulation) then {
        {if (alive _x) then {_x enableSimulationGlobal (_state == 0)}} forEach (_record get "units");
        _previousSimulation = _state;
    };
    private _queue = _record get "queue";
    if (_owned && {_state == 0} && {_queue isNotEqualTo []} && {diag_tickTime >= _nextBatch}
        && {_record get "fault" == ""}) then {
        private _result = [_record get "context",_queue select [0,4],_center,0,300,
            _marker,"legacy",24,false] call A3I_fnc_spawnGroup;
        private _count = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            (_record get "units") append _units;
            (_record get "groups") pushBack _group;
            _record set ["spawnedAny",true];
            _count = count _units;
            _queue deleteRange [0,_count];
            spawner setVariable [_marker + "_A3I_pending",count _queue,true];
            private _waypoint = _group addWaypoint [_center,0];
            _waypoint setWaypointType "MOVE";
            _waypoint setWaypointCompletionRadius 20;
        };
        if (_result # 2 in ["unregistered_role","invalid_request"]) then {
            _record set ["fault",_result # 2];
            diag_log format ["[INFECTION_ADMIN] marker=%1 paused reason=%2",_marker,_result # 2];
        };
        _nextBatch = diag_tickTime + (if (_count > 0) then {15} else {5});
    };
    if (_owned && {_state == 0}) then {[_marker] call A3I_fnc_tryCaptureAdministration};
    _record set ["units",(_record get "units") select {!isNull _x}];
    _record set ["groups",(_record get "groups") select {!isNull _x}];
    sleep 1;
};
[_marker,_record] call A3I_fnc_cleanupSite;
