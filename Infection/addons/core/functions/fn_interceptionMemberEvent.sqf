// Only engine death is elimination credit. Live deletion retains the obligation.
params ["_event","_unit"];
if (!isServer || {isNil "_thisEvent"} || {_thisEvent != _event}
    || {!(_event in ["Killed","Deleted"])}
    || {_unit getVariable ["A3I_interceptionResolved",false]}) exitWith {};
private _name = _unit getVariable ["A3I_interceptionName",""];
private _record = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_record getOrDefault ["serial",-1] != _unit getVariable ["A3I_interceptionSerial",-2]
    || {_record getOrDefault ["retired",true]}
    || {_record getOrDefault ["phase",""] == "cleanup"}) exitWith {};
_unit setVariable ["A3I_interceptionResolved",true];
if (_event == "Killed" && {!alive _unit}) exitWith {
    // Preserve first-entry failure if the first arrival dies before the next poll.
    private _target = _record get "target";
    if (_record get "phase" == "marching" && {_target in allMapMarkers} && {_unit inArea _target}) then {
        _record set ["arrived",true];
    };
    _record set ["remaining",((_record get "remaining") - 1) max 0];
    _record set ["killed",(_record getOrDefault ["killed",0]) + 1];
    if (_record get "phase" == "preparing") then {_record set ["fault","preparation_casualty"]};
};
_record set ["missing",(_record getOrDefault ["missing",0]) + 1];
_record set ["fault","missing_member"];
