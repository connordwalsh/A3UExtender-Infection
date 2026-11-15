// Read-only, bounded search of real building positions. No center fallback.
// [source marker, desired 2..6] -> [building or objNull, checked ATL positions].
params [["_marker","",[""]],["_desired",6,[0]]];
if (!isServer || {isRemoteExecuted} || {!finite _desired} || {_desired != floor _desired}
    || {_desired < 2} || {_desired > 6} || {!(_marker in (call A3I_fnc_extractionLocations))})
    exitWith {[objNull,[]]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[objNull,[]]};
private _observers = call A3I_fnc_spawnObservers;
private _radius = ((markerSize _marker) distance [0,0]) min 2000;
private _blacklist = missionNamespace getVariable ["A3A_buildingBlacklist",[]];
private _buildings = (nearestObjects [getMarkerPos _marker,["House"],_radius,true]) select {
    alive _x && {!(typeOf _x in _blacklist)}
};
_buildings = (_buildings call BIS_fnc_arrayShuffle) select [0,32];
private _result = [objNull,[]];
{
    private _building = _x;
    private _chosen = [];
    private _positions = (_building buildingPos -1) select [0,64];
    {
        if (count _chosen >= _desired) exitWith {};
        if !(_x inArea _marker) then {continue};
        private _safe = [_x,_observers,getMarkerPos _hq] call A3I_fnc_indoorPosition;
        if !(_safe # 0) then {continue};
        private _point = _safe # 1;
        if (_point inArea _marker && {(_chosen findIf {_x distance _point < 1.5}) == -1}) then {
            _chosen pushBack _point;
        };
    } forEach _positions;
    if (count _chosen >= 2) exitWith {_result = [_building,_chosen]};
} forEach _buildings;
_result
