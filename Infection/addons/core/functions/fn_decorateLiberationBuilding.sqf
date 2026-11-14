// Native damageBuilding distribution, with guarded roof geometry and exact
// ownership for both damage and the optional roof effect. The scene builder
// separately retains the native 20 percent selection among its first 100 houses.
params [["_record",createHashMap,[createHashMap]],["_building",objNull,[objNull]]];
if (!isServer || {isRemoteExecuted}) exitWith {[false,"server_local_only"]};
if (canSuspend) exitWith {[A3I_fnc_decorateLiberationBuilding,_this] call CBA_fnc_directCall};
private _roof = [_building] call A3I_fnc_liberationRoofPosition;
private _damage = random [0.7,0.9,1];
private _effect = "";
if (_roof isNotEqualTo []) then {
    if (random 100 <= 50) then {
        _effect = if (random 100 >= 70) then {"Smoke"} else {"BigDestructionFire"};
    } else {_damage = 1};
};
private _result = [_record,_building,_damage] call A3I_fnc_damageLiberationBuilding;
if (!(_result # 0) || {_result # 1 == "already_applied"}) exitWith {_result};
if (_effect != "" && {alive _building}) then {
    // A failed cosmetic effect must not lose the already-owned building.
    private _created = [_record,_roof,_effect] call A3I_fnc_createLiberationFire;
    if !(_created # 0) then {_record set ["lastSceneEffectFailure",_created # 1]};
};
[true,""]
