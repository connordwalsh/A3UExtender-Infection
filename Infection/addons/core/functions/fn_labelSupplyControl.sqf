params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlSetText "Supplies Seizure";
_control ctrlSetTooltip "Recover an abandoned service truck to HQ or a Rebel-held permanent site. Capturing its source site also completes recovery.";
