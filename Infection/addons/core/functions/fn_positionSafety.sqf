/* Pure placement predicate using engine terrain/geometry queries.
   [ATL position, prepared class, observer objects, HQ position, player distance]
   -> [safe, reason]. Callers must supply a verified HQ position.
   No fallback position is ever considered safe merely because a search failed. */
params ["_position", "_class", "_observers", "_hq", ["_playerDistance",150]];
if !(_position isEqualType [] && {count _position in [2,3]}
    && {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_hq isEqualType []} && {count _hq in [2,3]}
    && {(_hq findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_class isEqualType ""} && {isClass (configFile >> "CfgVehicles" >> _class)}
    && {_observers isEqualType []} && {(_observers findIf {!(_x isEqualType objNull)}) == -1}
    && {_playerDistance isEqualType 0} && {finite _playerDistance} && {_playerDistance >= 0})
    exitWith {[false,"invalid_request"]};
if (count _position == 3 && {abs (_position # 2) > 0.25}) exitWith {[false,"height"]};
if (_position # 0 < 0 || {_position # 1 < 0} || {_position # 0 >= worldSize}
    || {_position # 1 >= worldSize}) exitWith {[false,"world_bounds"]};
if (surfaceIsWater _position) exitWith {[false,"water"]};
if ((surfaceNormal _position) # 2 < cos 30) exitWith {[false,"slope"]};
if (_position distance2D _hq < 200) exitWith {[false,"hq"]};
if ((_observers findIf {!isNull _x && {_x distance2D _position < _playerDistance}}) != -1)
    exitWith {[false,"player_distance"]};
private _ground = [_position # 0, _position # 1, 0];
if (_ground findEmptyPosition [0,0,_class] isEqualTo []) exitWith {[false,"occupied_static"]};
if (nearestObjects [_ground,["CAManBase","LandVehicle","Air","Ship"],3] isNotEqualTo [])
    exitWith {[false,"occupied_entity"]};
// Reject overhead geometry too; underground and building-interior placements
// are not part of the basic outdoor spawn policy.
private _baseASL = ATLToASL _ground;
if (lineIntersectsSurfaces [_baseASL vectorAdd [0,0,0.2], _baseASL vectorAdd [0,0,3],
    objNull,objNull,true,1,"GEOM","NONE"] isNotEqualTo []) exitWith {[false,"overhead_geometry"]};
private _visible = _observers findIf {
    private _observer = _x;
    !isNull _observer && {([0.5,1.7] findIf {
        [vehicle _observer,"VIEW",_observer] checkVisibility [eyePos _observer, _baseASL vectorAdd [0,0,_x]] > 0.01
    }) != -1}
};
if (_visible != -1) exitWith {[false,"visible"]};
[true,""]
