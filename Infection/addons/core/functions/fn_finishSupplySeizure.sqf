params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_finishSupplySeizure,_this] call CBA_fnc_directCall};
private _current = (missionNamespace getVariable ["A3I_supplyTasks",createHashMap])
    getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if (_record get "settled") exitWith {true};
private _outcome = [_record] call A3I_fnc_supplyTaskOutcome;
if (_outcome == "pending") exitWith {false};
_record set ["settled",true]; _record set ["outcome",_outcome];
_record set ["phase","settled"]; _record set ["taskDeleteAt",time];
if !(_record get "taskRegistered") exitWith {true};
private _name = _record get "name";
private _index = A3A_tasksData findIf {_x # 0 == _name && {_x # 1 == "LOG"}};
if (_index < 0) exitWith {true};
if !(_outcome in ["delivered","destroyed","timeout"]) exitWith {
    [_name,"CANCELED"] call BIS_fnc_taskSetState; true
};
private _delivered = _outcome == "delivered";
[_name,"LOG",["FAILED","SUCCEEDED"] select _delivered] call A3A_fnc_taskSetState;
private _bonus = [1,2] select (_record get "difficult");
private _commander = missionNamespace getVariable ["theBoss",objNull];
if (_delivered) then {
    private _truck = _record get "truck";
    [_truck,teamPlayer,true] call A3A_fnc_vehKilledOrCaptured;
    [_truck] call A3A_fnc_addToStaticsToSave;
    [0,300 * _bonus] spawn A3A_fnc_resourcesFIA;
    [1200 * _bonus,west] remoteExec ["A3A_fnc_timingCA",2];
    {
        [15 * _bonus,_x] call A3A_fnc_addScorePlayer;
        [300 * _bonus,_x] call A3A_fnc_addMoneyPlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
    if (!isNull _commander) then {
        [5,_commander] call A3A_fnc_addScorePlayer;
        [200,_commander,true] call A3A_fnc_addMoneyPlayer;
    };
} else {
    [-1200 * _bonus,west] remoteExec ["A3A_fnc_timingCA",2];
    if (!isNull _commander) then {[-10 * _bonus,_commander] call A3A_fnc_addScorePlayer};
};
// Preserve native LOG task retention: taskDelete's 1200-second average.
_record set ["taskDeleteAt",time + 600 + random 1200];
true
