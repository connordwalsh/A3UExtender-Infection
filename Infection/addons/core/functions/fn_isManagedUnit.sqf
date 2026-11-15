// Match registered basic roles or explicitly created, approved mission specials.
params [["_unit", objNull, [objNull]]];
if (isNull _unit || {isPlayer _unit}) exitWith {false};
private _side = _unit getVariable ["originalSide", side group _unit];
if !([_side] call A3I_fnc_isActive) exitWith {false};
if (_unit getVariable ["A3I_specialManaged",false]) exitWith {
    typeOf _unit in (call A3I_fnc_eliminationClasses)
};
(_unit getVariable ["unitType", ""]) find "loadouts_occ_" == 0
    && {typeOf _unit in (A3I_dependencies get "basicClasses")}
