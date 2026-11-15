params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_finishElimination,_this] call CBA_fnc_directCall};
private _current = (missionNamespace getVariable ["A3I_eliminationTasks",createHashMap])
    getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if (_record get "settled") exitWith {true};
private _outcome = [_record] call A3I_fnc_eliminationTaskOutcome;
if (_outcome == "pending") exitWith {false};
_record set ["settled",true]; _record set ["outcome",_outcome];
_record set ["phase","settled"]; _record set ["taskDeleteAt",time];
private _ledger = _record get "ledger";
if (count _ledger > 0) then {
    [_ledger get "name",_ledger get "serial"] call A3I_fnc_releaseEliminationLedger;
};
private _search = _record get "searchMarker";
if (_search != "") then {deleteMarker _search; _record set ["searchMarker",""]};
if !(_record get "taskRegistered") exitWith {true};
private _name = _record get "name";
if (A3A_tasksData findIf {_x # 0 == _name && {_x # 1 == "AS"}} < 0) exitWith {true};
if !(_outcome in ["neutralized","failed"]) exitWith {
    [_name,"CANCELED"] call BIS_fnc_taskSetState; true
};
[_name,"AS",["FAILED","SUCCEEDED"] select (_outcome == "neutralized")] call A3A_fnc_taskSetState;
if (_outcome == "neutralized") then {
    // Native AS_Zombies rewards, without its unrelated city-destruction loss.
    private _bonus = [1,2] select (_record get "difficult");
    [0,1000*_bonus] spawn A3A_fnc_resourcesFIA;
    [0,10*_bonus,getMarkerPos (_record get "source")] spawn A3A_fnc_citySupportChange;
    {
        [10*_bonus,_x] call A3A_fnc_addScorePlayer;
        [250*_bonus,_x] call A3A_fnc_addMoneyPlayer;
    } forEach (call SCRT_fnc_misc_getRebelPlayers);
};
_record set ["taskDeleteAt",time+600+random 1200];
true
