// Every-frame observation, independent of the scheduled formation/controller job.
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
_arguments params ["_name","_serial"];
private _record = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _serial || {_record getOrDefault ["settled",false]}
    || {_record getOrDefault ["taskHandle",-1] != _handle}) exitWith {
    [_handle] call CBA_fnc_removePerFrameHandler;
    if (_record getOrDefault ["taskHandle",-1] == _handle) then {_record deleteAt "taskHandle"};
};
[_record] call A3I_fnc_finishInterception;
