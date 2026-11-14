// Both mission menus use anonymous controls. Their onLoad supplies the exact
// control rather than relying on translated labels or a shared idc of -1.
params [["_control",controlNull,[controlNull]]];
if (isNull _control || {!([west] call A3I_fnc_isActive)}) exitWith {};
_control ctrlEnable false;
_control ctrlShow false;
