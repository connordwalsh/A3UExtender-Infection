// Internal recovery. Hold the shared native patrol slot until cleanup finishes.
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _observers = call A3I_fnc_spawnObservers;
{
    private _base = _x;
    private _record = A3I_roamers get _base;
    if (!scriptDone (_record get "script")) then {continue};
    private _context = _record get "context";
    private _tickets = [];
    private _units = [];
    if (!isNil "A3I_budgetRecords") then {
        {if (_y # 0 == _context) then {_tickets pushBack _x; _units append (_y # 2)}} forEach A3I_budgetRecords;
    };
    _units = _units select {alive _x};
    private _groups = allGroups select {_x getVariable ["A3I_context",""] == _context};
    if (!(_record get "cleanupOrdered")) then {
        _record set ["cleanupOrdered",true];
        if (_base in allMapMarkers && {sidesX getVariable [_base,sideUnknown] == west}) then {
            {
                private _waypoint = _x addWaypoint [getMarkerPos _base,0];
                _waypoint setWaypointType "MOVE";
                _x setCurrentWaypoint _waypoint;
            } forEach _groups;
        };
    };
    if ((_units findIf {
        private _unit = _x;
        (_observers findIf {_x distance2D _unit < (distanceSPWN max 150)}) != -1
    }) != -1) then {continue};
    {["cancel",[_x]] call A3I_fnc_budget} forEach _tickets;
    {if (count units _x == 0) then {deleteGroup _x}} forEach _groups;
    if (_record get "counted") then {
        _record set ["counted",false];
        AAFpatrols = 0 max (AAFpatrols - 1);
    };
    A3I_roamers deleteAt _base;
} forEach keys A3I_roamers;
if (count A3I_roamers == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_roamingWatchdogHandle = nil;
};
