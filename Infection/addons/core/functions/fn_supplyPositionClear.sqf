/* Truck-specific geometry guard, after positionSafety validates the request.
   [ATL position, class, heading] -> [safe, reason]. No simulated vehicle exists
   yet. Sample the class footprint at its intended heading, not just its centre. */
params ["_position","_class","_heading"];
if (!isServer || {isRemoteExecuted} || {!finite _heading}) exitWith {[false,"truck_request"]};
private _bounds = [_class] call A3I_fnc_supplyTruckBounds;
if (_bounds isEqualTo []) exitWith {[false,"truck_bounds"]};
private _minimum = _bounds # 0;
private _maximum = _bounds # 1;
private _left = (_minimum # 0) - 0.25;
private _right = (_maximum # 0) + 0.25;
private _back = (_minimum # 1) - 0.25;
private _front = (_maximum # 1) + 0.25;
private _height = (_maximum # 2) - (_minimum # 2) + 0.25;
private _columns = ceil ((_right - _left) / 0.75);
private _rows = ceil ((_front - _back) / 0.75);
private _sin = sin _heading;
private _cos = cos _heading;
private _reason = "";
private _grid = [];
private _ground = getTerrainHeightASL _position;
for "_row" from 0 to _rows do {
    private _line = [];
    for "_column" from 0 to _columns do {
        private _xLocal = _left + (_right - _left) * _column / _columns;
        private _yLocal = _back + (_front - _back) * _row / _rows;
        private _point = _position vectorAdd [
            _xLocal * _cos + _yLocal * _sin,
            _yLocal * _cos - _xLocal * _sin,0];
        if (_point # 0 < 0 || {_point # 1 < 0} || {_point # 0 >= worldSize}
            || {_point # 1 >= worldSize} || {surfaceIsWater _point}
            || {(surfaceNormal _point) # 2 < cos 15}
            || {abs ((getTerrainHeightASL _point) - _ground) > 0.75}) exitWith {_reason = "truck_terrain"};
        private _base = ATLToASL _point;
        _line pushBack _base;
        {
            if (lineIntersectsSurfaces [_base vectorAdd [0,0,0.2],_base vectorAdd [0,0,_height],
                objNull,objNull,true,1,_x,"NONE"] isNotEqualTo []) exitWith {_reason = "truck_geometry"};
        } forEach ["GEOM","PHYSX"];
        if (_reason != "") exitWith {};
    };
    _grid pushBack _line;
    if (_reason != "") exitWith {};
};
if (_reason != "") exitWith {[false,_reason]};
// Horizontal scans catch fences/walls between the vertical samples. Heights
// are above the highest supported ground, avoiding false terrain intersections.
{
    private _z = _ground + 0.75 + _x;
    private _segments = [];
    for "_row" from 0 to _rows do {_segments pushBack [(_grid # _row) # 0,(_grid # _row) # _columns]};
    for "_column" from 0 to _columns do {_segments pushBack [(_grid # 0) # _column,(_grid # _rows) # _column]};
    {
        private _start = +(_x # 0); private _end = +(_x # 1);
        _start set [2,_z]; _end set [2,_z];
        {
            if (lineIntersectsSurfaces [_start,_end,objNull,objNull,true,1,_x,"NONE"] isNotEqualTo [])
                exitWith {_reason = "truck_geometry"};
        } forEach ["GEOM","PHYSX"];
        if (_reason != "") exitWith {};
    } forEach _segments;
    if (_reason != "") exitWith {};
} forEach [0.2,1,_height min 2,_height];
[_reason == "",_reason]
