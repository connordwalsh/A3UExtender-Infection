params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_cleanupHumanitarianAid,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_aidTasks",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if !(_record get "settled") exitWith {false};
if (!(_record get "taskRetired") && {time >= _record get "taskDeleteAt"}) then {
    private _tasks = missionNamespace getVariable ["A3A_tasksData",[]];
    private _index = _tasks findIf {_x # 0 == _name};
    if (_index < 0 || {_tasks # _index # 1 == "SUPP"}) then {
        if (_index >= 0) then {[_name,"SUPP","DELETED"] call A3A_fnc_taskUpdate};
        if (_record get "taskRegistered") then {[_name] call BIS_fnc_deleteTask};
    };
    _record set ["taskRetired",true];
};
if !(_record get "assetRetired") then {
    private _package = _record get "package";
    if (isNull _package || {!((_package getVariable ["A3I_aidTaskOwner",[]]) isEqualTo [_name,_record get "serial"])}) then {
        // The native action uses an object-derived key. A new owner may still
        // need that same logistics action, so leave it registered on reassignment.
        if (!isNull _package) then {_record set ["loadJipKey",""]};
        _record set ["assetRetired",true];
    } else {
        private _inUse = !isNull attachedTo _package || {ropesAttachedTo _package isNotEqualTo []}
            || {ropes _package isNotEqualTo []}
            || {(vehicles findIf {_package in (_x call A3A_Logistics_fnc_getCargo)
                || {_x getVariable ["LoadingCargo",false] && {_x distance2D _package < 20}}}) != -1}
            || {((call A3I_fnc_spawnObservers) findIf {_x distance2D _package < 150}) != -1};
        if (!_inUse) then {
            _package setVariable ["A3I_aidTaskOwner",nil];
            deleteVehicle _package; _record set ["assetRetired",true];
        };
    };
};
if (_record get "assetRetired") then {
    private _key = _record getOrDefault ["loadJipKey",""];
    if (_key != "") then {remoteExec ["",_key]; _record set ["loadJipKey",""]};
};
(_record get "taskRetired") && {_record get "assetRetired"}
