// Native CON_Outpost reward/penalty baseline. Cancellation and infrastructure
// interruption grant neither. Only the atomic ownership commit can record a win.
params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {};
if (canSuspend) exitWith {[A3I_fnc_finishLiquidation,_this] call CBA_fnc_directCall};
if (_record get "settled") exitWith {};
if (_record get "outcome" == "pending") then {_record set ["outcome","interrupted"]};
private _name = _record get "name";
private _exists = (missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name};
if (_exists == -1) then {_record set ["outcome","cancelled"]};
_record set ["settled",true];
_record set ["taskDeleteAt",time];
private _outcome = _record get "outcome";
if !(_outcome in ["won","timeout"]) exitWith {
    if (_exists != -1) then {[_name,"CANCELED"] call BIS_fnc_taskSetState};
};
private _won = _outcome == "won";
private _hard = _record get "difficult";
private _position = _record get "position";
private _commander = missionNamespace getVariable ["theBoss",objNull];
[_name,"CON",["FAILED","SUCCEEDED"] select _won] call A3A_fnc_taskSetState;
if (_won) then {
    [0,[600,800] select _hard] remoteExec ["A3A_fnc_resourcesFIA",2];
    [[-20,-25] select _hard,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
    [[1200,1800] select _hard,west] remoteExec ["A3A_fnc_timingCA",2];
    {
        [[250,450] select _hard,_x] call A3A_fnc_addMoneyPlayer;
        [[10,20] select _hard,_x] call A3A_fnc_addScorePlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
    if (!isNull _commander) then {
        [[10,20] select _hard,_commander] call A3A_fnc_addScorePlayer;
        [[100,200] select _hard,_commander,true] call A3A_fnc_addMoneyPlayer;
    };
} else {
    [[5,25] select _hard,0,_position] remoteExec ["A3A_fnc_citySupportChange",2];
    [[-600,-1200] select _hard,west] remoteExec ["A3A_fnc_timingCA",2];
    if (!isNull _commander) then {[[-10,-20] select _hard,_commander] call A3A_fnc_addScorePlayer};
};
// Preserve native average 20-minute retention without a disposable sleeping job.
_record set ["taskDeleteAt",time + 600 + random 1200];
