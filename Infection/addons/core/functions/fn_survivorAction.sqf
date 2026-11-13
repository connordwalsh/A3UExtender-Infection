// Client action setup; its request carries no reward or authoritative state.
params ["_unit"];
if (!hasInterface || {isNull _unit} || {isRemoteExecuted && {remoteExecutedOwner != 2}}
    || {!(_unit getVariable ["A3I_survivor",false])}) exitWith {};
private _old = _unit getVariable ["A3I_survivorAction",-1];
if (_old != -1) exitWith {};
private _id = _unit addAction [
    format ["<img image='\a3\ui_f\data\IGUI\Cfg\holdactions\holdAction_unbind_ca.paa' size='1.6' /> %1",localize "STR_antistasi_actions_free_prisoner"],
    {params ["_target","_caller"]; [_target,_caller] remoteExecCall ["A3I_fnc_requestRescue",2]},
    nil,6,true,true,"",
    "isPlayer _this && {side group _this == teamPlayer} && {alive _target} && {_target getVariable ['A3I_survivorState',''] == 'waiting'}",4
];
_unit setVariable ["A3I_survivorAction",_id];
