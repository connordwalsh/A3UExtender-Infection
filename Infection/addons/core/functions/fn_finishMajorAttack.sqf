// Internal once-only task/resource settlement. The watchdog owns flag release
// and retirement independently, so a stopped worker cannot strand either one.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_finishMajorAttack,_this] call CBA_fnc_directCall};
if (_record get "settled") exitWith {};
_record set ["settled",true];
if (_record get "outcome" == "pending") then {_record set ["outcome","interrupted"]};
_record set ["queue",[]]; _record set ["creditRemaining",0];
if (_record get "paidActors" == 0 && {_record get "fixedCost" > 0}) then {
    [_record get "fixedCost",west,"attack"] call A3A_fnc_addEnemyResources;
    _record set ["fixedRefunded",true];
};
private _outcome = _record get "outcome";
private _completed = _record get "paidActors" > 0 && {_outcome in ["defeated","timeout","captured","petros_killed"]};
private _taskId = _record get "taskId";
private _taskType = _record get "taskType";
private _taskExists = (missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _taskId};
if (_record get "targetOwner" == teamPlayer) then {
    if (_completed && {_taskExists != -1}) then {
        private _failed = _outcome in ["captured","petros_killed"];
        [_taskId,_taskType,["SUCCEEDED","FAILED"] select _failed] call A3A_fnc_taskSetState;
        if (!_failed) then {
            private _hq = _record get "hq";
            {
                [round (([10,5] select _hq) * tierWar),_x] call A3A_fnc_addScorePlayer;
                [round (([110,150] select _hq) * tierWar),_x] call A3A_fnc_addMoneyPlayer;
            } forEach (call SCRT_fnc_misc_getRebelPlayers);
            if (_hq) then {
                if (getMarkerPos "Synd_HQ" distance2D (_record get "hqPosition") < 500) then {
                    [west,10,60] call A3A_fnc_addAggression;
                };
            } else {
                private _commander = missionNamespace getVariable ["theBoss",objNull];
                if (!isNull _commander) then {
                    [10,_commander] call A3A_fnc_addScorePlayer;
                    [100,_commander,true] call A3A_fnc_addMoneyPlayer;
                };
            };
            _record set ["rewarded",true];
        } else {
            if (!(_record get "hq")) then {
                private _commander = missionNamespace getVariable ["theBoss",objNull];
                if (!isNull _commander) then {[-round (5 * tierWar),_commander] call A3A_fnc_addScorePlayer};
            };
        };
        _record set ["taskDeleteScript",[_taskId,_taskType,[30,1200] select (_record get "hq")]
            spawn A3A_fnc_taskDelete];
    } else {
        // Ultimate taskUpdate accepts only success/failure, so cancellation is
        // presented through BIS and removed through native DELETED bookkeeping.
        if (_taskExists != -1) then {
            [_taskId,"CANCELED"] call BIS_fnc_taskSetState;
            [_taskId,_taskType,0] call A3A_fnc_taskDelete;
        } else {
            // Also remove a BIS task if a worker stopped before native registration.
            [_taskId] call BIS_fnc_deleteTask;
        };
    };
};
_record set ["releaseAt",time + ([0,60] select _completed)];
