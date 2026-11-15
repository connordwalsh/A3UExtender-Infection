// Towns and administrations regenerate their baseline, but save extra defenders.
// Other saved entries are not part of this population and must remain untouched.
params [["_marker","",[""]]];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}} || {!([west] call A3I_fnc_isActive)}
    || {isNil "garrison"} || {isNil "sidesX"}
    || {!(_marker in ((missionNamespace getVariable ["citiesX",[]])
        + (missionNamespace getVariable ["milAdministrationsX",[]])))}
    || {sidesX getVariable [_marker,sideUnknown] != west}) exitWith {[]};
private _roster = garrison getVariable [_marker,[]];
if !(_roster isEqualType []) exitWith {[]};
private _definitions = A3A_faction_occ getOrDefault ["loadouts",createHashMap];
_roster select {_x isEqualType "" && {_x find "loadouts_occ_" == 0} && {(_x select [13]) in _definitions}}
