params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_cleanupSupplySeizure,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_supplyTasks",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if !(_record get "settled") exitWith {false};
if (!(_record get "taskRetired") && {time >= _record get "taskDeleteAt"}) then {
    private _tasks = missionNamespace getVariable ["A3A_tasksData",[]];
    private _index = _tasks findIf {_x # 0 == _name};
    if (_index < 0 || {_tasks # _index # 1 == "LOG"}) then {
        if (_index >= 0) then {[_name,"LOG","DELETED"] call A3A_fnc_taskUpdate};
        if (_record get "taskRegistered") then {[_name] call BIS_fnc_deleteTask};
    };
    _record set ["taskRetired",true];
};
if !(_record get "assetRetired") then {
    private _truck = _record get "truck";
    private _owns = !isNull _truck && {(_truck getVariable ["A3I_supplyTaskOwner",[]])
        isEqualTo [_name,_record get "serial"]};
    if (!_owns) then {_record set ["assetRetired",true]} else {
        if (_truck getVariable ["ownerSide",sideUnknown] == teamPlayer) then {
            // Captured trucks remain usable even if delivery missed the deadline.
            _truck setVariable ["A3I_supplyTaskOwner",nil]; _record set ["assetRetired",true];
        } else {
            private _observers = call A3I_fnc_spawnObservers;
            private _inUse = (crew _truck findIf {alive _x}) != -1
                || {!isNull attachedTo _truck} || {ropesAttachedTo _truck isNotEqualTo []}
                || {ropes _truck isNotEqualTo []}
                || {(_observers findIf {_x distance2D _truck <
                    ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)}) != -1};
            if (!_inUse) then {
                _truck setVariable ["A3I_supplyTaskOwner",nil];
                deleteVehicle _truck; _record set ["assetRetired",true];
            };
        };
    };
};
(_record get "taskRetired") && {_record get "assetRetired"}
