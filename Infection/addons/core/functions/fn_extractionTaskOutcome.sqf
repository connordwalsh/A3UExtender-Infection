params ["_record"];
if (!isServer || {isRemoteExecuted}) exitWith {"interrupted"};
if (_record getOrDefault ["settled",false]) exitWith {_record get "outcome"};
if (_record getOrDefault ["fault",""] != "") exitWith {"interrupted"};
if (_record get "phase" == "preparing") exitWith {
    ["pending","interrupted"] select scriptDone (_record getOrDefault ["script",scriptNull])
};
if (!([west] call A3I_fnc_isActive)) exitWith {"cancelled"};
private _name=_record get "name";
if ((missionNamespace getVariable ["A3A_tasksData",[]]) findIf {_x # 0 == _name && {_x # 1 == "RES"} && {_x # 2 == "CREATED"}} < 0) exitWith {"cancelled"};
private _ledger=_record get "ledger";
private _state=[_ledger] call A3I_fnc_updateExtractionLedger;
if (_state == "") exitWith {"interrupted"};
_state
