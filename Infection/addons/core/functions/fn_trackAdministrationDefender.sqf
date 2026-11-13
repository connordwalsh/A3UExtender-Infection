// Attach before the first scheduling boundary after creation. Death and live
// deletion have different objective effects, even after bodies are collected.
params ["_unit","_marker","_context"];
if (!isServer || {isRemoteExecuted && {remoteExecutedOwner != 2}} || {isNil "A3I_sites"}) exitWith {};
private _record = A3I_sites getOrDefault [_marker,createHashMap];
if (_record getOrDefault ["kind",""] != "MilAdmin" || {_record get "context" != _context}
    || {_unit getVariable ["A3I_adminTracked",false]}) exitWith {};
_unit setVariable ["A3I_adminTracked",true];
_unit setVariable ["A3I_adminMarker",_marker];
_unit setVariable ["A3I_adminId",_record get "id"];
_unit addEventHandler ["Killed", {["Killed",_this # 0] call A3I_fnc_administrationDefenderEvent}];
_unit addEventHandler ["Deleted", {["Deleted",_this # 0] call A3I_fnc_administrationDefenderEvent}];
