// Cache model bounds without creating a simulated, damageable truck at the site.
params [["_class","",[""]]];
if (!isServer || {isRemoteExecuted} || {!isClass (configFile >> "CfgVehicles" >> _class)}
    || {!(_class isKindOf "Car")}) exitWith {[]};
if (canSuspend) exitWith {[A3I_fnc_supplyTruckBounds,_this] call CBA_fnc_directCall};
private _cache = missionNamespace getVariable ["A3I_supplyTruckBounds",createHashMap];
if (_class in _cache) exitWith {+(_cache get _class)};
// Local, non-PhysX model, away from gameplay; removed in this unscheduled call.
private _model = createSimpleObject [_class,[0,0,10000],true];
if (isNull _model) exitWith {[]};
private _bounds = boundingBoxReal _model;
deleteVehicle _model;
if (count _bounds < 2) exitWith {[]};
private _minimum = _bounds # 0;
private _maximum = _bounds # 1;
private _dimensions = _maximum vectorDiff _minimum;
if ((_dimensions findIf {!finite _x || {_x <= 0} || {_x > 30}}) != -1) exitWith {[]};
_cache set [_class,[_minimum,_maximum]];
missionNamespace setVariable ["A3I_supplyTruckBounds",_cache];
[_minimum,_maximum]
