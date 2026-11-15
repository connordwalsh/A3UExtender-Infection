params ["_position","_marker"];
if (!(_marker in allMapMarkers)) exitWith {false};
if (_marker in (missionNamespace getVariable ["milAdministrationsX",[]])) exitWith {
    _position distance2D getMarkerPos _marker <= ([_marker] call A3I_fnc_interceptionRadius)
};
_position inArea _marker
