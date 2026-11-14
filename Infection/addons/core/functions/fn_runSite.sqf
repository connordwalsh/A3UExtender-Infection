// Persistent six-site adapter: resources/factories, outposts/seaports, bases, airports.
// Saved roster entries remain virtual until safely spawned. Refusals never consume them.
#include "\x\a3a\addons\core\script_component.hpp"
params ["_marker","_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _kind = _record get "kind";
private _center = getMarkerPos _marker;
private _radius = ([_marker] call A3A_fnc_sizeMarker) max 50;
// Initial defenders can appear inside the site while it is still out of view.
// Later batches may approach from its surroundings, always through the same checks.
private _outerRadius = (_radius + 250) min 1000;
if (_record getOrDefault ["assets",true]) then {
    private _flagData = [_marker] call A3A_fnc_createZoneFlag;
    if (!isNil "_flagData" && {_flagData isEqualType []} && {count _flagData > 0}) then {
        _record set ["flag",_flagData # 0];
        if (!isNil {_flagData # 1}) then {(_record get "positions") pushBack (_flagData # 1)};
    };
    private _crateCount = switch (_kind) do {case "Resource": {0}; case "Milbase": {2}; default {1}};
    for "_i" from 1 to _crateCount do {
        private _crateData = [_marker] call A3A_fnc_createZoneAmmoBox;
        if (!isNil "_crateData" && {_crateData isEqualType []} && {count _crateData > 0}) then {
            if (!isNull (_crateData # 0)) then {(_record get "crates") pushBack (_crateData # 0)};
            if (!isNil {_crateData # 1}) then {(_record get "positions") pushBack (_crateData # 1)};
        };
    };
    if (_kind == "Resource" && {!(A3A_faction_civ getOrDefault ["attributeLowCiv",false])}) then {
        private _civData = [_marker,4] call A3A_fnc_createResourceCiv;
        if (!isNil "_civData" && {_civData isEqualType []} && {count _civData == 2}) then {
            (_record get "groups") pushBack (_civData # 0);
            (_record get "civilians") append (_civData # 1);
        };
    };
    _record set ["announced",true];
    [CBA_EVENT_SERVER_SPAWN_LOCATION,[_marker,_kind,true]] call A3A_fnc_triggerLocalEvent;
};
private _nextBatch = 0;
private _previousSimulation = -1;
while {spawner getVariable [_marker,2] != 2} do {
    private _state = spawner getVariable [_marker,2];
    private _owned = sidesX getVariable [_marker,sideUnknown] == west;
    if (!_owned) then {
        // A real ownership change cancels unspawned arrivals. Existing actors
        // remain until normal distance cleanup, avoiding a visible disappearance.
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
        private _result = [_record get "context",_queue select [0,4],_center,0,_outerRadius,
            _marker,"garrison",24] call A3I_fnc_spawnGroup;
        private _count = 0;
        if (_result # 0) then {
            (_result # 1) params ["_group","_units"];
            (_record get "units") append _units;
            (_record get "groups") pushBack _group;
            _count = count _units;
            _queue deleteRange [0,_count];
            spawner setVariable [_marker + "_A3I_pending",count _queue,true];
            private _waypoint = _group addWaypoint [_center,0];
            _waypoint setWaypointType "MOVE";
            _waypoint setWaypointCompletionRadius 15;
        };
        // Creation failures retain the queue. Invalid data waits for repair;
        // capacity/placement failures retry, with no busy loop or center fallback.
        if (_result # 2 in ["unregistered_role","invalid_request"]) then {
            _record set ["fault",_result # 2];
            diag_log format ["[INFECTION_SITE] marker=%1 paused reason=%2 pending=%3",_marker,_result # 2,count _queue];
        };
        if (A3I_budgetDiagnostics) then {
            diag_log format ["[INFECTION_SITE] marker=%1 created=%2 pending=%3 reason=%4",_marker,_count,count _queue,_result # 2];
        };
        _nextBatch = diag_tickTime + (if (_count > 0) then {15} else {5});
    };
    // Remove only transient references; dead bodies stay with Ultimate's despawner.
    _record set ["units",(_record get "units") select {!isNull _x}];
    _record set ["groups",(_record get "groups") select {!isNull _x}];
    sleep 1;
};
[_marker,_record] call A3I_fnc_cleanupSite;
