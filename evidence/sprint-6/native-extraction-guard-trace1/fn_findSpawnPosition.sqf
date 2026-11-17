/* Bounded outdoor search. [center, min radius, max radius, prepared class]
   -> [safe ATL position or [], last rejection reason]. No center fallback. */
params ["_center", "_minimum", "_maximum", "_class"];
if !(_center isEqualType [] && {count _center in [2,3]}
    && {(_center findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_minimum isEqualType 0} && {finite _minimum} && {_minimum >= 0}
    && {_maximum isEqualType 0} && {finite _maximum} && {_maximum >= _minimum}
    && {_maximum <= 2000} && {_class isEqualType ""}
    && {isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {[[],"invalid_request"]};
private _hqMarker = missionNamespace getVariable ["respawnTeamPlayer", ""];
if !(_hqMarker isEqualType "" && {_hqMarker in allMapMarkers}) exitWith {[[],"hq_unavailable"]};
private _hq = getMarkerPos _hqMarker;
private _observers = call A3I_fnc_spawnObservers;
private _result = [];
private _reason = "no_position";
for "_attempt" from 1 to 16 do {
    private _radius = sqrt (_minimum^2 + random (_maximum^2 - _minimum^2));
    private _candidate = _center getPos [_radius, random 360];
    _candidate set [2,0];
    // Each engine search is local and bounded; validate its result again.
    _candidate = _candidate findEmptyPosition [0,8,_class];
    if (_candidate isEqualTo []) then {_reason = "no_empty_position"; continue};
    private _distance = _candidate distance2D _center;
    if (_distance < _minimum || {_distance > _maximum}) then {_reason = "search_bounds"; continue};
    private _safety = [_candidate,_class,_observers,_hq] call A3I_fnc_positionSafety;
    if (_safety # 0) exitWith {_result = _candidate; _reason = ""};
    _reason = _safety # 1;
};
[_result,_reason]
