// Match only this template's registered prepared roles, never a whole side.
params [["_unit", objNull, [objNull]]];
if (isNull _unit || {isPlayer _unit}) exitWith {false};
private _side = _unit getVariable ["originalSide", side group _unit];
[_side] call A3I_fnc_isActive
    && {(_unit getVariable ["unitType", ""]) find "loadouts_occ_" == 0}
    && {typeOf _unit in (A3I_dependencies get "basicClasses")}
