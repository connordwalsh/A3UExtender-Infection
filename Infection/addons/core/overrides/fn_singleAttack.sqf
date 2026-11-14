params ["_marker","_side","_vehicleCount","_reveal"];
if !([_side] call A3I_fnc_isActive) exitWith {_this call A3I_fnc_originalSingleAttack};
[_marker,_vehicleCount,_reveal] call A3I_fnc_startCounterattack
