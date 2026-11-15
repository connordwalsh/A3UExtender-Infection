params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_finishExtraction,_this] call CBA_fnc_directCall};
private _current=(missionNamespace getVariable ["A3I_extractionTasks",createHashMap]) getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record=_current;
if (_record get "settled") exitWith {true};
private _outcome=[_record] call A3I_fnc_extractionTaskOutcome;
if (_outcome == "pending") exitWith {[_record] call A3I_fnc_convertExtractionRescues; false};
_record set ["settled",true]; _record set ["outcome",_outcome]; _record set ["phase","settled"];
_record set ["taskDeleteAt",time]; _record set ["cleanupAt",time+([0,60] select (_record get "taskRegistered"))];
[_record] call A3I_fnc_convertExtractionRescues;
private _ledger=_record get "ledger";
if (count _ledger > 0) then {[_ledger get "name",_ledger get "serial"] call A3I_fnc_releaseExtractionLedger};
if !(_record get "taskRegistered") exitWith {true};
private _name=_record get "name";
if (A3A_tasksData findIf {_x # 0 == _name && {_x # 1 == "RES"}} < 0) exitWith {true};
if !(_outcome in ["succeeded","failed"]) exitWith {[_name,"CANCELED"] call BIS_fnc_taskSetState; true};
[_name,"RES",["FAILED","SUCCEEDED"] select (_outcome == "succeeded")] call A3A_fnc_taskSetState;
private _bonus=[1,2] select (_record get "difficult");
private _boss=missionNamespace getVariable ["theBoss",objNull];
if (_outcome == "succeeded") then {
    private _count=_ledger get "rescued";
    [0,100*_count*_bonus] spawn A3A_fnc_resourcesFIA;
    [west,-10,60] remoteExec ["A3A_fnc_addAggression",2];
    {[_count*_bonus,_x] call A3A_fnc_addScorePlayer;
        [_count*_bonus*10,_x] call A3A_fnc_addMoneyPlayer
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
    if (!isNull _boss) then {private _amount=round (_count*_bonus/2);
        [_amount,_boss] call A3A_fnc_addScorePlayer; [_amount*10,_boss,true] call A3A_fnc_addMoneyPlayer};
} else {if (!isNull _boss) then {[-10*_bonus,_boss] call A3A_fnc_addScorePlayer}};
_record set ["taskDeleteAt",time+600+random 1200];
true
