params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record=A3I_extractionTasks get _x;
    if !(_record get "settled") then {[_record] call A3I_fnc_finishExtraction};
    if (_record get "settled" && {[_record] call A3I_fnc_cleanupExtraction}) then {A3I_extractionTasks deleteAt _x};
} forEach keys A3I_extractionTasks;
if (count A3I_extractionTasks == 0) then {[_handle] call CBA_fnc_removePerFrameHandler; A3I_extractionTaskHandle=nil};
