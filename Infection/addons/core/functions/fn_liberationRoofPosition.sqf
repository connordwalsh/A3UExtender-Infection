// Read-only geometry query. A missing roof never becomes an origin fallback or
// an unchecked select 0, as in the native damageBuilding helper.
params [["_building",objNull,[objNull]]];
if (isNull _building || {!alive _building} || {!(_building isKindOf "House")}
    || {isObjectHidden _building}) exitWith {[]};
private _box = boundingBoxReal _building;
if (count _box < 2) exitWith {[]};
private _minimum = _box # 0;
private _maximum = _box # 1;
private _center = (_minimum vectorAdd _maximum) vectorMultiply 0.5;
private _top = _building modelToWorldWorld [_center # 0,_center # 1,(_maximum # 2) + 1];
private _bottom = _building modelToWorldWorld [_center # 0,_center # 1,(_minimum # 2) - 1];
private _hits = lineIntersectsSurfaces [_top,_bottom,objNull,objNull,true,16,"GEOM","NONE"];
private _index = _hits findIf {(_x # 2 == _building || {_x # 3 == _building}) && {(_x # 1) # 2 > 0}};
if (_index < 0) exitWith {[]};
ASLToATL ((_hits # _index # 0) vectorAdd [0,0,0.05])
