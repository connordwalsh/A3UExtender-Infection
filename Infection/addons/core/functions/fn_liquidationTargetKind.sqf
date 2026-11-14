// Classify the owner's town/permanent-site targets. Road controls retain their
// native conquest eligibility; field patrol controls are not conquest sites.
params [["_marker","",[""]]];
if (!(_marker in allMapMarkers)) exitWith {""};
private _kind = "";
{
    _x params ["_list","_type"];
    if (_marker in (missionNamespace getVariable [_list,[]])) exitWith {_kind = _type};
} forEach [["citiesX","City"],["milAdministrationsX","MilAdmin"],
    ["airportsX","Airport"],["milbases","Milbase"],["outposts","Outpost"],
    ["seaports","Outpost"],["factories","Resource"],["resourcesX","Resource"]];
if (_kind == "" && {_marker in (missionNamespace getVariable ["controlsX",[]])}
    && {isOnRoad getMarkerPos _marker}) then {_kind = "Control"};
_kind
