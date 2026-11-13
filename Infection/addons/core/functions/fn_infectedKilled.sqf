/* Adapted from Ultimate 12.4.1 enemyUnitKilledEH (MIT; see bundled licenses).
   Keep resource, player credit, support, garrison and postmortem contracts.
   Infected deaths are combat kills, without human surrender/revive/AI reactions. */
params ["_victim", "_killer"];
if (_victim getVariable ["A3I_finalized", false]) exitWith {};
_victim setVariable ["A3I_finalized", true];
_this call A3A_fnc_postmortem;
_victim setVariable ["spawner", nil, true];
private _side = _victim getVariable ["originalSide", west];
private _pool = _victim getVariable ["A3A_resPool", "legacy"];
if (_pool == "legacy") then {[-10, _side, "legacy"] remoteExecCall ["A3A_fnc_addEnemyResources", 2]};
if (missionNamespace getVariable ["A3A_hasACE", false] && {isNull _killer || {_killer == _victim}}) then {
    _killer = _victim getVariable ["ace_medical_lastDamageSource", _killer];
};
if (!isNull _killer && {side group _killer != _side}) then {
    [_side, getPosATL _victim, 10, _killer] remoteExecCall ["A3A_fnc_addRecentDamage", 2];
};
if (side group _killer == teamPlayer) then {
    if (isPlayer _killer) then {
        [2, _killer] call A3A_fnc_addScorePlayer;
        if (captive _killer && {_killer distance _victim < distanceSPWN}) then {
            [_killer, false] remoteExec ["setCaptive", _killer];
        };
        _killer addRating 1000;
    };
    if (vehicle _killer isKindOf "StaticMortar") then {
        {
            if (_x distance _victim < 300 && {captive _x}) then {[_x, false] remoteExec ["setCaptive", _x]};
        } forEach (call A3A_fnc_playableUnits);
    };
    [-1, 1, getPos _victim] remoteExec ["A3A_fnc_citySupportChange", 2];
    [_side, 0.5, 45] remoteExec ["A3A_fnc_addAggression", 2];
} else {
    [-0.25, 0, getPos _victim] remoteExec ["A3A_fnc_citySupportChange", 2];
};
private _marker = _victim getVariable ["markerX", ""];
if (_marker != "" && {sidesX getVariable [_marker, sideUnknown] == _side}) then {
    [_victim getVariable "unitType", _side, _marker, -1] remoteExec ["A3A_fnc_garrisonUpdate", 2];
    [_marker, _side] remoteExec ["A3A_fnc_zoneCheck", 2];
};
nil
