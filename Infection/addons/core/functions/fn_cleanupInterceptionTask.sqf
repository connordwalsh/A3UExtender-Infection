// Retire task metadata independently from the surviving horde's aftermath.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_cleanupInterceptionTask,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {!(_record getOrDefault ["settled",false])}) exitWith {false};
if (_record getOrDefault ["taskRetired",false]) exitWith {true};
// An invalid cleanup deadline must not strand a settled task indefinitely.
private _deleteAt = time;
if (!isNil {_record get "taskDeleteAt"}) then {
    private _value = _record get "taskDeleteAt";
    if (_value isEqualType 0 && {finite _value}) then {_deleteAt = _value};
};
if (time < _deleteAt) exitWith {false};
private _tasks = missionNamespace getVariable ["A3A_tasksData",[]];
private _index = _tasks findIf {_x # 0 == _name};
// Never delete a task another system has reassigned to a different category.
if (_index < 0 || {_tasks # _index # 1 == "CONVOY"}) then {
    if (_index >= 0) then {[_name,"CONVOY","DELETED"] call A3A_fnc_taskUpdate};
    [_name] call BIS_fnc_deleteTask;
};
_record set ["taskRetired",true];
private _handle = _record getOrDefault ["taskCleanupHandle",-1];
if (_handle >= 0) then {[_handle] call CBA_fnc_removePerFrameHandler; _record deleteAt "taskCleanupHandle"};
true
