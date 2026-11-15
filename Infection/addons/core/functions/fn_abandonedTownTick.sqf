params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_abandonedTowns get _x;
    if (!(_record get "ended") && {scriptDone (_record get "script")
        || {!([west] call A3I_fnc_isActive)}
        || {isNil "spawner"} || {spawner getVariable [_x+"_civ",2] == 2}}) then {
        _record set ["ended",true]; terminate (_record get "script");
    };
    if (_record get "ended" && {[_record] call A3I_fnc_cleanupAbandonedTown}) then {
        A3I_abandonedTowns deleteAt _x;
    };
} forEach keys A3I_abandonedTowns;
if (count A3I_abandonedTowns == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler; A3I_abandonedTownHandle = nil;
};
