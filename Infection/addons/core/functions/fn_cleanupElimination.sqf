params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_cleanupElimination,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_eliminationTasks",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if !(_record get "settled") exitWith {false};
if (!(_record get "taskRetired") && {time >= _record get "taskDeleteAt"}) then {
    private _tasks = missionNamespace getVariable ["A3A_tasksData",[]];
    private _index = _tasks findIf {_x # 0 == _name};
    if (_index < 0 || {_tasks # _index # 1 == "AS"}) then {
        if (_index >= 0) then {[_name,"AS","DELETED"] call A3A_fnc_taskUpdate};
        if (_record get "taskRegistered") then {[_name] call BIS_fnc_deleteTask};
    };
    _record set ["taskRetired",true];
};
if !(_record get "assetRetired") then {
    private _remaining = [];
    private _observers = call A3I_fnc_spawnObservers;
    {
        if (isNull _x || {!((_x getVariable ["A3I_eliminationTaskOwner",[]])
            isEqualTo [_name,_record get "serial"])}) then {continue};
        // A new ledger owner may have claimed the primary after releasing the
        // previous ledger. Do not delete that actor using our older task tag.
        private _ledgerOwner = _x getVariable ["A3I_eliminationOwner",[]];
        private _ledger = _record get "ledger";
        if (_ledgerOwner isNotEqualTo [] && {!(_ledgerOwner isEqualTo
            [_ledger getOrDefault ["name",""],_ledger getOrDefault ["serial",-1]])}) then {
            _x setVariable ["A3I_eliminationTaskOwner",nil];
            continue;
        };
        private _unit = _x;
        private _inUse = isPlayer _unit || {!local _unit} || {!isNull attachedTo _unit}
            || {(_observers findIf {_x distance2D _unit <
                ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)}) != -1};
        if (_inUse) then {_remaining pushBack _unit} else {
            _unit setVariable ["A3I_eliminationTaskOwner",nil]; deleteVehicle _unit;
        };
    } forEach (_record get "units");
    _record set ["units",_remaining];
    if (_remaining isEqualTo []) then {
        [[_record get "group"]] call A3I_fnc_cleanupGroups;
        _record set ["assetRetired",true];
    };
};
(_record get "taskRetired") && {_record get "assetRetired"}
