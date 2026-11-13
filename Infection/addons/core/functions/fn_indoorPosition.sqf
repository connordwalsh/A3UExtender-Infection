/* Validate a building-position candidate and snap to its real supporting floor.
   [ATL position, observers, HQ ATL position] -> [safe, ATL position, reason].
   This policy is for human captives/loot only; infected remain outdoor spawns. */
params ["_position","_observers","_hq"];
if !(_position isEqualType [] && {count _position == 3}
    && {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_hq isEqualType []} && {count _hq in [2,3]}
    && {(_hq findIf {!(_x isEqualType 0) || {!finite _x}}) == -1}
    && {_observers isEqualType []} && {(_observers findIf {!(_x isEqualType objNull)}) == -1})
    exitWith {[false,[],"invalid_request"]};
if (_position # 0 < 0 || {_position # 1 < 0} || {_position # 0 >= worldSize}
    || {_position # 1 >= worldSize} || {surfaceIsWater _position}) exitWith {[false,[],"terrain"]};
if (_position distance2D _hq < 200) exitWith {[false,[],"hq"]};
if ((_observers findIf {!isNull _x && {_x distance2D _position < 150}}) != -1)
    exitWith {[false,[],"player_distance"]};
private _asl = ATLToASL _position;
private _floor = lineIntersectsSurfaces [_asl vectorAdd [0,0,0.25],_asl vectorAdd [0,0,-1.5],
    objNull,objNull,true,1,"GEOM","NONE"];
if (_floor isEqualTo [] || {((_floor # 0) # 1) # 2 < cos 30}) exitWith {[false,[],"floor"]};
private _base = ((_floor # 0) # 0) vectorAdd [0,0,0.02];
private _point = ASLToATL _base;
if (nearestObjects [_point,["CAManBase","LandVehicle","Air","Ship"],1] isNotEqualTo [])
    exitWith {[false,[],"occupied_entity"]};
if (lineIntersectsSurfaces [_base vectorAdd [0,0,0.1],_base vectorAdd [0,0,1.85],
    objNull,objNull,true,1,"GEOM","NONE"] isNotEqualTo []) exitWith {[false,[],"headroom"]};
private _body = _base vectorAdd [0,0,0.9];
if (([[0.35,0,0],[-0.35,0,0],[0,0.35,0],[0,-0.35,0]] findIf {
    lineIntersectsSurfaces [_body,_body vectorAdd _x,objNull,objNull,true,1,"GEOM","NONE"] isNotEqualTo []
}) != -1) exitWith {[false,[],"wall"]};
if ((_observers findIf {
    private _observer = _x;
    !isNull _observer && {([0.5,1.7] findIf {
        [vehicle _observer,"VIEW",_observer] checkVisibility [eyePos _observer,_base vectorAdd [0,0,_x]] > 0.01
    }) != -1}
}) != -1) exitWith {[false,[],"visible"]};
[true,_point,""]
