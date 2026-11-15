// Server-only task observation. Destination ownership changes do not cancel.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {"pending"};
if (canSuspend) exitWith {[A3I_fnc_interceptionTaskOutcome,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {"interrupted"};
private _outcome = _record getOrDefault ["outcome","pending"];
if (isNil "_outcome" || {!(_outcome isEqualType "")}) exitWith {"interrupted"};
if (_outcome != "pending") exitWith {_outcome};
if (!([west] call A3I_fnc_isActive) || {_record getOrDefault ["retired",true]}
    || {!(_record getOrDefault ["phase",""] in ["marching","arrived"])}) exitWith {"interrupted"};
if ((missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name && {_x # 1 == "CONVOY"}} == -1)
    exitWith {"cancelled"};
if (isNil {_record get "deadline"}) exitWith {"interrupted"};
private _deadline = _record get "deadline";
if !(_deadline isEqualType 0) exitWith {"interrupted"};
if (!finite _deadline) exitWith {"interrupted"};
// Engine events retain terminal evidence even if a controller stops afterward.
// Arrival wins when the first entrant is also the last actor killed that frame.
if (_record getOrDefault ["arrived",false]) exitWith {
    if (_record getOrDefault ["arrivedAt",time] <= _deadline) then {"arrived"} else {"timeout"}
};
if (_record getOrDefault ["fault",""] != "" || {_record getOrDefault ["missing",0] > 0}) exitWith {"interrupted"};
private _size = _record get "size";
if (_record get "created" == _size && {_record get "remaining" == 0}
    && {_record getOrDefault ["killed",0] == _size} && {_record getOrDefault ["eliminatedAt",-1] >= 0}) exitWith {
    if (_record get "eliminatedAt" <= _deadline) then {"won"} else {"timeout"}
};
if (scriptDone (_record getOrDefault ["script",scriptNull])) exitWith {"interrupted"};
private _target = _record get "target";
if (!(_target in allMapMarkers) || {!(_record get "source" in allMapMarkers)}) exitWith {"cancelled"};
private _index = (_record get "units") findIf {
    alive _x && {_x getVariable ["A3I_interceptionName",""] == _name}
        && {_x getVariable ["A3I_interceptionSerial",-1] == _record get "serial"} && {_x inArea _target}
};
if (_index >= 0) exitWith {
    _record set ["arrived",true]; _record set ["arrivedAt",time];
    _record set ["arrivalPosition",getPosATL ((_record get "units") # _index)];
    if (time <= _deadline) then {"arrived"} else {"timeout"}
};
if (time > _deadline) exitWith {"timeout"};
"pending"
