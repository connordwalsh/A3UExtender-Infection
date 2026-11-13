// One server handler for all sites; it removes itself when the registry is empty.
params ["_arguments","_handle"];
// This callback is internal to CBA. A remote call must never be able to pass
// another component's handler ID to the removal operation below.
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_sites get _x;
    if (scriptDone (_record get "script")) then {[_x,_record] call A3I_fnc_cleanupSite};
} forEach keys A3I_sites;
if (count A3I_sites == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_siteWatchdogHandle = nil;
};
