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
    // Active administrations replace live-deleted actors without clearing them.
    // Preserve that extra's saved role even if it was unfit when deleted. Check
    // the exact visit here: adopted actors attach their admin handler after this
    // native bookkeeping handler, so handler order cannot decide persistence.
    private _site = (missionNamespace getVariable ["A3I_sites",createHashMap])
        getOrDefault [_marker,createHashMap];
    private _replaced = _pool == "garrison" && {_site getOrDefault ["kind",""] == "MilAdmin"}
        && {!(_site getOrDefault ["cleaned",true])}
        && {_site getOrDefault ["id",-1] == _unit getVariable ["A3I_adminId",-2]}
        && {!isNil "spawner"} && {spawner getVariable [_marker,2] != 2};
    if (!_replaced) then {
        [_unit getVariable "unitType", _side, _marker, -1] remoteExec ["A3A_fnc_garrisonUpdate", 2];
    };
};
nil
