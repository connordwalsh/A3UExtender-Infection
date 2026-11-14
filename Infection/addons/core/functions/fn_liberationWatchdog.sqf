params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _name = _x;
    private _record = A3I_liberations get _name;
    if (!scriptDone (_record get "script")) then {continue};
    if !([_record] call A3I_fnc_finishLiberation) then {continue};
    if (!isNil {_record get "cityMaintenanceAt"} && {!(_record getOrDefault ["cityMaintenanceDone",false])}
        && {time >= _record get "cityMaintenanceAt"}) then {
        {[_record get "town",_x] spawn A3A_fnc_deleteControls} forEach controlsX;
        // The pinned tierCheck/updatePreference/updateVehicles chain does not
        // suspend. Finish it here before publishing the reward tier or cleanup.
        [] call A3A_fnc_tierCheck;
        _record set ["rewardTier",tierWar];
        _record set ["cityMaintenanceDone",true];
    };
    if (_record get "outcome" == "won" && {!([_record] call A3I_fnc_rewardLiberation)}) then {continue};
    if (!(_record get "taskDeleted") && {time >= _record get "taskDeleteAt"}) then {
        _record set ["taskDeleted",true];
        if (((missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name}) != -1) then {
            [_name,"townBattle",0] call A3A_fnc_taskDelete;
        } else {[_name] call BIS_fnc_deleteTask};
    };
    if (!(_record get "taskDeleted") || {spawner getVariable [_record get "town",2] != 2}) then {continue};
    if (!isNil {_record get "cityMaintenanceAt"} && {!(_record getOrDefault ["cityMaintenanceDone",false])}) then {continue};
    if !(([_record] call A3I_fnc_cleanupLiberationSurvivor) # 0) then {continue};
    if (!(_record get "claimsReleased")) then {
        _record set ["claimsReleased",true];
        {
            private _claim = A3I_liberationSkirmishClaims getOrDefault [_x,[true,[]]];
            private _owners = _claim # 1;
            private _index = _owners find _name;
            if (_index >= 0) then {_owners deleteAt _index};
            if (_owners isEqualTo []) then {
                if !(_claim # 0) then {
                    _index = townSkirmishes find _x;
                    if (_index >= 0) then {townSkirmishes deleteAt _index};
                };
                A3I_liberationSkirmishClaims deleteAt _x;
            };
        } forEach (_record get "claims");
    };
    A3I_liberations deleteAt _name;
} forEach keys A3I_liberations;
if (count A3I_liberations == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_liberationWatchdogHandle = nil;
};
