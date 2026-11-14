/* Bounded outdoor placement across a town's actual marker, including rotation.
   [marker, class, group anchor=[], cached road positions=[]] -> [position, reason].
   Group leaders sample the town; followers stay within 50m of their leader's
   spawn point. Every candidate keeps the existing HQ/observer/geometry checks. */
params ["_marker","_class",["_anchor",[]],["_roads",[]]];
if !(_marker isEqualType "" && {_marker in allMapMarkers}
    && {markerShape _marker in ["RECTANGLE","ELLIPSE"]}
    && {_class isEqualType ""} && {isClass (configFile >> "CfgVehicles" >> _class)}
    && {_anchor isEqualType []} && {count _anchor in [0,2,3]}
    && {(_anchor findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_roads isEqualType []}) exitWith {[[],"invalid_request"]};
private _size = markerSize _marker;
if ((_size findIf {!finite _x || {_x <= 0}}) != -1) exitWith {[[],"invalid_request"]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if !(_hq in allMapMarkers) exitWith {[[],"hq_unavailable"]};
private _center = getMarkerPos _marker;
private _angle = markerDir _marker;
private _observers = call A3I_fnc_spawnObservers;
private _position = [];
private _reason = "no_position";
for "_attempt" from 1 to 16 do {
    private _candidate = [];
    if (_anchor isNotEqualTo []) then {
        _candidate = _anchor getPos [40 * sqrt random 1,random 360];
    } else {
        if (_roads isNotEqualTo [] && {_attempt <= 10}) then {
            _candidate = (selectRandom _roads) getPos [random 12,random 360];
        } else {
            private _dx = 0;
            private _dy = 0;
            if (markerShape _marker == "RECTANGLE") then {
                _dx = (2 * random 1 - 1) * (_size # 0);
                _dy = (2 * random 1 - 1) * (_size # 1);
            } else {
                private _radius = sqrt random 1;
                private _bearing = random 360;
                _dx = (_size # 0) * _radius * sin _bearing;
                _dy = (_size # 1) * _radius * cos _bearing;
            };
            _candidate = [(_center # 0) + _dx * cos _angle + _dy * sin _angle,
                (_center # 1) - _dx * sin _angle + _dy * cos _angle,0];
        };
    };
    _candidate set [2,0];
    _candidate = _candidate findEmptyPosition [0,8,_class];
    if (_candidate isEqualTo []) then {_reason = "no_empty_position"; continue};
    if (!(_candidate inArea _marker) || {_anchor isNotEqualTo [] && {_candidate distance2D _anchor > 50}})
        then {_reason = "town_bounds"; continue};
    private _safe = [_candidate,_class,_observers,getMarkerPos _hq] call A3I_fnc_positionSafety;
    if (_safe # 0) exitWith {_position = _candidate; _reason = ""};
    _reason = _safe # 1;
};
[_position,_reason]
