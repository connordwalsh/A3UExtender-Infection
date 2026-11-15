params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_eliminationTasks get _x;
    if !(_record get "settled") then {[_record] call A3I_fnc_finishElimination};
    if (_record get "settled" && {[_record] call A3I_fnc_cleanupElimination}) then {
        A3I_eliminationTasks deleteAt _x;
    };
} forEach keys A3I_eliminationTasks;
if (count A3I_eliminationTasks == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler; A3I_eliminationTaskHandle = nil;
};
