// Bounded roadside-first search, then safe outdoor parking within the location.
params [["_target","",[""]],["_class","",[""]]];
if (!isServer || {isRemoteExecuted} || {!(_target in allMapMarkers)}) exitWith {[[],0]};
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if (!(_hq in allMapMarkers) || {!isClass (configFile >> "CfgVehicles" >> _class)}) exitWith {[[],0]};
private _center = getMarkerPos _target;
private _radius = ([_target] call A3I_fnc_interceptionRadius) min 2000;
if (_radius <= 0) exitWith {[[],0]};
private _roads = _center nearRoads _radius;
private _observers = call A3I_fnc_spawnObservers;
private _result = [[],0];
for "_attempt" from 0 to 23 do {
    private _heading = random 360;
    private _candidate = [];
    if (_attempt < 12 && {_roads isNotEqualTo []}) then {
        private _road = selectRandom _roads;
        private _connections = roadsConnectedTo _road;
        if (_connections isNotEqualTo []) then {
            _heading = [getPosATL _road,getPosATL (_connections # 0)] call BIS_fnc_dirTo;
        };
        _candidate = (getPosATL _road) getPos [8 + random 8,_heading + selectRandom [-90,90]];
    } else {_candidate = _center getPos [sqrt random 1 * _radius,random 360]};
    _candidate set [2,0];
    _candidate = _candidate findEmptyPosition [0,12,_class];
    if (_candidate isEqualTo [] || {!([_candidate,_target] call A3I_fnc_interceptionContains)}) then {continue};
    if (([_candidate,_class,_observers,getMarkerPos _hq] call A3I_fnc_positionSafety) # 0)
        exitWith {_result = [_candidate,_heading]};
};
_result
