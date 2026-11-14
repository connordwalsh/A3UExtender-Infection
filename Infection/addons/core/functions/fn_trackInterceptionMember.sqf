// Called atomically by spawnGroup after native initialization and budget bind.
params ["_unit","_context"];
if (!isServer || {isRemoteExecuted} || {isNull _unit} || {!local _unit}
    || {!alive _unit} || {_context find "interception:" != 0}) exitWith {false};
private _name = _context select [13];
private _record = (missionNamespace getVariable ["A3I_interceptions",createHashMap]) getOrDefault [_name,createHashMap];
if (!([_record] call A3I_fnc_interceptionPreparing)
    || {_record getOrDefault ["created",0] >= _record get "size"}
    || {_unit getVariable ["A3I_interceptionTracked",false]}) exitWith {false};
private _ticket = _unit getVariable ["A3I_budgetTicket",""];
private _binding = A3I_budgetRecords getOrDefault [_ticket,[]];
if (_binding isEqualTo [] || {_binding # 0 != _context} || {!(_unit in (_binding # 2))}
    || {group _unit getVariable ["A3I_context",""] != _context}) exitWith {false};
_unit setVariable ["A3I_interceptionTracked",true];
_unit setVariable ["A3I_interceptionName",_name];
_unit setVariable ["A3I_interceptionSerial",_record get "serial"];
_unit setVariable ["A3I_interceptionResolved",false];
_unit addEventHandler ["Killed",{["Killed",_this # 0] call A3I_fnc_interceptionMemberEvent}];
_unit addEventHandler ["Deleted",{["Deleted",_this # 0] call A3I_fnc_interceptionMemberEvent}];
_unit enableSimulationGlobal false;
_unit hideObjectGlobal true;
(_record get "units") pushBack _unit;
(_record get "groups") pushBackUnique group _unit;
_record set ["created",(_record get "created") + 1];
true
