// Claims are bounded by known markers, retained through the native mission and
// released when that rebuild ends. Running QRFs keep their normal lifecycle.
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    if (!(_x in allMapMarkers) || {!(missionNamespace getVariable ["A3U_rebuilding_" + _x,false])}) then {
        A3I_rebuildClaims deleteAt _x;
    };
} forEach keys A3I_rebuildClaims;
if (count A3I_rebuildClaims == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_rebuildWatchdogHandle = nil;
};
