params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlSetText "Extraction Mission";
_control ctrlSetTooltip "Rescue stranded survivors to HQ or a Rebel-held permanent site. Deliveries become manpower; resolve every survivor before the deadline.";
