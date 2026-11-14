params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlSetText "Liquidation Assignment";
_control ctrlSetTooltip "Clear an infected-held town or site so friendly forces can move in.";
