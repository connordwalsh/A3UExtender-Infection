// Administration icons have the owner's explicit 50-metre arrival boundary.
params ["_marker"];
if (_marker in (missionNamespace getVariable ["milAdministrationsX",[]])) exitWith {50};
[_marker] call A3A_fnc_sizeMarker
