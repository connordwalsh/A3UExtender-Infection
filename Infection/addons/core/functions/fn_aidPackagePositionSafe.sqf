// HQ package creation is intentionally visible, like native SUPP delivery cargo.
params [["_position",[],[[]]]];
private _hq = missionNamespace getVariable ["respawnTeamPlayer",""];
if (!(_hq in allMapMarkers) || {count _position != 3}
    || {(_position findIf {!(_x isEqualType 0) || {!finite _x}}) != -1}
    || {abs (_position # 2) > 0.25} || {_position distance2D getMarkerPos _hq > 50}
    || {_position # 0 < 0} || {_position # 1 < 0} || {_position # 0 >= worldSize} || {_position # 1 >= worldSize}
    || {surfaceIsWater _position} || {(surfaceNormal _position) # 2 < cos 30}) exitWith {false};
if (_position findEmptyPosition [0,0,"Land_FoodSacks_01_cargo_brown_F"] isEqualTo []) exitWith {false};
if (nearestObjects [_position,["CAManBase","LandVehicle","Air","Ship","ThingX"],2] isNotEqualTo []) exitWith {false};
private _base = ATLToASL _position;
lineIntersectsSurfaces [_base vectorAdd [0,0,0.1],_base vectorAdd [0,0,2.5],objNull,objNull,true,1,"GEOM","NONE"] isEqualTo []
