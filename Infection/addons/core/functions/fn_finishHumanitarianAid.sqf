params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {false};
if (canSuspend) exitWith {[A3I_fnc_finishHumanitarianAid,_this] call CBA_fnc_directCall};
private _current = (missionNamespace getVariable ["A3I_aidTasks",createHashMap]) getOrDefault [_record getOrDefault ["name",""],createHashMap];
if (_current getOrDefault ["serial",-1] != _record getOrDefault ["serial",-2]) exitWith {false};
_record = _current;
if (_record get "settled") exitWith {true};
private _outcome = [_record] call A3I_fnc_aidTaskOutcome;
if (_outcome == "pending") exitWith {false};
private _name = _record get "name";
_record set ["settled",true]; _record set ["outcome",_outcome]; _record set ["phase","settled"];
_record set ["taskDeleteAt",time];
if ((missionNamespace getVariable ["A3I_aidSupplyLock",[]]) isEqualTo [_name,_record get "serial"]) then {
    A3I_aidSupplyLock = nil; missionNamespace setVariable ["A3A_supplyMissionActive",nil,true];
};
private _ledger = _record get "ledger";
if (count _ledger > 0) then {[_ledger get "name",_ledger get "serial"] call A3I_fnc_releaseAidLedger};
private _package = _record get "package";
if (!isNull _package && {(_package getVariable ["A3I_aidTaskOwner",[]]) isEqualTo [_name,_record get "serial"]}) then {
    _package setVariable ["A3I_aidDisplay",[_record get "serial",_record getOrDefault ["townName",""],0,_outcome],true];
};
private _owners = _record get "notifiedOwners";
if (_owners isNotEqualTo []) then {[_record get "serial","",0,"stop"] remoteExecCall ["A3I_fnc_aidProgressHint",_owners]};
private _pickup = _record get "pickupMarker";
if (_pickup != "") then {deleteMarker _pickup; _record set ["pickupMarker",""]};
if !(_record get "taskRegistered") exitWith {true};
if (A3A_tasksData findIf {_x # 0 == _name && {_x # 1 == "SUPP"}} == -1) exitWith {true};
if !(_outcome in ["delivered","failed"]) exitWith {[_name,"CANCELED"] call BIS_fnc_taskSetState; true};
private _delivered = _outcome == "delivered";
[_name,"SUPP",["FAILED","SUCCEEDED"] select _delivered] call A3A_fnc_taskSetState;
private _bonus = [1,2] select (_record get "difficult");
private _commander = missionNamespace getVariable ["theBoss",objNull];
if (_delivered) then {
    [-5*_bonus,5*_bonus,_record get "target"] spawn A3A_fnc_citySupportChange;
    [west,-10,60] spawn A3A_fnc_addAggression;
    { [15*_bonus,_x] call A3A_fnc_addScorePlayer; [300*_bonus,_x] call A3A_fnc_addMoneyPlayer }
        forEach (call SCRT_fnc_misc_getRebelPlayers);
    if (!isNull _commander) then {[5*_bonus,_commander] call A3A_fnc_addScorePlayer; [100*_bonus,_commander,true] call A3A_fnc_addMoneyPlayer};
} else {
    [5*_bonus,-5*_bonus,_record get "target"] spawn A3A_fnc_citySupportChange;
    if (!isNull _commander) then {[-10*_bonus,_commander] call A3A_fnc_addScorePlayer};
};
_record set ["taskDeleteAt",time+450+random 900];
true
