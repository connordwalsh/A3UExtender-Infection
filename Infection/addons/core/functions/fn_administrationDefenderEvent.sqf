// Only real engine events may advance clearing or replace a deleted defender.
params ["_event","_unit"];
if (!isServer || {isNil "_thisEvent"} || {_thisEvent != _event}
    || {!(_event in ["Killed","Deleted"])} || {isNil "A3I_sites"}
    || {_unit getVariable ["A3I_adminResolved",false]}) exitWith {};
private _marker = _unit getVariable ["A3I_adminMarker",""];
private _record = A3I_sites getOrDefault [_marker,createHashMap];
if (_record getOrDefault ["id",-1] != _unit getVariable ["A3I_adminId",-2]
    || {_record get "kind" != "MilAdmin"} || {_record get "cleaned"}) exitWith {};
_unit setVariable ["A3I_adminResolved",true];
if (_event == "Killed" && {!alive _unit}) exitWith {
    _record set ["remainingDefenders",((_record get "remainingDefenders") - 1) max 0];
};
if (_event == "Deleted" && {alive _unit} && {sidesX getVariable [_marker,sideUnknown] == west}
    && {spawner getVariable [_marker,2] != 2}) then {
    (_record get "queue") pushBack (_unit getVariable "unitType");
    spawner setVariable [_marker + "_A3I_pending",count (_record get "queue"),true];
};
