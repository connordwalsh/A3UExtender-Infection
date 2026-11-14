// Town/control patrols regenerate per visit, without a saved roster or vehicles.
#include "\x\a3a\addons\core\script_component.hpp"
params ["_marker","_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _center = getMarkerPos _marker;
private _kind = _record get "kind";
private _town = _kind == "City";
private _outerRadius = ((([_marker] call A3A_fnc_sizeMarker) max 50) + 250) min 1000;
private _began = diag_tickTime;
private _populationReady = false;
private _nextReport = diag_tickTime + 30;
if (_town) then {
    private _size = markerSize _marker;
    private _roads = (_center nearRoads sqrt ((_size # 0)^2 + (_size # 1)^2)) apply {getPosATL _x};
    _record set ["townRoads",_roads select {_x inArea _marker}];
    diag_log format ["[INFECTION_TOWN] marker=%1 target=%2 phase=activate",_marker,_record get "populationTarget"];
};
_record set ["announced",true];
[CBA_EVENT_SERVER_SPAWN_LOCATION,[_marker,_kind,true]] call A3A_fnc_triggerLocalEvent;
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
        private _result = [_record get "context",_queue select [0,_record get "batchSize"],_center,0,_outerRadius,
            _marker,"legacy",if (_town) then {200} else {24},false] call A3I_fnc_spawnGroup;
        private _count = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            (_record get "units") append _units;
            (_record get "groups") pushBack _group;
            _record set ["spawnedAny",true];
            _count = count _units;
            _record set ["spawnedCount",(_record get "spawnedCount") + _count];
            _queue deleteRange [0,_count];
            spawner setVariable [_marker + "_A3I_pending",count _queue,true];
            if (_kind == "City") then {[_group,_marker] call A3I_fnc_patrolWaypoints} else {
                private _waypoint = _group addWaypoint [_center,0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointCompletionRadius 10;
            };
        };
        if (_result # 2 in ["unregistered_role","invalid_request"]) then {
            _record set ["fault",_result # 2];
            diag_log format ["[INFECTION_PATROL] marker=%1 paused reason=%2 pending=%3",_marker,_result # 2,count _queue];
        };
        if (A3I_budgetDiagnostics) then {
            diag_log format ["[INFECTION_PATROL] marker=%1 created=%2 pending=%3 reason=%4",_marker,_count,count _queue,_result # 2];
        };
        if (_town && {diag_tickTime >= _nextReport} && {_queue isNotEqualTo []}) then {
            diag_log format ["[INFECTION_TOWN] marker=%1 target=%2 created=%3 pending=%4 reason=%5",
                _marker,_record get "populationTarget",_record get "spawnedCount",count _queue,_result # 2];
            _nextReport = diag_tickTime + 30;
        };
        // Towns fill immediately; only blocked placement/ownership/capacity retries
        // wait. Controls preserve their existing 15-second arrival pacing.
        _nextBatch = diag_tickTime + (if (_count > 0) then {if (_town) then {0} else {15}} else {5});
    };
    if (_town && {_owned} && {!_populationReady} && {_queue isEqualTo []}) then {
        _populationReady = true;
        diag_log format ["[INFECTION_TOWN] marker=%1 target=%2 created=%3 living=%4 phase=ready seconds=%5",
            _marker,_record get "populationTarget",_record get "spawnedCount",{alive _x} count (_record get "units"),diag_tickTime - _began];
    };
    // Remember arrival before testing capture. A safely spawned approaching
    // defender outside the capture radius must not look like an empty control.
    if (_kind == "Control") then {
        {
            if ([_x,_marker] call A3A_fnc_canConquer) then {_x setVariable ["A3I_controlArrived",true]};
        } forEach (_record get "units");
        if (_owned && {_state == 0}) then {[_marker,_record] call A3I_fnc_tryCaptureControl};
    } else {
        // Retry obstructed routes without a search loop every frame or new actors.
        if (_state == 0) then {
            {
                if (alive leader _x && {_x getVariable ["A3I_patrolPoints",[]] isEqualTo []}
                    && {diag_tickTime >= _x getVariable ["A3I_routeRetry",0]}) then {
                    [_x,_marker] call A3I_fnc_patrolWaypoints;
                };
            } forEach (_record get "groups");
        };
    };
    _record set ["units",(_record get "units") select {!isNull _x}];
    _record set ["groups",(_record get "groups") select {!isNull _x}];
    sleep (if (_town && {_owned} && {_state == 0} && {_queue isNotEqualTo []} && {_record get "fault" == ""}
        && {diag_tickTime >= _nextBatch}) then {0.05} else {1});
};
[_marker,_record] call A3I_fnc_cleanupSite;
