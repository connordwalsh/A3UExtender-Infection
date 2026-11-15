params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlSetText "Humanitarian Aid";
_control ctrlSetTooltip "Deliver supplies to survivors in an infected-held town and protect the unloading area.";
