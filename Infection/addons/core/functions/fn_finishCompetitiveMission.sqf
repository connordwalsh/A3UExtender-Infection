// Once-only settlement. Rewards/penalties match native competitive conquest;
// unavailable, interrupted and cancelled missions do not grant either.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_finishCompetitiveMission,_this] call CBA_fnc_directCall};
if (_record get "settled") exitWith {};
_record set ["settled",true];
if (_record get "outcome" == "pending") then {_record set ["outcome","interrupted"]};
private _outcome = _record get "outcome";
private _name = _record get "name";
if (_outcome in ["cancelled","interrupted"]) then {
    // Find linked jobs even if this worker stopped before saving the return.
    {
        if (_y getOrDefault ["mission",""] == _name && {_y get "outcome" == "pending"}) then {
            _y set ["outcome","cancelled"];
            _y set ["queue",[]]; _y set ["creditRemaining",0];
        };
    } forEach (missionNamespace getVariable ["A3I_majorAttacks",createHashMap]);
};
private _exists = (missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name};
// Native task metadata is authoritative if startup stopped between taskUpdate
// and setting taskRegistered on this record.
if (_exists == -1) exitWith {[_name] call BIS_fnc_deleteTask};
if !(_outcome in ["won","lost_race","timeout"]) exitWith {
    [_name,"CANCELED"] call BIS_fnc_taskSetState;
    [_name,"CON",0] call A3A_fnc_taskDelete;
};
private _won = _outcome == "won";
private _difficult = _record get "difficult";
private _position = _record get "position";
[_name,"CON",["FAILED","SUCCEEDED"] select _won] call A3A_fnc_taskSetState;
private _commander = missionNamespace getVariable ["theBoss",objNull];
if (_won) then {
    [0,[600,800] select _difficult] remoteExec ["A3A_fnc_resourcesFIA",2];
    [[-20,-25] select _difficult,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
    [[1200,1800] select _difficult,Invaders] remoteExec ["A3A_fnc_timingCA",2];
    {
        [[250,450] select _difficult,_x] call A3A_fnc_addMoneyPlayer;
        [[20,30] select _difficult,_x] call A3A_fnc_addScorePlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
    if (!isNull _commander) then {
        [[20,30] select _difficult,_commander] call A3A_fnc_addScorePlayer;
        [[200,300] select _difficult,_commander,true] call A3A_fnc_addMoneyPlayer;
    };
} else {
    [[5,25] select _difficult,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
    [[-600,-1200] select _difficult,Invaders] remoteExec ["A3A_fnc_timingCA",2];
    if (!isNull _commander) then {[[-10,-20] select _difficult,_commander] call A3A_fnc_addScorePlayer};
};
_record set ["taskDeleteScript",[_name,"CON",1200] spawn A3A_fnc_taskDelete];
