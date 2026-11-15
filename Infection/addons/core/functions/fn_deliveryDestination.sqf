/* [living subject, "truck" or "survivor"] -> friendly marker name or "".
   Location predicate only. Mission owners validate their exact truck/survivor,
   settle rewards, and retain delivered assets. No ownership or asset mutation. */
params [["_subject",objNull,[objNull]],["_kind","",[""]]];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}
    || {isNull _subject} || {!alive _subject} || {!(_kind in ["truck","survivor"])}
    || {isNil "teamPlayer"} || {isNil "sidesX"}) exitWith {""};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
private _result = "";
if (_hq isEqualType "" && {_hq in allMapMarkers}) then {
    // Preserve each native mission's HQ reference and distance convention.
    private _position = if (_kind == "truck") then {
        missionNamespace getVariable ["posHQ",[]]
    } else {getMarkerPos _hq};
    if (_position isEqualType [] && {count _position == 3}
        && {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}) then {
        private _radius = [50,100] select (_kind == "truck");
        if (_subject distanceSqr _position < _radius * _radius) then {_result = _hq};
    };
};
if (_result != "") exitWith {_result};
private _sites = [];
{
    private _list = missionNamespace getVariable [_x,[]];
    if (_list isEqualType []) then {_sites append _list};
} forEach ["airportsX","milbases","outposts","factories","resourcesX","seaports"];
private _excluded = (missionNamespace getVariable ["citiesX",[]])
    + (missionNamespace getVariable ["controlsX",[]])
    + (missionNamespace getVariable ["milAdministrationsX",[]]);
{
    if (!(_x isEqualType "") || {!(_x in allMapMarkers)} || {_x in _excluded}
        || {sidesX getVariable [_x,sideUnknown] != teamPlayer}
        || {!(markerShape _x in ["ELLIPSE","RECTANGLE"])}
        || {(markerSize _x findIf {_x <= 0 || {!finite _x}}) != -1}) then {continue};
    if (_subject inArea _x) exitWith {_result = _x};
} forEach (_sites arrayIntersect _sites);
_result
