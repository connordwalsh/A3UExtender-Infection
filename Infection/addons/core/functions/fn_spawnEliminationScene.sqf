// Internal bounded scene factory. Caller owns returned actors and budget ticket.
// [marker, optional approved primary class] -> [success,[target,escorts,group,ticket,context],reason].
params [["_marker","",[""]],["_primary","",[""]]];
private _empty = [objNull,[],grpNull,"",""];
if (!isServer || {isRemoteExecuted} || {!canSuspend}) exitWith {[false,_empty,"scheduled_server_only"]};
if !(_marker in (call A3I_fnc_eliminationTargets)) exitWith {[false,_empty,"target_unavailable"]};
private _roster = [_primary] call A3I_fnc_eliminationRoster;
if (_roster isEqualTo []) exitWith {[false,_empty,"roster_unavailable"]};
private _roles = [_roster # 0] + (_roster # 1) + (_roster # 2);
private _specials = call A3I_fnc_eliminationClasses;
private _classes = [];
{
    if (_x in _specials) then {_classes pushBack _x} else {
        private _definition = A3A_customUnitTypes getVariable [_x,[]];
        if (count _definition < 4) exitWith {};
        private _traits = _definition # 1;
        private _index = _traits findIf {_x # 0 == "baseClass"};
        if (_index == -1) exitWith {};
        private _class = _traits # _index # 1;
        if !(_class in (A3I_dependencies get "basicClasses")) exitWith {};
        _classes pushBack _class;
    };
} forEach _roles;
if (count _classes != count _roles) exitWith {[false,_empty,"unregistered_role"]};
private _hqMarker = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hqMarker in allMapMarkers) exitWith {[false,_empty,"hq_unavailable"]};
private _center = getMarkerPos _marker;
private _radius = if (_marker in (missionNamespace getVariable ["milAdministrationsX",[]])) then {40}
    else {((markerSize _marker # 0) min (markerSize _marker # 1)) min 100};
private _positions = []; private _reason = "no_safe_position";
{
    private _anchor = if (_positions isEqualTo []) then {_center} else {_positions # 0};
    private _maximum = if (_positions isEqualTo []) then {_radius} else {25 min _radius};
    private _position = [];
    for "_attempt" from 1 to 8 do {
        private _search = [_anchor,0,_maximum,_x] call A3I_fnc_findSpawnPosition;
        private _candidate = _search # 0;
        if (_candidate isEqualTo []) exitWith {_reason = _search # 1};
        if ([_candidate,_marker] call A3I_fnc_interceptionContains
            && {(_positions findIf {_x distance2D _candidate < 3.5}) == -1}) exitWith {_position = _candidate};
    };
    if (_position isEqualTo []) exitWith {};
    _positions pushBack _position;
} forEach _classes;
if (count _positions != count _roles) exitWith {[false,_empty,_reason]};
A3I_eliminationSceneSerial = (missionNamespace getVariable ["A3I_eliminationSceneSerial",0])+1;
private _context = "elimination:scene:"+str A3I_eliminationSceneSerial;
private _reservation = ["reserve",[_context,count _roles,count _roles]] call A3I_fnc_budget;
if !(_reservation # 0) exitWith {[false,_empty,_reservation # 2]};
(_reservation # 1) params ["_ticket","_granted"];
if (_granted != count _roles) exitWith {
    ["close",[_ticket]] call A3I_fnc_budget;
    [false,_empty,"capacity"]
};
private _group = grpNull; private _units = []; private _success = false;
_reason = "";
isNil {
    if (!(_marker in (call A3I_fnc_eliminationTargets)) || {!(_hqMarker in allMapMarkers)}) exitWith {_reason = "target_changed"};
    private _observers = call A3I_fnc_spawnObservers;
    private _safe = true;
    {if !(([_x,_classes # _forEachIndex,_observers,getMarkerPos _hqMarker] call A3I_fnc_positionSafety) # 0)
        exitWith {_safe = false}} forEach _positions;
    if (!_safe) exitWith {_reason = "placement_changed"};
    _group = createGroup [west,false];
    if (isNull _group) exitWith {_reason = "group_limit"};
    _group setVariable ["A3I_context",_context];
    {
        private _unit = [_group,_x,_positions # _forEachIndex,[],0,"NONE"] call A3A_fnc_createUnit;
        if (isNull _unit) exitWith {_reason = "creation_failed"};
        _units pushBack _unit;
        if (_x in _specials) then {_unit setVariable ["A3I_specialManaged",true]};
        private _bound = ["bind",[_ticket,_unit]] call A3I_fnc_budget;
        if !(_bound # 0) exitWith {_reason = _bound # 2};
        [_unit,"",false,"legacy"] call A3A_fnc_NATOinit;
        if !(_unit getVariable ["A3I_initialized",false]) exitWith {_reason = "initialization_failed"};
        if (!alive _unit || {_unit distance2D (_positions # _forEachIndex) > 1}) exitWith {_reason = "placement_changed"};
    } forEach _roles;
    _success = _reason == "" && {count _units == count _roles}
        && {(_units findIf {!alive _x || {!(_x getVariable ["A3I_initialized",false])}}) == -1};
};
["close",[_ticket]] call A3I_fnc_budget;
if (!_success) exitWith {
    {deleteVehicle _x} forEach _units;
    if (!isNull _group) then {[[_group]] call A3I_fnc_cleanupGroups};
    [false,_empty,_reason]
};
_group deleteGroupWhenEmpty true;
[true,[_units # 0,_units select [1],_group,_ticket,_context],""]
