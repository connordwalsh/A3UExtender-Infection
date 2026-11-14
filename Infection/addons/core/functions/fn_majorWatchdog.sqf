params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _observers = call A3I_fnc_spawnObservers;
{
    private _name = _x;
    private _record = A3I_majorAttacks get _name;
    if (!scriptDone (_record get "script")) then {continue};
    [_record] call A3I_fnc_finishMajorAttack;
    if (!(_record get "released") && {time >= _record get "releaseAt"}) then {
        _record set ["released",true];
        // Remove only our one forced-spawn entry, preserving a later duplicate.
        private _index = forcedSpawn find (_record get "target");
        if (_index >= 0) then {forcedSpawn deleteAt _index; publicVariable "forcedSpawn"};
        if (missionNamespace getVariable ["A3I_majorGlobalOwner",""] == _name) then {
            A3I_majorGlobalOwner = nil;
            bigAttackInProgress = false; publicVariable "bigAttackInProgress";
            if (_record get "hq") then {HQAttackInProgress = false; publicVariable "HQAttackInProgress"};
        };
    };
    private _context = _record get "context";
    private _tickets = []; private _units = [];
    {
        if (_y # 0 == _context) then {_tickets pushBack _x; _units append (_y # 2)};
    } forEach (missionNamespace getVariable ["A3I_budgetRecords",createHashMap]);
    _units = _units select {alive _x};
    private _groups = allGroups select {_x getVariable ["A3I_context",""] == _context};
    if (!(_record get "cleanupOrdered")) then {
        _record set ["cleanupOrdered",true];
        private _source = _record get "source";
        if (_source in allMapMarkers && {sidesX getVariable [_source,sideUnknown] == west}) then {
            {
                private _waypoint = _x addWaypoint [getMarkerPos _source,0];
                _waypoint setWaypointType "MOVE"; _x setCurrentWaypoint _waypoint;
            } forEach _groups;
        };
    };
    if ((_units findIf {
        private _unit = _x;
        (_observers findIf {_x distance2D _unit < (distanceSPWN max 150)}) != -1
    }) != -1) then {continue};
    {["cancel",[_x]] call A3I_fnc_budget} forEach _tickets;
    {if (count units _x == 0) then {deleteGroup _x}} forEach _groups;
    if (_record get "released") then {A3I_majorAttacks deleteAt _name};
} forEach keys A3I_majorAttacks;
if (count A3I_majorAttacks == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_majorWatchdogHandle = nil;
};
