params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
_arguments params ["_name","_serial"];
private _record = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial || {_record getOrDefault ["taskRetired",false]}
    || {_record getOrDefault ["taskCleanupHandle",-1] != _handle}) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    if (_record getOrDefault ["taskCleanupHandle",-1] == _handle) then {_record deleteAt "taskCleanupHandle"};
};
[_record] call A3I_fnc_cleanupInterceptionTask;
