params [["_unit", objNull, [objNull]]];
if !([_unit] call A3I_fnc_isManagedUnit) exitWith {_this call A3I_fnc_originalNATOinit};
_this call A3I_fnc_initInfected
