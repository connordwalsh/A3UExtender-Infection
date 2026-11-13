// Adapted from Ultimate enemyUnitDeletedEH; use the actual unit on every path.
params ["_unit"];
if (!alive _unit || {_unit getVariable ["A3I_finalized", false]}) exitWith {};
_unit setVariable ["A3I_finalized", true];
private _pool = _unit getVariable ["A3A_resPool", "legacy"];
private _side = _unit getVariable ["originalSide", west];
if (_unit call A3A_fnc_canFight) exitWith {
    if (_pool in ["attack", "defence"]) then {
        [10, _side, _pool] remoteExecCall ["A3A_fnc_addEnemyResources", 2];
    };
};
if (_pool == "legacy") then {[-10, _side, "legacy"] remoteExecCall ["A3A_fnc_addEnemyResources", 2]};
private _marker = _unit getVariable ["markerX", ""];
if (_marker != "" && {sidesX getVariable [_marker, sideUnknown] == _side}) then {
    [_unit getVariable "unitType", _side, _marker, -1] remoteExec ["A3A_fnc_garrisonUpdate", 2];
};
nil
