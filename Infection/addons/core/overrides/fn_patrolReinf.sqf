params ["_target","_source","_count","_side"];
if !([_side] call A3I_fnc_isActive) exitWith {_this call A3I_fnc_originalPatrolReinf};
[_target,_source,_count] call A3I_fnc_requestReinforcement
