// Towns have fuel only; permanent infected-held sites allow all service roles.
params [["_marker","",[""]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNil "sidesX"} || {!(_marker in (call A3I_fnc_interceptionLocations))}
    || {sidesX getVariable [_marker,sideUnknown] != west}) exitWith {[]};
if (_marker in (missionNamespace getVariable ["citiesX",[]])) exitWith {["fuel"]};
["ammunition","fuel","repair"]
