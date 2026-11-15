// Retire exact owned actors/tickets, including an interrupted spawnGroup call.
// Hidden preparation actors can retire immediately; visible actors wait until
// observers leave. This helper does not settle or delete the mission's task.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_retireInterceptionFormation,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record set ["phase","cleanup"];
private _marchHandle = _record getOrDefault ["marchHandle",-1];
if (_marchHandle >= 0) then {
    [_marchHandle] call CBA_fnc_removePerFrameHandler;
    _record deleteAt "marchHandle";
};
private _context = _record get "context";
private _tickets = []; private _units = +(_record get "units");
{
    if (_y # 0 == _context) then {_tickets pushBack _x; _units append (_y # 2)};
} forEach (missionNamespace getVariable ["A3I_budgetRecords",createHashMap]);
_units = (_units arrayIntersect _units) select {alive _x};
private _observers = call A3I_fnc_spawnObservers;
private _distance = (missionNamespace getVariable ["distanceSPWN",1000]) max 150;
if ((_units findIf {
    private _unit = _x;
    !isObjectHidden _unit && {(_observers findIf {_x distance2D _unit < _distance}) != -1}
}) != -1) exitWith {false};
_record set ["retired",true];
{["cancel",[_x]] call A3I_fnc_budget} forEach _tickets;
{if (alive _x) then {deleteVehicle _x}} forEach _units;
private _groups = +(_record get "groups");
{if (_x getVariable ["A3I_context",""] == _context) then {_groups pushBackUnique _x}} forEach allGroups;
[_groups] call A3I_fnc_cleanupGroups;
true
