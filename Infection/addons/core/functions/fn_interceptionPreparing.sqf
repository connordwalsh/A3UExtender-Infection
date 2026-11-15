// Internal owner and preparation guard; no reservation or mutation.
params ["_record"];
if (!isServer || {isRemoteExecuted} || {!([west] call A3I_fnc_isActive)}) exitWith {false};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {_record getOrDefault ["context",""] != "interception:" + _name}
    || {_record getOrDefault ["phase",""] != "preparing"}
    || {_record getOrDefault ["retired",true]} || {_record getOrDefault ["fault","missing"] != ""}
    || {scriptDone (_record getOrDefault ["script",scriptNull])}) exitWith {false};
private _size = _record getOrDefault ["size",0];
if (!(_size isEqualType 0 && {finite _size} && {_size >= 1} && {_size <= 120} && {floor _size == _size})
    || {_record getOrDefault ["remaining",-1] != _size} || {_record getOrDefault ["missing",1] != 0}) exitWith {false};
private _source = _record getOrDefault ["source",""];
private _target = _record getOrDefault ["target",""];
if (!([_source,false] call A3I_fnc_majorSourceEligible) || {!(_target in allMapMarkers)}
    || {!(sidesX getVariable [_target,sideUnknown] in [west,teamPlayer])}) exitWith {false};
private _position = _record getOrDefault ["spawnPosition",[]];
private _destination = _record getOrDefault ["destinationPosition",[]];
if (count _position != 3 || {count _destination != 3}
    || {_position distance2D getMarkerPos _source > 25}
    || {!([_destination,_target] call A3I_fnc_interceptionContains)}
    || {_position distance2D getMarkerPos _target <= ([_target] call A3I_fnc_interceptionRadius) + 100}) exitWith {false};
true
