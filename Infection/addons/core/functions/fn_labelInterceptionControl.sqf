params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlSetText "Horde Interception";
_control ctrlSetTooltip "Neutralize a marching infected horde before its first member reaches the destination.";
