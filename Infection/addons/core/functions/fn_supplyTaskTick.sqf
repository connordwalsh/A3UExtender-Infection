params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_supplyTasks get _x;
    if !(_record get "settled") then {[_record] call A3I_fnc_finishSupplySeizure};
    if (_record get "settled" && {[_record] call A3I_fnc_cleanupSupplySeizure}) then {
        A3I_supplyTasks deleteAt _x;
    };
} forEach keys A3I_supplyTasks;
if (count A3I_supplyTasks == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler; A3I_supplyTaskHandle = nil;
};
