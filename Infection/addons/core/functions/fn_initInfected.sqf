// Bookkeeping follows Ultimate NATOinit; leave prepared-class AI/health intact.
// Related upstream license and attribution: Infection/THIRD_PARTY_LICENSES.txt.
#include "\x\a3a\addons\core\script_component.hpp"
params ["_unit", ["_marker", ""], "_isSpawner", "_resPool"];
if (isNull _unit || {!local _unit} || {!([_unit] call A3I_fnc_isManagedUnit)}) exitWith {};
if (_unit getVariable ["A3I_initialized", false]) exitWith {};
_unit setVariable ["A3I_initialized", true];
_unit setVariable ["originalSide", west];
if (isNil "_resPool") then {_resPool = ["legacy", "garrison"] select (_marker != "")};
_unit setVariable ["A3A_resPool", _resPool, true];
// Prepared infected cannot use Ultimate's human unconscious/revive flow.
_unit setVariable ["canBeIncapacitated", false, true];
if (_marker != "") then {_unit setVariable ["markerX", _marker, true]};
if (isNil "_isSpawner") then {
    _isSpawner = _marker == "";
    // Match NATOinit: only implicit persistent garrisons inherit inactive-site simulation.
    if (_marker != "" && {!isNil "spawner"} && {spawner getVariable [_marker, 2] != 0}) then {
        [_unit, false] remoteExecCall ["enableSimulationGlobal", 2];
    };
};
_unit setVariable ["spawner", _isSpawner, true];
// Add only our own handlers; do not remove or rerun WebKnight handlers.
private _handlers = [
    ["HandleDamage", _unit addEventHandler ["HandleDamage", A3I_fnc_infectedDamageObserved]],
    ["Killed", _unit addEventHandler ["Killed", A3I_fnc_infectedKilled]],
    ["Deleted", _unit addEventHandler ["Deleted", A3I_fnc_infectedDeleted]]
];
_unit setVariable ["A3I_handlers", _handlers];
[CBA_EVENT_SERVER_INIT_AI_UNIT, [_unit, west, _marker, _isSpawner]] call A3A_fnc_triggerServerEvent;
nil
