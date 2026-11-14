#include "\x\a3a\addons\core\script_component.hpp"
params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_competitiveMissions get _x;
    if (scriptDone (_record get "script")) then {
        [_record] call A3I_fnc_finishCompetitiveMission;
        A3I_competitiveMissions deleteAt _x;
    };
} forEach keys A3I_competitiveMissions;
if (count A3I_competitiveMissions == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_competitiveWatchdogHandle = nil;
    [CBA_EVENT_SERVER_MARKER_CHANGE,A3I_competitiveCaptureHandle] call CBA_fnc_removeEventHandler;
    A3I_competitiveCaptureHandle = nil;
};
