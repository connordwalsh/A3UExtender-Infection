params ["_record"];
if (!isServer || {!canSuspend} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _target = _record get "target";
private _source = _record get "source";
private _nextBatch = 0;
private _nextCapture = 0;
private _maySpawn = {
    ([_source] call A3I_fnc_counterattackSourceEligible)
    && {!(missionNamespace getVariable ["areOccupantsDefeated",false])}
    && {sidesX getVariable [_target,sideUnknown] == _record get "targetOwner"}
};
while {time < _record get "endTime"} do {
    if (!([west] call A3I_fnc_isActive) || {!(_target in allMapMarkers)}
        || {missionNamespace getVariable ["areOccupantsDefeated",false]}) exitWith {_record set ["outcome","cancelled"]};
    private _owner = sidesX getVariable [_target,sideUnknown];
    if (_owner == west) then {
        _record set ["queue",[]];
        _record set ["outcome","captured"];
        if (_record get "handoffDeadline" < 0) then {_record set ["handoffDeadline",time + 60]};
        // Native distance processing does not recreate a controller merely
        // because ownership changed while the marker remained spawned.
        if (spawner getVariable [_target,2] == 0) then {
            private _kind = switch (true) do {
                case (_target in citiesX): {"City"};
                case (_target in airportsX): {"Airport"};
                case (_target in milbases): {"Milbase"};
                case (_target in (outposts + seaports)): {"Outpost"};
                default {"Resource"};
            };
            [_target,_kind,false] call A3I_fnc_startSite;
        };
        private _waiting = [];
        {
            if (isNull _x || {{alive _x} count units _x == 0}) then {continue};
            private _units = +(units _x);
            private _result = [_x,_target,true] call A3I_fnc_adoptReinforcement;
            _record set ["lastHandoff",_result];
            if (_result # 0) then {_record set ["units",(_record get "units") - _units]} else {_waiting pushBack _x};
        } forEach (_record get "groups");
        _record set ["groups",_waiting];
        if (_waiting isEqualTo [] || {time >= _record get "handoffDeadline"} || {_target in citiesX}) exitWith {};
    } else {
        if (_owner != _record get "targetOwner" || {!(_source in allMapMarkers)}
            || {sidesX getVariable [_source,sideUnknown] != west}) exitWith {_record set ["outcome","cancelled"]};
        if (time >= _record get "spawnDeadline") then {_record set ["queue",[]]};
        private _queue = _record get "queue";
        if (_queue isNotEqualTo [] && {time >= _nextBatch} && {call _maySpawn}) then {
            private _result = [_record get "context",_queue select [0,4],getMarkerPos _source,0,200,
                "","defence",24,false,_maySpawn,true] call A3I_fnc_spawnGroup;
            private _created = 0;
            if (_result # 0) then {
                (_result # 1) params ["_group","_units"];
                _created = count _units;
                (_record get "units") append _units;
                (_record get "groups") pushBack _group;
                _record set ["created",(_record get "created") + _created];
                _queue deleteRange [0,_created];
                // Native distance processing must activate the defending site
                // as these troops approach, even without a connected player.
                {_x setVariable ["spawner",true,true]} forEach _units;
                private _waypoint = _group addWaypoint [_record get "position",0];
                _waypoint setWaypointType "MOVE";
                _waypoint setWaypointCompletionRadius 20;
                _group setCurrentWaypoint _waypoint;
                if (!(_record get "announced")) then {
                    _record set ["announced",true];
                    // Preserve the native warning without inventing a walking ETA.
                    [(_record get "reveal") min 0.79,west,"CounterAttack",_record get "position",0]
                        call A3A_fnc_showInterceptedSetupCall;
                };
            };
            if (_result # 2 in ["unregistered_role","invalid_request"]) then {_record set ["queue",[]]};
            _nextBatch = time + (if (_created > 0) then {15} else {5});
        };
        private _living = (_record get "units") select {alive _x};
        private _fighting = {!fleeing _x && {_x call A3A_fnc_canFight}} count _living;
        // Preserve Ultimate's retreat threshold once staging has finished. An
        // empty force also terminates instead of waiting for a 0 < 0 comparison.
        if (_record get "queue" isEqualTo [] && {
            _living isEqualTo [] || {_fighting < 0.25 * (_record get "created")}
        }) exitWith {
            _record set ["outcome",if (_record get "created" == 0) then {"no_force"} else {"defeated"}];
        };
        private _defendersReady = spawner getVariable [_target,2] == 0 && {
            // A newly activated native creator may still be materializing its
            // saved roster. Do not capture past defenders still waiting to spawn.
            {alive _x && {_x getVariable ["markerX",""] == _target}} count units _owner
                >= count (garrison getVariable [_target,[]])
        };
        if (time >= _nextCapture && {_defendersReady}
            && {(_living findIf {_x distance2D getMarkerPos _target <= 200}) != -1}) then {
            // The native transaction still decides ownership using all factions.
            [_target,_owner] spawn A3A_fnc_zoneCheck;
            _nextCapture = time + 10;
        };
    };
    // An exitWith inside either branch exits that block, not this enclosing loop.
    if (_record get "outcome" in ["cancelled","no_force","defeated"]) exitWith {};
    if (_record get "outcome" == "captured" && {
        _record get "groups" isEqualTo [] || {time >= _record get "handoffDeadline"} || {_target in citiesX}
    }) exitWith {};
    sleep 1;
};
if (_record get "outcome" == "pending") then {_record set ["outcome","timeout"]};
_record set ["queue",[]];
