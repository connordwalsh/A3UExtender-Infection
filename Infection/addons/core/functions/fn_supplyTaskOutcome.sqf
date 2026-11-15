params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {"interrupted"};
if (_record getOrDefault ["settled",false]) exitWith {_record get "outcome"};
if (_record getOrDefault ["fault",""] != "") exitWith {"interrupted"};
if (_record get "phase" == "preparing") exitWith {
    ["pending","interrupted"] select scriptDone (_record getOrDefault ["script",scriptNull])
};
if (!([west] call A3I_fnc_isActive)) exitWith {"cancelled"};
private _name = _record get "name";
private _tasks = missionNamespace getVariable ["A3A_tasksData",[]];
private _index = _tasks findIf {_x # 0 == _name && {_x # 1 == "LOG"} && {_x # 2 == "CREATED"}};
if (_index < 0) exitWith {"cancelled"};
private _truck = _record get "truck";
if (isNull _truck) exitWith {"interrupted"};
if (!((_truck getVariable ["A3I_supplyTaskOwner",[]]) isEqualTo [_name,_record get "serial"]))
    exitWith {"interrupted"};
if (!alive _truck) exitWith {"destroyed"};
if (time >= _record get "deadline") exitWith {"timeout"};
// The owner explicitly keeps recovery active after either faction captures the
// source. Only current delivery-site ownership is relevant after truck creation.
private _destination = [_truck,"truck"] call A3I_fnc_deliveryDestination;
if (_destination != "") exitWith {_record set ["deliveryDestination",_destination]; "delivered"};
"pending"
