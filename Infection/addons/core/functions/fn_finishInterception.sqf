// Once-only native reinforcement-convoy reward baseline. No arrival adoption here.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_finishInterception,_this] call CBA_fnc_directCall};
private _name = _record getOrDefault ["name",""];
private _current = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]
    || {_record getOrDefault ["settled",false]}) exitWith {};
private _outcome = [_record] call A3I_fnc_interceptionTaskOutcome;
if (_outcome == "pending") exitWith {};
_record set ["outcome",_outcome];
_record set ["settled",true];
_record set ["taskDeleteAt",time];
private _handle = _record getOrDefault ["taskHandle",-1];
if (_handle >= 0) then {[_handle] call CBA_fnc_removePerFrameHandler; _record deleteAt "taskHandle"};
private _exists = (missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name && {_x # 1 == "CONVOY"}};
if (_exists == -1) exitWith {_record set ["outcome","cancelled"]};
if !(_outcome in ["won","arrived","timeout"]) exitWith {[_name,"CANCELED"] call BIS_fnc_taskSetState};
private _won = _outcome == "won";
[_name,"CONVOY",["FAILED","SUCCEEDED"] select _won] call A3A_fnc_taskSetState;
private _bonus = [1,1.5] select (_record getOrDefault ["difficult",false]);
private _commander = missionNamespace getVariable ["theBoss",objNull];
private _score = [-10,10 * _bonus] select _won;
if (!isNull _commander) then {
    [_score,_commander] call A3A_fnc_addScorePlayer;
    [10 * _score,_commander] call A3A_fnc_addMoneyPlayer;
};
[[-200,400 * _bonus] select _won,west] remoteExec ["A3A_fnc_timingCA",2];
if (_won) then {
    [west,10,120] remoteExec ["A3A_fnc_addAggression",2];
    [0,10 * _bonus,_record get "source"] remoteExec ["A3A_fnc_citySupportChange",2];
    private _position = _record get "eliminationPosition";
    {
        if (_x distance2D _position < 500) then {
            [10 * _bonus,_x] call A3A_fnc_addScorePlayer;
            [25 * _bonus,_x] call A3A_fnc_addMoneyPlayer;
        };
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
    private _source = _record get "source";
    private _target = _record get "target";
    killZones setVariable [_source,(killZones getVariable [_source,[]]) + [_target,_target],true];
};
if (_outcome == "arrived") then {_record set ["phase","arrived"]};
// Native taskDelete's 600-second argument is an average, not a fixed delay.
_record set ["taskDeleteAt",time + 300 + random 600];
