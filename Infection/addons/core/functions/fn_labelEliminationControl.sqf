params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlSetText "Elimination Task";
_control ctrlSetTooltip "Find and neutralize the named special infected in the marked search area.";
