params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {"interrupted"};
if (_record get "settled") exitWith {_record get "outcome"};
if (_record get "fault" != "") exitWith {"interrupted"};
if (_record get "phase" == "preparing") exitWith {["pending","interrupted"] select scriptDone (_record getOrDefault ["script",scriptNull])};
private _name = _record get "name";
if ((missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name && {_x # 1 == "SUPP"} && {_x # 2 == "CREATED"}} == -1) exitWith {"cancelled"};
private _ledger = _record get "ledger";
private _current = (missionNamespace getVariable ["A3I_aidLedgers",createHashMap]) getOrDefault [_name,createHashMap];
if (_current getOrDefault ["serial",-1] != _ledger getOrDefault ["serial",-2]) exitWith {"interrupted"};
private _package = _record get "package";
if (!isNull _package && {!((_package getVariable ["A3I_aidTaskOwner",[]]) isEqualTo [_name,_record get "serial"])}) exitWith {"interrupted"};
[_ledger] call A3I_fnc_updateAidLedger
