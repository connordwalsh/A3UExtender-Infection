params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_cleanupExtraction,_this] call CBA_fnc_directCall};
private _name=_record getOrDefault ["name",""];
private _current=(missionNamespace getVariable ["A3I_extractionTasks",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record=_current;
if !(_record get "settled") exitWith {false};
if (!(_record get "taskRetired") && {time >= _record get "taskDeleteAt"}) then {
    private _tasks=missionNamespace getVariable ["A3A_tasksData",[]];
    private _index=_tasks findIf {_x # 0 == _name};
    if (_index < 0 || {_tasks # _index # 1 == "RES"}) then {
        if (_index >= 0) then {[_name,"RES","DELETED"] call A3A_fnc_taskUpdate};
        if (_record get "taskRegistered") then {[_name] call BIS_fnc_deleteTask};
    };
    _record set ["taskRetired",true];
};
if (!(_record get "assetRetired") && {time >= _record get "cleanupAt"}) then {
    [_record] call A3I_fnc_convertExtractionRescues;
    private _remaining=[]; private _survivorsRemaining=[];
    {
        if (isNull _x || {!((_x getVariable ["A3I_extractionTaskOwner",[]]) isEqualTo [_name,_record get "serial"])}) then {continue};
        if (isPlayer _x) then {_x setVariable ["A3I_extractionTaskOwner",nil]; continue};
        private _ledgerOwner=_x getVariable ["A3I_extractionOwner",[]];
        if (_ledgerOwner isNotEqualTo []) then {_x setVariable ["A3I_extractionTaskOwner",nil]; continue};
        private _ledger=_record get "ledger";
        private _entryIndex=-1;
        // Resolve by the actual actor, not a global player or group reference.
        private _actor=_x;
        _entryIndex=(_ledger getOrDefault ["entries",[]]) findIf {_x get "unit" == _actor};
        if (_entryIndex >= 0 && {((_ledger get "entries") # _entryIndex) get "state" == "rescued"}
            && {!(((_ledger get "entries") # _entryIndex) getOrDefault ["converted",false])}) then {
            _survivorsRemaining pushBack _actor; continue;
        };
        // Owner explicitly retains native removal of ALL undelivered survivors,
        // including recruited AI, one minute after settlement. Never delete groups owned by players.
        deleteVehicle _x;
    } forEach (_record get "units");
    _record set ["units",_survivorsRemaining];
    private _observers=call A3I_fnc_spawnObservers;
    {
        if (isNull _x || {!((_x getVariable ["A3I_extractionTaskOwner",[]]) isEqualTo [_name,_record get "serial"])}) then {continue};
        private _unit=_x;
        if (isPlayer _unit || {!local _unit} || {!isNull attachedTo _unit}
            || {(_observers findIf {_x distance2D _unit < ((missionNamespace getVariable ["distanceSPWN",1000]) max 150)}) != -1}) then {
            _remaining pushBack _unit;
        } else {deleteVehicle _unit};
    } forEach (_record get "guards");
    _record set ["guards",_remaining];
    if (_remaining isEqualTo [] && {_survivorsRemaining isEqualTo []}) then {
        [_record get "groups"] call A3I_fnc_cleanupGroups;
        _record set ["assetRetired",true];
    };
};
(_record get "taskRetired") && {_record get "assetRetired"}
