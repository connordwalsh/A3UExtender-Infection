// Internal callback: a remote caller must never select a handler for removal.
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
private _pending = [];
{
    if (isNull _x) then {continue};
    if (local _x && {units _x isEqualTo []}) then {deleteGroup _x};
    if (!isNull _x) then {_pending pushBack _x};
} forEach A3I_retiredGroups;
A3I_retiredGroups = _pending;
if (_pending isEqualTo []) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_groupCleanupHandle = nil;
};
