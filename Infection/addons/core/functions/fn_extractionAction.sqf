// Client presentation only. The server validates every request.
params [["_unit",objNull,[objNull]],["_remove",false,[false]]];
if (!hasInterface || {isNull _unit} || {isRemoteExecuted && {remoteExecutedOwner != 2}}) exitWith {};
private _old = _unit getVariable ["A3I_extractionAction",-1];
if (_old >= 0) then {_unit removeAction _old; _unit setVariable ["A3I_extractionAction",nil]};
if (_remove) exitWith {};
private _id = _unit addAction [localize "STR_antistasi_actions_free_prisoner",
    {params ["_target","_caller"]; [_target,_caller] remoteExecCall ["A3I_fnc_requestExtractionRelease",2]},
    nil,6,true,true,"",
    "isPlayer _this && {_this == _this getVariable ['owner',objNull]} && {side group _this == teamPlayer} && {alive _target} && {_target getVariable ['A3I_extractionReleaseState',''] == 'waiting'}",4];
_unit setVariable ["A3I_extractionAction",_id];
