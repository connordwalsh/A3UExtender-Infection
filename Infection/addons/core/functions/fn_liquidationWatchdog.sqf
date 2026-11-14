params ["_arguments","_handle"];
if (!isServer || {isRemoteExecuted}) exitWith {};
{
    private _record = A3I_liquidationClaims get _x;
    // A stopped parent must not cancel a capture already inside its native
    // transaction or release its claim before the delayed flag work finishes.
    if (scriptDone (_record get "script")
        && {scriptDone (_record getOrDefault ["captureScript",scriptNull])}) then {
        [_record] call A3I_fnc_finishLiquidation;
        if (time >= _record get "taskDeleteAt") then {
            private _name = _record get "name";
            // The native zero-delay deletion operations, executed locally on
            // their authoritative server to retire registration without a gap.
            if ((missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name} != -1) then {
                [_name,"CON","DELETED"] call A3A_fnc_taskUpdate;
            };
            [_name] call BIS_fnc_deleteTask;
            A3I_liquidationClaims deleteAt _x;
        };
    };
} forEach keys A3I_liquidationClaims;
if (count A3I_liquidationClaims == 0) then {
    [_handle] call CBA_fnc_removePerFrameHandler;
    A3I_liquidationWatchdogHandle = nil;
};
